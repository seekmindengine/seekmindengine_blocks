# UDP Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / UDP Sink

## 概览

UDP Sink 模块把输入 stream 数据打包为 UDP 数据包，并发送到指定 IP 地址和端口。它适合与外部程序、其他主机或网络设备做轻量实时数据传输。

UDP 是无连接协议，发送开销低、实时性好，但不保证可靠送达、顺序和去重。因此本模块适合实时监视、局域网高速传输和可容忍丢包的链路；如果需要严格可靠记录，应考虑 File Sink 或在应用层增加序号、确认和重传机制。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Networking Tools（网络工具） |
| Block ID | `network_udp_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | 平台内置 |

## 何时使用

1. **网络输出**  
   将 SeekMind Engine 样本流发送到外部程序或另一台主机

2. **实时联调**  
   与 Python、C++、LabVIEW、MATLAB 等程序通过 UDP 对接

3. **轻量数据桥接**  
   在不同进程或设备间传递样本流

4. **硬件/嵌入式接口**  
   向支持 UDP 输入的设备发送数据

5. **丢包测试**  
   配合带序列号 Header 检查网络或系统栈瓶颈

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | Input Type × Vector Length | 连续样本流端口 |

> 发送端与接收端必须就地址、端口、连接角色、数据类型和消息格式达成一致；跨主机使用前先验证网络可达性。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Input Type** | 枚举 | 输入类型：complex、float、int、short、byte | float |
| **Address** | 字符串 | 目标 IP 地址或主机名 | 127.0.0.1 |
| **Destination Port** | 整数 | 目标 UDP 端口 | 2000 |
| **Header** | 枚举 | 包头格式：None、64-bit Sequence Number、Sequence + data size、CHDR | None |
| **UDP Packet Data Size** | 整数 | 单个 UDP 包 payload 字节数 | 1472 |
| **Send Null Packet as EOF** | 枚举 | 结束时是否发送空包作为 EOF | No |
| **Vector Length** | 整数 | 输入向量长度 | 1 |

## 参数说明

**1. Input Type（输入类型）**
- 决定每个样本的字节数和解释方式
- complex 通常为复数 float32 IQ 样本
- 发送端和接收端必须使用一致的数据类型

**2. Address（目标地址）**
- 本机测试可使用 `127.0.0.1`
- 局域网传输填写接收端主机 IP
- 块定义说明：检测到 IPv6 地址时会按 IPv6 连接处理，但系统 IPv6 栈需要可用

**3. Destination Port（目标端口）**
- 接收端 UDP Source 或外部程序监听的端口
- 必须大于 0
- 避免使用系统保留端口或已被占用端口

**4. Header（包头）**
- None：只发送样本 payload
- 64-bit Sequence Number：添加 64 位序列号，用于检测丢包
- Sequence + 16-bit data size：添加序列号和数据大小
- CHDR：用于特定兼容场景

**5. UDP Packet Data Size（UDP 包数据大小）**
- 表示每个 UDP 包中样本数据 payload 的字节数
- 块定义文档中指出：标准网络中 1472 字节通常对应 `1500 - 28`，即以太网 MTU 扣除 IPv4/UDP 头
- Jumbo frame 场景可使用类似 8972，但需要网络路径都支持
- 设置过大可能导致 IP 分片，增加丢包和重组开销

**6. Send Null Packet as EOF（发送 EOF 空包）**
- Yes：结束时发送空 UDP 包表示 EOF
- No：不发送 EOF 标记
- 接收端或外部程序必须约定如何解释空包

**7. Vector Length（向量长度）**
- 与输入流项目大小共同决定打包边界
- 必须大于 0
- 接收端需要按相同类型和向量长度解释数据

## 工作原理

```
输入 stream → 按类型和 vlen 转字节 → 可选 Header → UDP Packet → 网络发送
```

模块不进行重采样、压缩或可靠传输控制。输入数据会按照配置被拆分成多个 UDP 包发送。

## 快速示例

**示例 1：本机 UDP 测试**

发送端：

```
[Signal Source] → [Throttle] → [UDP Sink]
                              127.0.0.1:2000
```

接收端：

```
[UDP Source] → [QT GUI Time Sink]
 port=2000
```

配置要点：
- 两端类型一致，例如 float
- Header 设置一致
- Payload size 设置一致

**示例 2：发送复数 IQ 数据**

```
[UHD: USRP Source] → [Low Pass Filter] → [UDP Sink]
                                      complex, 192.168.1.20:2000
```

接收端需要按 complex float32 IQ 数据解释 payload。

**示例 3：启用序列号检测丢包**

```
[Source] → [UDP Sink]
           Header = 64-bit Sequence Number
```

接收端或测试程序可根据序列号跳变判断 UDP 包是否丢失。

## Payload Size 选择

| 网络环境 | 建议值 | 说明 |
|----------|--------|------|
| 普通以太网 MTU 1500 | 1472 | 常见 IPv4/UDP payload 上限 |
| Jumbo Frame MTU 9000 | 8972 | 需要整条路径支持 jumbo frame |
| 不确定网络 | 小于 1472 | 减少分片风险 |

配置时优先避免 IP 分片。分片后的 UDP 包只要任一分片丢失，整个包都无法恢复。

## 性能与系统设置

块定义文档建议在高吞吐场景下关注操作系统 socket buffer。例如 Linux 上可根据实际情况调整：

```
net.core.rmem_default
net.core.rmem_max
net.core.wmem_default
net.core.wmem_max
```

是否调整以及调到多少取决于系统权限、网络速率和部署环境。修改系统参数前应先用测试流图验证瓶颈。

## 性能与部署

实际吞吐受网络带宽、序列化开销、缓冲和接收端处理能力共同限制。长时间运行应监控丢包、积压和重连行为。

## 故障排查

**Q1: UDP Sink 会保证数据不丢吗？**  
A: 不会。UDP 不提供可靠送达。可用序列号 Header 检测丢包，但不能自动补发。

**Q2: 为什么接收端数据错位？**  
A: 常见原因是 Input Type、Vector Length、Header 或 Payload Size 与接收端不一致。

**Q3: Payload Size 为什么默认 1472？**  
A: 在标准 MTU 1500 的 IPv4 UDP 场景中，1472 字节通常可避免分片。

**Q4: 可以跨公网使用吗？**  
A: 技术上可以，但要考虑防火墙、NAT、丢包、延迟和安全问题。默认更适合受控局域网。

**Q5: 和 ZMQ PUB Sink 怎么选？**  
A: UDP 更轻量但可靠性更弱；ZMQ 提供更丰富的连接模型和队列行为，适合进程间解耦。

## 典型应用场景

**实时数据桥：**

```
[Processing] → [UDP Sink] → 外部实时显示程序
```

**局域网采集分发：**

```
[USRP Source] → [UDP Sink] → 远端 [UDP Source] → [File Sink]
```

**网络压力测试：**

```
[Vector Source] → [Throttle] → [UDP Sink] → [UDP Source] → [Sequence Check]
```

## 相关 Block

- [UDP Source](UDP_Source.md)：UDP 数据接收
- [ZMQ PUB Sink](ZeroMQ_Pub_Sink.md)：ZeroMQ 流发布
- [File Sink](File_Sink.md)：本地保存
- [Throttle](Throttle.md)：纯软件源限速

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
