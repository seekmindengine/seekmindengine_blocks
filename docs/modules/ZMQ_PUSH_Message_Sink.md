# ZMQ PUSH Message Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / ZMQ PUSH Message Sink

## 概览

ZMQ PUSH Message Sink 模块接收 SeekMind Engine 消息端口中的 PMT/PDU 消息，并通过 ZeroMQ PUSH socket 发送给 PULL 接收端。PUSH/PULL 更像任务管道或工作队列，不同于 PUB/SUB 的广播订阅模型。

当存在多个 PULL 接收端时，PUSH 通常会在接收端之间分发消息，而不是让每个接收端都收到同一份消息。因此它适合任务分发、负载均衡和流水线处理。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | ZeroMQ（ZeroMQ） |
| Block ID | `zeromq_push_msg_sink` |
| 处理模型 | 消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

1. **任务分发**  
   将 PDU 或控制任务推送给一个或多个工作进程

2. **消息流水线**  
   构建上游产生消息、下游消费消息的处理链

3. **跨进程处理**  
   将 SeekMind Engine 内部消息送到外部程序处理

4. **负载分担**  
   多个 PULL 端可分担消息处理压力

5. **PDU 外发**  
   将包数据发送到独立解析或存储程序

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
- 常见格式：`tcp://127.0.0.1:5555`
- 本端 Bind 时可使用 `tcp://*:5555`
- 应与 PULL 端地址对应

**2. Timeout（超时）**
- 控制发送等待时间
- 接收端处理慢或未连接时，超时影响阻塞表现

**3. Bind（绑定方式）**
- Yes：PUSH 端绑定地址，等待 PULL 连接
- No：PUSH 端连接到 PULL 绑定地址
- 常见配置是 PUSH Bind，PULL Connect

## 工作原理

```
消息输入端口 in → PMT/PDU 序列化 → ZeroMQ PUSH socket → PULL 接收端
```

PUSH/PULL 关注消息分发，不适合广播同一消息给多个消费者。如果需要广播，使用 PUB/SUB 消息模块。

## 快速示例

**示例 1：将 PDU 推送给外部处理进程**

```
[PDU Producer] --pdus--> [ZMQ PUSH Message Sink]
```

外部或另一个流程图中：

```
[ZMQ PULL Message Source] --out--> [PDU Processor]
```

**示例 2：任务队列**

```
[Task Builder] --task--> [ZMQ PUSH Message Sink] → 多个 PULL Worker
```

每个任务通常只由某一个 Worker 处理。

## PUB/SUB 与 PUSH/PULL 对比

| 模式 | 发送端 | 接收端 | 语义 |
|------|--------|--------|------|
| PUB/SUB | PUB Message Sink | SUB Message Source | 广播/订阅 |
| PUSH/PULL | PUSH Message Sink | PULL Message Source | 队列/分发 |

选择原则：
- 要让多个接收端都看到同一消息：PUB/SUB
- 要把任务分给多个工作端处理：PUSH/PULL

## 性能与部署

实际吞吐受网络带宽、序列化开销、缓冲和接收端处理能力共同限制。长时间运行应监控丢包、积压和重连行为。

## 故障排查

**Q1: 多个 PULL 端会都收到同一条消息吗？**  
A: 通常不会。PUSH/PULL 用于分发，消息会被分配给某个 PULL 端。

**Q2: 能接 ZMQ SUB Message Source 吗？**  
A: 不能。PUSH 必须配 PULL；PUB 才配 SUB。

**Q3: 适合发控制广播吗？**  
A: 不适合广播。控制广播应使用 ZMQ PUB Message Sink。

**Q4: 消息格式需要注意什么？**  
A: 与其他消息接口一样，接收端需要理解 SeekMind Engine PDU 编码。

## 典型应用场景

**PDU 工作队列：**

```
[Packet Source] --pdus--> [ZMQ PUSH Message Sink] → [Worker 1]
                                                   → [Worker 2]
```

**外部任务处理：**

```
[Detector] --event--> [ZMQ PUSH Message Sink] → [External Processor]
```

## 相关 Block

- [ZMQ PULL Message Source](ZeroMQ_Pull_Msg_Source.md)：接收 PUSH 消息
- [ZMQ PUB Message Sink](ZMQ_PUB_Message_Sink.md)：广播消息
- [Message Debug](Message_Debug.md)：调试消息
- [PDU To Stream](PDU_to_Stream.md)：PDU 转流

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
