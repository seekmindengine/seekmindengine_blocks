# ZeroMQ Pull Msg Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / ZMQ PULL Message Source

## 概览

ZeroMQ Pull Msg Source 模块使用 ZeroMQ 的 PULL 套接字接收消息数据。它支持跨进程和跨网络的消息通信，适用于分布式信号处理系统中接收远程消息。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | ZeroMQ（ZeroMQ） |
| Block ID | `zeromq_pull_msg_source` |
| 处理模型 | 消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **分布式消息接收**  
   从远程节点接收消息数据

2. **跨进程通信**  
   在不同进程间传递控制消息或数据

3. **消息队列消费**  
   从 ZeroMQ 消息队列中拉取消息

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `out` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 发送端与接收端必须就地址、端口、连接角色、数据类型和消息格式达成一致；跨主机使用前先验证网络可达性。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Address** | 字符串 | 设置 ZeroMQ 端点，例如 tcp://127.0.0.1:5555 | tcp://127.0.0.1:5555 | ✗ |
| **Timeout (msec)** | float | 设置网络操作超时，单位为毫秒 | 100 | ✗ |
| **Bind** | 枚举 | 控制本端是否绑定并监听所配置的地址 | No | ✗ |

## 参数说明

**1. Address**
- 网络地址

**2. Timeout (msec)**
- 网络操作的超时时间，单位为毫秒。
**3. Bind**
- 决定本端是否绑定并监听地址；通信两端只能有一端绑定同一端点。
  - **Yes**：True
  - **No**：False

## 工作原理

```
[远程 ZeroMQ PUSH] ── 网络 ── [ZeroMQ Pull Msg Source] ── 消息输出
```

## 快速示例

**示例 1：跨进程消息接收**

```
[外部程序 (PUSH)] ── tcp://localhost:5555 ── [ZeroMQ Pull Msg Source] → [处理模块]
```

## 性能与部署

实际吞吐受网络带宽、序列化开销、缓冲和接收端处理能力共同限制。长时间运行应监控丢包、积压和重连行为。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无法连接 | 地址、端口或 Bind/Connect 角色冲突 | 逐端确认监听方与连接方，并检查网络可达性 |
| 能连接但无数据 | 数据类型、消息格式或启动顺序不一致 | 用最小收发链路验证格式，并先启动接收端 |

更多通用排查方法见[故障排查指南](../TROUBLESHOOTING.md)。

## 相关 Block

- [ZeroMQ Pub Sink](ZeroMQ_Pub_Sink.md)：通过 PUB 模式发送消息
- [ZeroMQ Sub Source](ZeroMQ_Sub_Source.md)：通过 SUB 模式订阅消息

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
