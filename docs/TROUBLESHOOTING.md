# SeekMind Engine 故障排查

[文档首页](../README.md) / 故障排查

本指南按流程校验、流式端口、消息端口和运行时行为组织。先保留第一条错误信息，再逐步缩小范围；不要一次修改多个无关参数。

## 标准排查顺序

1. 流程能否通过编辑器校验并完成构造？
2. Source 是否产生了预期类型和布局的数据？
3. 每一段流的 item 率、采样率语义和标签是否正确？
4. 完整链路的吞吐是否达到外部设备或 I/O 的要求？

常用隔离方式：

```text
[Source] -> [Null Sink]
[Source] -> [Suspected Block] -> [Null Sink]
[Known Source] -> [Suspected Block] -> [GUI or File Sink]
```

## 流程无法启动

### 数据类型或向量长度不匹配

检查连接两端的基础类型、item size 和 `vlen`。复杂数到浮点数不是隐式转换，需要 `Complex to Mag` 或其他含义明确的转换 Block。

```text
[complex] -> [Complex to Mag] -> [float]
[scalar stream] -> [Stream to Vector (N)] -> [vector item, vlen=N]
```

流程编辑器可能在生成前报告不兼容，运行时也可能在连接构造阶段报告 item size 不一致。不要把这类检查统一称为“编译期检查”。

### 端口域不匹配

样本流端口不能直接连接消息端口。

- PDU 消息到样本流：使用 `PDU to Stream`
- 样本流到 tagged stream：使用 `Stream to Tagged Stream`
- tagged stream 到 PDU：需要 `Tagged Stream to PDU` 或目标版本中的等价 Block

`Stream to Tagged Stream` 本身不产生消息或 PDU。

### 参数表达式错误

- 检查变量名和定义顺序
- 暂时用常量替换复杂表达式
- 对照模块页确认参数类型、单位、有效范围和断言
- 参数以产品集成版本的模块定义为准

### 设备不可用

USRP 可先用 UHD 工具确认设备是否可发现：

```bash
uhd_find_devices
uhd_usrp_probe
```

然后检查设备地址、驱动/固件兼容性、权限、网络接口和是否被其他进程占用。音频设备名称和查询方法取决于操作系统与所用音频后端。

## 流程运行但无预期数据

### 先验证 Source

```text
[Source] -> [QT GUI Time Sink]
[Source] -> [Head] -> [File Sink]
[Source] -> [Null Sink]
```

注意：纯软件源没有 Throttle 时会尽快运行，但“无 Throttle”通常不是“没有输出”的原因。它更可能造成 CPU 占用高、GUI 刷新不便或流程很快结束。需要实时观察时再加 Throttle。

### 文件已经读完

File Source 在 Repeat=No 时读到文件末尾结束该数据源；当前面板默认 Repeat=Yes，会循环读取。根据需要配置 Repeat，或用 Head 明确限制测试 item 数。File Source 读取的是裸 item，不携带类型或采样率元数据；读取端的类型和向量长度必须与写入布局一致。

### 选择或丢弃 Block

检查 `Head`、`Skip Head`、`Keep M in N`、`Keep One in N` 和 `Selector` 的具体参数。不要把所有“无输出”都归因于滤波器；先使用确定性输入验证保留/丢弃位置。

### PDU 没有输出流

确认 PDU 是 `(metadata, uniform-vector payload)`，payload 类型与 `PDU to Stream` 的 PDU Type 一致，并检查 Early Behavior 和 Queue Depth。普通 PMT 字符串或任意 pair 不一定是有效 PDU。

## 数值或坐标轴错误

### 按段核对采样率

采样率不是连接类型。为每个 rate-changing Block 前后分别记录：

```text
fs_out = fs_in * interpolation / decimation
```

检查：

- Signal Source 用于波形生成的 Sample Rate
- 滤波器 taps 设计所用 Sample Rate
- QT GUI Time Sink 的 Sample Rate
- QT GUI Frequency Sink 的 Bandwidth
- 硬件 Source/Sink 实际接受的设备采样率

不要要求多速率流程中所有 Block 填同一个采样率。

### 单位和类型转换

