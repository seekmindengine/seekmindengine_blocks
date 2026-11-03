# SeekMind Engine 核心概念

[文档首页](../README.md) / 核心概念

SeekMind Engine 以流图组织内置 Block，并通过端口、调度和数据项语义定义处理关系。若概念说明与产品中的实际模块定义不一致，以产品集成版本为准。

## 流图与 Block

流程是由 Block 和连接组成的有向图。Block 声明输入、输出及处理关系，运行时调度器根据上下游缓冲区可用空间调用 Block。

连接主要检查以下接口属性：

- 端口域：样本流端口或消息端口
- 样本数据类型及 item size
- 向量长度
- 必需端口和可选端口的数量

流程编辑器会在生成流程前执行连接和参数校验，部分不一致也可能在流程构造或启动时由运行时报告。这不是 C/C++ 意义上的“编译期类型检查”。采样率通常也不是连接类型的一部分。

## Block 处理关系

当前模块体系常见的流式 Block 处理关系如下：

| 处理关系 | 每个端口的输入/输出 item 关系 | 说明 |
|---|---|---|
| Source | 无流输入 | 产生样本；常由同步 Block 派生 |
| Sink | 无流输出 | 消费样本；常由同步 Block 派生 |
| Synchronous | 1:1 | 每个输入端口消费的 item 数与每个输出端口产生的 item 数相同 |
| Decimator | N:1 | 固定整数倍抽取 |
| Interpolator | 1:N | 固定整数倍插值 |
| General/Basic | 由 Block 声明或在运行时决定 | 用于不符合上述固定整数关系的处理 |

“Source/Sink”描述端口角色，“Sync/Decimator/Interpolator/General”描述调度关系，两者不是互斥分类。不能只根据用途或算法名称猜测某个 Block 的基类，例如 FFT 对向量 item 的处理通常是 1:1。

## 样本流

样本流连接传输连续的 item。一个 item 可以是一个标量，也可以是固定长度向量。上游写入缓冲区，下游从对应缓冲区读取；缓冲区满时，纯软件上游会等待可用空间。硬件设备仍可能继续采样或要求持续送样，因此主机处理不及时会表现为 overflow 或 underflow。

### 标量与向量

`vlen=1` 表示每个 item 含一个元素；`vlen=N` 表示每个 item 含 N 个相同基础类型的元素。

```text
标量 item:  s0, s1, s2, ...
向量 item: [v0 ... vN-1], [vN ... v2N-1], ...
```

常用布局转换 Block：

- `Stream to Vector`：把单路连续标量按顺序组成向量 item
- `Vector to Stream`：把向量 item 按顺序展开为标量 item
- `Streams to Vector`：同一时刻从多路输入各取一个 item，按端口顺序组成一个更长的向量 item
- `Vector to Streams`：按向量位置把一个向量 item 分配到多个输出端口

`Stream to Vector(N)` 的输出 item 率是输入标量 item 率的 `1/N`，但元素所代表的原始采样间隔没有因此改变。向量长度只需满足 Block 的接口和算法要求，并不普遍要求为 2 的幂。

## 消息与 PDU

消息端口传递 PMT（Polymorphic Type）对象。PMT 可以是符号、数值、pair、vector、dictionary 等，并不等同于 dictionary。消息处理由具体 Block 的消息处理器或内部队列决定，不应把流式端口的速率、缓冲或标签规则套用到消息端口。

PDU 是具有约定结构的 PMT pair：

```text
(metadata, payload)
```

- `metadata` 通常是 PMT dictionary 或 `PMT_NIL`
- `payload` 是与 PDU 类型匹配的 uniform vector

样本流端口和消息端口不能直接连接。当前内置的 `PDU to Stream` 把 PDU payload 输出为样本流；`Stream to Tagged Stream` 只是在流中周期性加入长度标签，并不会把样本流转换成 PDU。若要执行相反转换，需要目标版本提供的 `Tagged Stream to PDU` 或等价实现。

## 流标签

流标签是关联到某个绝对 item offset 的元数据。一个标签包含：

- `offset`：端口内的绝对 item 偏移
- `key`：PMT key
- `value`：PMT value
- `srcid`：可选的来源标识

