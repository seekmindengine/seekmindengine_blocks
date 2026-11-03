# PDU to Stream 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / PDU To Stream

## 概览

PDU to Stream 从消息的 uniform-vector 负载中取出样本，形成带突发起止标签的流输出。没有待发送数据时不产生样本；模块不会自行补零维持固定速率。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `pdu_pdu_to_stream_x` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

1. **消息转流**  
   将消息域数据转换为流域格式

2. **突发数据传输**  
   将 PDU 包中的数据展开为连续流

3. **协议数据处理**  
   将协议层数据送入流处理链路

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `pdus` | 消息 | `(metadata dict, uniform vector)` | 负载类型须与 PDU Type 一致 |
| 输出 | `默认` | 样本流 | PDU Type 对应标量 | 负载依次展开，附带突发标签 |

空负载会被忽略。类型应按实际向量元素约定匹配，不能仅因字节宽度相同就混用整数和浮点数据。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **PDU Type** | 枚举 | 负载和输出类型：Byte、Short、Int、Float 或 Complex | Float | ✗ |
| **Early Behavior** | 枚举 | 前一突发未完成时，新 PDU 的处理方式：Append 排队，Drop 丢弃，Balk 丢弃并记错误 | Append | ✗ |
| **Queue Depth** | 整数 | 最多排队的 PDU 数；队满后丢弃新包 | 64 | ✓ |

## 工作原理

接收有效 PDU 后排队，调度时将负载写入流。突发首样本带 `tx_sob=True`，末样本带 `tx_eob=True`；有效的 `tx_time` 元数据会变成首样本时间标签，内容为“整数秒 + 小数秒”。

Append 模式下，队列中后续不带时间的 PDU 可能合并进同一突发，因此不能假定每个 PDU 都对应独立的一对起止标签。模块不自动生成 `packet_len`，也不会把所有元数据逐项变成流标签。

## 快速示例

PDU Type=Float、Early Behavior=Append，向 `pdus` 发送一次：

```python
pmt.cons(pmt.make_dict(), pmt.init_f32vector(3, [1.0, 2.0, 3.0]))
```

输出分别接 Float File Sink 和 Float Tag Debug，检查样本 `[1,2,3]`，offset=0 的 tx_sob，以及 offset=2 的 tx_eob。发送动作应在流程启动后执行；消息源使用上述表达式构造 PMT 对象。

## 性能与部署

Queue Depth 限制的是包数，内存还取决于每包负载长度与当前突发。持续输入超过下游消费能力时会丢包；增加队列只能吸收短时突发。

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 无输出 | 消息结构、类型或空负载 | 先使用三元素 f32vector 示例 |
| 新包被丢弃 | Early Behavior 或队列容量 | 按业务选择排队方式并控制发送速率 |
| 找不到长度标签 | 模块输出的是突发标签 | 需要长度标签时另行构造 |
| 两包之间没有独立起止 | 无时间 PDU 被合并 | 不将本模块用作严格逐包边界转换器 |

## 相关 Block

- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：流数据加标签
- [Message Debug](Message_Debug.md)：消息调试输出

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