- 频率通常为 Hz，时间通常为秒
- Float 到整数的舍入、截断、饱和或溢出行为以具体转换 Block 为准
- Complex 到 Float 必须明确选择幅度、相位、实部或虚部
- GUI Autoscale 只改变显示范围，不改变样本值

### 频谱幅值不符合预期

确认 FFT size、窗函数、窗功率归一化、平均系数、Y 轴单位和输入是实数还是复数。未经相同配置和标定，不应承诺固定的峰值 dB 或旁瓣数值。

## 性能、Overflow 与 Underflow

### 纯软件流程占用一个 CPU 核

纯软件 Source 通常会尽快运行。若目标是实时观察，可加入 Throttle；若目标是离线尽快完成，则无需限速。

### 硬件 Overflow

硬件 Source 持续产生数据，而下游没有及时消费时可能 overflow。按以下顺序定位：

```text
[USRP Source] -> [Null Sink]
[USRP Source] -> [Filter] -> [Null Sink]
[USRP Source] -> [Full Processing] -> [Target Sink]
```

可采取的措施包括降低设备采样率、减少不必要 GUI、减少处理量、调整硬件端抽取/插值或改善主机 I/O。硬件 Source 后加入更慢的 Throttle 不会修复 overflow。

### 硬件 Sink Underflow

硬件 Sink 无法及时获得样本时可能 underflow。检查上游是否能持续供数、主机到设备链路、重采样后的实际 item 率以及设备时钟配置。

### 缓冲区与内存

流式缓冲通常有界。增大缓冲区可能吸收短时抖动，但会增加延迟，也不能提高长期平均吞吐。进程内存增长不等于已经证明“流缓冲持续积压”；还需检查消息队列、Block 内部缓存、GUI 和应用代码。

### GUI 开销

用 Null Sink 替换 GUI 做 A/B 测试。必要时增加 Update Period、减小 FFT Size 或 Number of Points，并减少同时显示的通道。不要引用未经目标机器实测的固定 CPU 降幅。

## 文件问题

### 原始 File Source/File Sink

数据率可按 item size 估算：

```text
bytes_per_second = item_rate * item_size * channels
```

确认文件系统的持续写入能力、剩余空间和目标路径权限。裸文件没有自描述头，必须另行记录基础类型、字节序、向量长度和采样率。

### WAV 文件

WAV Source/Sink 支持的通道数、位深、采样格式和头部行为可能随产品集成版本变化。以当前模块参数和接口文档为准，不在通用排障文档中假定固定的“仅 1 或 2 通道”或固定裁剪行为。

## 网络与 ZeroMQ

### UDP

检查本地绑定地址、目标地址、端口、payload/item size、MTU、防火墙和接收端是否已启动。UDP 不提供可靠送达或流式背压；系统 socket buffer 只能吸收短时突发，不能弥补长期带宽不足。

系统调优命令依赖操作系统，应先查看当前值和系统文档，不要直接套用固定 `sysctl` 数字。

### ZeroMQ

- 核对 endpoint 中的 transport，例如 `tcp://` 或 `ipc://`
- 明确哪个 Block bind、哪个 Block connect
- PUB/SUB 可能出现 slow joiner 导致初始消息未被订阅者收到
- 流式 ZMQ Block 与消息 ZMQ Block 的端口域不同，不能互换

## 标签问题

使用 Tag Debug 在关键位置观察 offset、key、value 和 srcid：

```text
[Source] -> [Tag Debug] -> [Processing]
```

若标签在 rate-changing Block 后位置异常，检查该 Block 的 relative rate、sample delay 和 tag propagation policy。不能假定所有 Block 都传播全部标签，也不能假定简单用整数除法就能得到所有情况下的准确 offset。

## 获取有效帮助

报告问题时至少提供：

- SeekMind Engine 版本
- 最小可复现流程或关键连接图
- Block ID、参数和端口类型
- 第一条完整错误及其上下文
- 输入数据类型、向量长度和每段采样率
- 操作系统、硬件型号、驱动与固件版本
- 已完成的最小链路和 Null Sink 测试结果

---

[快速入门](GETTING_STARTED.md) / [核心概念](CONCEPTS.md) / [Block 目录](../README.md#block-目录)