标签传播由 Block 的 tag propagation policy 和实现共同决定。常见策略包括 all-to-all、one-to-one 和不自动传播。对声明了相对速率的 Block，调度器会据此换算标签 offset；遇到含延迟、选择、丢弃或不确定速率的 Block 时，应查看该 Block 的实际定义，不能假定标签一定原样保留。

`Stream to Tagged Stream` 每隔配置的 packet length 在样本流中添加一个长度标签。Tagged stream 仍然是流，只是使用长度标签表达包边界。

## 采样率

采样率通常是 Block 参数的数值约定，而不是流端口类型。它可能用于：

- 由 Signal Source 把频率换算为每个样本的相位增量
- 由滤波器设计 Block 生成 taps
- 由 QT GUI Sink 标定时间轴或频率轴
- 由硬件 Source/Sink 配置设备采样率
- 由 Throttle 设置平均 item 处理速率上限

连接成功并不证明采样率配置正确。检查时应按“每一段流”的实际 item 率记录，而不是要求整条路径上的数值始终相同。经过抽取、插值或有理重采样后，下游采样率应按 Block 的 rate change 更新：

```text
fs_out = fs_in * interpolation / decimation
```

重采样 Block 改变输入/输出 item 的速率关系，并通常包含相应滤波。Throttle 不做重采样，它只限制调度中的平均 item 通过速率。

## Throttle 与速率限制

纯软件源通常会按可用 CPU 尽快产生数据。对需要近似实时观察的仿真流程，可加入一个 Throttle 以限制平均 item 率。以下情况不应把 Throttle 写成强制要求：

- 离线处理本来就需要尽快完成
- 流程已经由音频、SDR 或其他阻塞 I/O 限速
- 网络或文件 I/O 的实际行为已满足应用需求

硬件 Source 后通常不需要再加 Throttle。若 Throttle 上限低于硬件实际产生率，它会限制下游消费并可能加重硬件 overflow。若一个流程同时包含硬件 Source 和硬件 Sink，则两端都可能具有自己的设备时钟；这不是“每条路径只能有一个时钟源”能够概括的问题，需要根据设备时钟同步、缓存和速率匹配单独设计。

## 缓冲与吞吐

流式缓冲区通常是有界的。下游变慢时，软件上游会因输出空间不足而等待；硬件或外部传输无法总是被这种等待反向限速，所以可能丢样、溢出、欠载或丢包。

定位吞吐问题时可逐段替换为 `Null Sink`：

```text
[Source] -> [Null Sink]
[Source] -> [Filter] -> [Null Sink]
[Source] -> [Filter] -> [GUI or I/O Sink]
```

持续增长的进程内存不能直接等同于“流缓冲积压”。它也可能来自消息队列、Block 内部缓存、GUI 数据、文件映射或内存泄漏，需要结合 Block 实现和运行指标判断。

## 参数与变量

Block 参数在生成流程时求值。生成后的 Block 是否支持运行时更新，取决于它是否提供 callback、setter、消息端口或其他控制接口。不能仅从参数名称推断“运行时可调”。

流程变量适合统一共享数值，但在多速率流程中应分别命名不同阶段的采样率：

```python
rf_rate = 2_000_000
channel_rate = 200_000
audio_rate = 48_000
```

## 设计检查清单

- [ ] 端口域、数据类型、item size、向量长度和端口数量匹配
- [ ] 每一段流的实际采样率已记录，速率变换前后计算正确
- [ ] 滤波器和 GUI 使用对应阶段的采样率
- [ ] Throttle 只在需要限制纯软件执行速度时使用
- [ ] PDU payload 类型与 `PDU to Stream` 的 PDU Type 匹配
- [ ] 依赖标签的流程已核对每个中间 Block 的传播策略
- [ ] 硬件链路已观察 overflow/underflow，并以目标数据率验证
- [ ] 参数是否可在运行时更新已由 callback 或 Block API 确认

## 定义优先级

Block 级参数、端口、默认值和运行行为以产品实际集成的模块定义与实现为准。通用概念说明不能覆盖具体 Block 的特殊行为。

---

[快速入门](GETTING_STARTED.md) / [故障排查](TROUBLESHOOTING.md) / [Block 目录](../README.md#block-目录)
