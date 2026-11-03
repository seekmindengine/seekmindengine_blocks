# ZMQ SUB Message Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / ZMQ SUB Message Source

## 概览

ZMQ SUB Message Source 模块订阅 ZeroMQ PUB 消息，并将收到的消息输出到 SeekMind Engine 消息端口。它用于把外部控制消息、PDU 包或事件通知引入 SeekMind Engine 流图。

本模块处理消息域数据，不产生连续样本流输出。如果需要接收样本流，应使用 ZMQ SUB Source。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | ZeroMQ（ZeroMQ） |
| Block ID | `zeromq_sub_msg_source` |
| 处理模型 | 消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **消息订阅**  
   从 ZMQ PUB Message Sink 或外部 PUB 程序接收消息

2. **远程控制**  
   将外部程序发出的控制命令送入流图

3. **PDU 接入**  
   接收远端发来的包数据，继续进行 PDU 或流处理

4. **事件接收**  
   接收检测结果、状态变化或告警信息

5. **调试桥接**  
   将外部消息直接送到 Message Debug 查看

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `out` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 发送端与接收端必须就地址、端口、连接角色、数据类型和消息格式达成一致；跨主机使用前先验证网络可达性。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Address** | 字符串 | ZeroMQ 地址 | tcp://127.0.0.1:5555 |
| **Timeout (msec)** | 浮点数 | 接收超时时间 | 100 |
| **Bind** | 枚举 | 是否由本端绑定地址 | No |

## 参数说明

**1. Address（地址）**
- 应与发布端配置匹配
- 本地测试常用 `tcp://127.0.0.1:5555`
- 跨主机时需填写可访问的 IP 地址

**2. Timeout（超时）**
- 控制等待消息的时间
- 超时不代表永久断开，只表示当前没有收到消息
- 对交互式控制，默认值通常足够

**3. Bind（绑定方式）**
- No：连接到发布端绑定的地址，最常见
- Yes：本端绑定地址，等待发布端连接
- 两端必须一端 Bind、一端 Connect

## 工作原理

```
ZeroMQ SUB socket → 接收消息 → 反序列化为 PMT/PDU → 输出消息端口 out
```

输出端口是 message 域，通常连接到 Message Debug、PDU To Stream、自定义控制块或带消息输入的模块。

## 快速示例

**示例 1：接收并打印消息**

```
[ZMQ SUB Message Source] --out--> [Message Debug]
```

这是验证连接和消息格式的最简单方式。

**示例 2：接收远程控制命令**

```
[ZMQ SUB Message Source] --out--> [Controller Block]
```

Controller Block 根据消息内容调整频率、增益、模式或开关状态。

**示例 3：PDU 转流**

```
[ZMQ SUB Message Source] --out--> [PDU To Stream] → [Modulator]
```

接收端必须确保收到的消息确实是 PDU 格式，否则 PDU To Stream 无法按预期处理。

## 启动顺序建议

PUB/SUB 模型通常不会补发历史消息。对于控制消息：

1. 先启动 SUB Message Source 所在流程图
2. 再启动 PUB Message Sink 或外部发布端
3. 对关键状态消息，发布端可定期重发当前状态
4. 对一次性命令，建议设计确认或查询机制

## 性能与部署

实际吞吐受网络带宽、序列化开销、缓冲和接收端处理能力共同限制。长时间运行应监控丢包、积压和重连行为。

## 故障排查

**Q1: 为什么 Message Debug 没有输出？**  
A: 检查地址、Bind 设置、发布端是否已启动，以及消息是否在订阅端连接后发送。

**Q2: 可以接收 ZMQ PUB Sink 的流数据吗？**  
A: 不可以。ZMQ PUB Sink 是 stream 接口；本模块是 message 接口。

**Q3: 收到的消息一定是 PDU 吗？**  
A: 不一定。消息可以是 PMT 符号、数值、字典、pair 或 PDU，取决于发送端。

**Q4: 外部程序如何发送兼容消息？**  
A: 需要按 SeekMind Engine ZeroMQ 消息接口使用的格式编码。若外部程序只发送普通字符串，接收端未必能直接解释为 PMT。

## 典型应用场景

**远程 UI 控制：**

```
[Remote UI] → [ZMQ SUB Message Source] --cmd--> [Controlled Block]
```

**跨进程 PDU 链路：**

```
进程 A: [Packet Builder] --pdus--> [ZMQ PUB Message Sink]
进程 B: [ZMQ SUB Message Source] --out--> [Packet Parser]
```

## 相关 Block

- [ZMQ PUB Message Sink](ZMQ_PUB_Message_Sink.md)：发布消息
- [Message Debug](Message_Debug.md)：查看消息内容
- [PDU To Stream](PDU_to_Stream.md)：PDU 转流
- [ZMQ SUB Source](ZeroMQ_Sub_Source.md)：订阅连续流数据

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
