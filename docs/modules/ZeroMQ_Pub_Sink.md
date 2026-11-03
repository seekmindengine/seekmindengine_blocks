# ZeroMQ Pub Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / ZMQ PUB Sink

## 概览

ZeroMQ Pub Sink 将输入样本流按批次封装为 ZeroMQ 帧，通过 PUB socket 发布给订阅端。它适合将同一条采集或处理结果流分发给多个进程。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | ZeroMQ（ZeroMQ） |
| Block ID | `zeromq_pub_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

- 在进程或主机之间传输连续样本。
- 将一路信号分发到多个显示、记录或分析节点。

需要传输 PMT/PDU 控制消息时，使用相应的 Message 模块。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | IO Type × Vector Length | 要发布的连续样本 |

两端必须一致配置数据类型、向量长度及 Pass Tags；原始样本字节不会自动携带类型或采样率。使用非空 Filter Key 时，两端应采用匹配的主题帧约定。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **IO Type** | 枚举 | 选择输入输出样本类型，连接两端必须一致 | Float | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |
| **Address** | 字符串 | 设置 ZeroMQ 端点，例如 tcp://127.0.0.1:5555 | tcp://127.0.0.1:5555 | ✗ |
| **Timeout (msec)** | float | 设置网络操作超时，单位为毫秒 | 100 | ✗ |
| **Pass Tags** | 枚举 | 控制是否随样本流传递标签元数据 | No | ✗ |
| **High Watermark** | 整数 | 队列消息数上限；-1 保留库默认值，0 表示不设上限 | -1 | ✗ |
| **Filter Key** | 字符串 | 发送时附加的主题键；留空时不附加主题帧 |  | ✗ |
| **On Full Buffer** | 枚举 | 选择内部缓冲区满时的处理策略 | Drop | ✗ |
| **Connection** | 枚举 | 选择由本端连接还是绑定 ZeroMQ 地址 | Bind | ✗ |

## 工作原理

```text
[样本源] → [ZMQ PUB Sink] ── 网络 ── [ZMQ SUB Source] → [样本处理]
```

发送端按调度批次打包样本；Filter Key 非空时先发送主题帧，再发送样本帧。Pass Tags=Yes 时，样本帧还包含标签头，接收端必须按同一格式解析。订阅键用于前缀匹配。

传输帧边界不等于协议包边界；订阅端输出 item 率受实际到达数据与下游消费速度影响。

## 快速示例

发送流程：Signal Source（Float、32000 Sps、1000 Hz）→ Throttle（Float、32000）→ ZMQ PUB Sink。

接收流程：ZMQ SUB Source → QT GUI Time Sink（Float、Sample Rate=32000）。

收发两端均设 IO Type=Float、Vector Length=1、Address=`tcp://127.0.0.1:5555`、Pass Tags=No、Filter Key 为空。PUB 设 Connection=Bind，SUB 设 Connection=Connect。启动后，接收端应显示 1 kHz 波形；连接建立前的数据可能丢失。

跨主机时，PUB 可绑定 `tcp://*:5555`，SUB 使用发布机器的实际地址。

## 性能与部署

网络带宽、批次大小、队列水位和接收端速度决定吞吐与延迟。PUB 的 On Full Buffer=Drop 允许丢弃，Block 会施加背压；PUB/SUB 不提供历史重放或端到端确认。接收端需要连续无缺口数据时，应额外检测数据连续性。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无数据 | 地址、连接角色或主题键不匹配 | 先用本机、空主题键验证 |
| 样本异常 | 类型、字节布局、向量长度或标签格式不一致 | 统一两端格式 |
| 刚启动时缺数据 | 订阅连接尚未建立 | 等待连接稳定后再开始需要完整记录的采集 |
| 数据停顿或丢失 | 队列满、网络慢或接收处理慢 | 检查水位、背压策略及实际吞吐 |

## 相关 Block

- [ZeroMQ Pub Sink](ZeroMQ_Pub_Sink.md)：发布样本流。
- [ZeroMQ Sub Source](ZeroMQ_Sub_Source.md)：接收样本流。
- [ZMQ PUB Message Sink](ZMQ_PUB_Message_Sink.md)：发布 PMT/PDU 消息。
- [ZMQ SUB Message Source](ZMQ_SUB_Message_Source.md)：接收 PMT/PDU 消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
