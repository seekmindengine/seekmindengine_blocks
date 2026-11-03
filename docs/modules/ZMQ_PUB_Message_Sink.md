# ZMQ PUB Message Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / ZMQ PUB Message Sink

## 概览

ZMQ PUB Message Sink 接收 SeekMind Engine 平台消息（PMT/PDU），并通过 ZeroMQ PUB 模式发布。它与 ZMQ PUB Sink 的边界很明确：本 Block 处理离散消息，后者处理连续样本流。

它适合广播控制命令、状态事件、检测结果、PDU 包或调试信息。多个订阅端可以同时接收同一类消息，但 PUB/SUB 模型通常不会保存订阅端连接前的历史消息。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | ZeroMQ（ZeroMQ） |
| Block ID | `zeromq_pub_msg_sink` |
| 处理模型 | 消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

1. **消息广播**  
   将 PMT/PDU 消息发布给一个或多个订阅者

2. **事件通知**  
   发布检测结果、告警、状态变化等离散事件

3. **跨进程控制**  
   将流图内部控制消息送到外部程序

4. **PDU 分发**  
   将包处理链路中的 PDU 发往其他进程

5. **调试监控**  
   与 Message Debug 或外部 ZeroMQ 客户端配合查看消息内容

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `in` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 发送端与接收端必须就地址、端口、连接角色、数据类型和消息格式达成一致；跨主机使用前先验证网络可达性。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Address** | 字符串 | ZeroMQ 地址 | tcp://127.0.0.1:5555 |
| **Timeout (msec)** | 浮点数 | 发送超时时间 | 100 |
| **Bind** | 枚举 | 是否由本端绑定地址 | Yes |

## 参数说明

**1. Address（地址）**
- 常见格式为 `tcp://127.0.0.1:5555`
- 本端 Bind 时，可使用 `tcp://*:5555` 监听所有网卡
- 与订阅端地址必须对应

**2. Timeout（超时）**
- 控制发送等待时间
- 消息量很大或订阅端处理较慢时，超时设置会影响阻塞和丢弃表现

**3. Bind（绑定方式）**
- Yes：本模块绑定地址，等待 SUB 端连接
- No：本模块连接到对方绑定的地址
- 常见配置是 PUB Message Sink Bind，SUB Message Source Connect

## 工作原理

```
消息输入端口 in → PMT/PDU 序列化 → ZeroMQ PUB socket → 订阅端
```

消息是否能被外部程序正确解析，取决于接收端是否理解 SeekMind Engine 消息编码约定。使用相同编码约定的 SeekMind Engine 流程或外部接收端通常最容易兼容。

## 快速示例

**示例 1：发布按钮控制消息**

```
[QT GUI Msg Push Button] --msg--> [ZMQ PUB Message Sink]
```

另一个流程图中：

```
[ZMQ SUB Message Source] --out--> [Message Debug]
```

**示例 2：发布 PDU 包**

```
[Packet Generator] --pdus--> [ZMQ PUB Message Sink]
```

接收端可用 ZMQ SUB Message Source 接收后，送入 PDU To Stream 或自定义消息处理模块。

**示例 3：广播检测事件**

```
[Detector] --event--> [ZMQ PUB Message Sink]
```

多个订阅端可同时接收检测事件并分别记录、显示或触发控制逻辑。

## PUB/SUB 消息特点

| 特性 | 说明 |
|------|------|
| 一对多 | 多个 SUB 端可同时收到消息 |
| 不补发历史 | 订阅端连接前的消息通常收不到 |
| 无确认机制 | 发布端不知道订阅端是否真正处理 |
| 适合广播 | 状态、事件、控制消息很合适 |
| 不适合任务分发 | 任务队列应考虑 PUSH/PULL |

## 调试建议

1. 先用 Message Debug 在发送前确认消息内容
2. 再用本地 ZMQ SUB Message Source 验证接收
3. 最后接入外部程序
4. 如果消息必须可靠保存，同时写入 Message to File 或日志模块

## 性能与部署

实际吞吐受网络带宽、序列化开销、缓冲和接收端处理能力共同限制。长时间运行应监控丢包、积压和重连行为。

## 故障排查

**Q1: 和 ZMQ PUB Sink 有什么区别？**  
A: ZMQ PUB Message Sink 处理离散消息；ZMQ PUB Sink 处理连续样本流。

**Q2: 多个订阅者会抢消息吗？**  
A: 不会。PUB/SUB 是广播模型，匹配订阅者通常都会收到一份。

**Q3: 为什么外部程序解析不了消息？**  
A: 外部程序需要理解 SeekMind Engine PDU 的序列化格式。若只想传普通文本或 JSON，需要在发送前转换成约定格式。

**Q4: 能保证消息不丢吗？**  
A: PUB/SUB 不提供端到端可靠确认。关键控制消息应设计确认机制或使用更可靠的通道。

## 典型应用场景

**远程控制广播：**

```
[Control UI] --msg--> [ZMQ PUB Message Sink] → 多个控制接收端
```

**事件监控：**

```
[Threshold Detector] --event--> [ZMQ PUB Message Sink] → [Logger / UI]
```

## 相关 Block

- [ZMQ SUB Message Source](ZMQ_SUB_Message_Source.md)：订阅消息
- [ZMQ PUB Sink](ZeroMQ_Pub_Sink.md)：发布流数据
- [Message Debug](Message_Debug.md)：调试消息内容
- [PDU To Stream](PDU_to_Stream.md)：PDU 转流

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
