# UDP Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / UDP Source

## 概览

UDP Source 模块监听指定 UDP 端口，将收到的 UDP payload 按配置的数据类型转换为 SeekMind Engine 样本流输出。它常用于接收外部程序、网络设备或另一个 SeekMind Engine 样本流图发送的实时样本。

UDP Source 不知道发送端的真实数据类型，所有解释都由本模块参数决定。因此发送端和接收端必须在类型、Header、Payload Size 和向量长度上保持一致。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Networking Tools（网络工具） |
| Block ID | `network_udp_source` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | 平台内置 |

## 何时使用

1. **网络输入**  
   从 UDP 数据包恢复为流式样本

2. **跨进程接收**  
   与外部采集、仿真或转发程序对接

3. **远程数据接入**  
   从另一台主机接收实时样本

4. **网络链路测试**  
   使用序列号 Header 检测丢包或乱序

5. **外部设备接口**  
   接收支持 UDP 输出的采集设备或嵌入式系统数据

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | Input Type × Vector Length | 连续样本流端口 |

> 发送端与接收端必须就地址、端口、连接角色、数据类型和消息格式达成一致；跨主机使用前先验证网络可达性。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Input Type** | 枚举 | 输出流类型：complex、float、int、short、byte | float |
| **Port** | 整数 | 本地监听 UDP 端口 | 1234 |
| **Header** | 枚举 | 包头格式：None、64-bit Sequence Number、Sequence + data size、ATA Header | None |
| **UDP Packet Data Size** | 整数 | 单个 UDP 包 payload 字节数 | 1472 |
| **Notify Missed Frames** | 枚举 | 是否提示丢帧 | No |
| **Src 0s If No Data** | 枚举 | 无数据时是否输出 0 | No |
| **Enable IPv6 Support** | 枚举 | 是否启用 IPv6 | No |
| **Vector Length** | 整数 | 输出向量长度 | 1 |

## 参数说明

**1. Input Type（输出类型）**
- 名称在块定义中为 Input Type，但实际决定输出 stream 类型
- 必须与发送端发送的样本类型一致
- complex 通常按复数 float32 IQ 样本解释

**2. Port（监听端口）**
- 本地 UDP 端口
- 发送端的 Destination Port 必须指向此端口
- 若端口被其他程序占用，模块无法正常监听

**3. Header（包头）**
- 必须与发送端 UDP Sink 的 Header 设置一致
- 序列号 Header 可用于检测丢包
- Header 设置错误会导致 payload 解析偏移

**4. UDP Packet Data Size（UDP 包数据大小）**
- 应与发送端设置匹配
- 标准 MTU 1500 网络中，1472 是常见 payload 大小
- 过大可能导致分片，过小会增加包数量和协议开销

**5. Notify Missed Frames（提示丢帧）**
- 在使用支持序列号的 Header 时，可提示缺失帧
- 如果 Header=None，通常无法可靠判断丢包

**6. Src 0s If No Data（无数据输出 0）**
- Yes：没有 UDP 数据时输出 0，保持下游继续运行
- No：没有数据时不产生样本
- 块定义文档提示：该模式最好与配套 UDP Sink 使用；外部发送程序若发送包大小不匹配，可能产生部分包相关问题

**7. Enable IPv6 Support（IPv6 支持）**
- Yes：启用 IPv6 支持
- 网络栈和发送端地址也必须支持 IPv6

**8. Vector Length（向量长度）**
- 输出流项目的向量长度
- 需要与下游模块期望一致
- 与发送端 vlen 不一致会造成数据组织错误

## 工作原理

```
UDP socket 监听端口 → 接收 packet → 解析 Header → 按类型输出 stream
```

模块不负责可靠传输，也不自动修复丢包。若使用序列号 Header，可以检测到包序列中的缺口。

## 快速示例

**示例 1：本机接收测试**

发送端：

```
[Signal Source] → [Throttle] → [UDP Sink]
```

接收端：

```
[UDP Source] → [QT GUI Time Sink]
```

两端设置：
- Type: float
- Header: None
- Payload Size: 1472
- Vector Length: 1

**示例 2：接收复数 IQ**

```
[UDP Source] → [QT GUI Frequency Sink]
 complex
```

发送端需要按 complex float32 布局发送 IQ 数据。

**示例 3：丢包检测**

```
[UDP Source] → [Processing]
 Header = 64-bit Sequence Number
 Notify Missed Frames = Yes
```

## 配置检查清单

| 检查项 | 要求 |
|--------|------|
| Port | 与发送端 Destination Port 对应 |
| Input Type | 与发送端类型一致 |
| Header | 与发送端 Header 一致 |
| Payload Size | 与发送端一致 |
| Vector Length | 与发送端和下游一致 |
| IPv6 | 发送端、接收端和系统栈一致 |

## 性能与部署

1. **socket buffer 影响丢包**  
   高速 UDP 接收时，操作系统接收缓冲区过小会造成丢包。块定义文档建议高吞吐场景关注 rmem/wmem 系统参数。

2. **下游处理速度要足够**  
   如果 GUI、文件写入或算法处理跟不上，接收数据会积压或丢失。

3. **Payload Size 影响包率**  
   payload 越小，每秒包数越多，CPU 和网络协议开销越大。

4. **输出 0 模式要谨慎**  
   Src 0s If No Data 可保持下游运行，但可能掩盖网络中断。

## 故障排查

**Q1: 为什么收不到数据？**  
A: 检查端口、防火墙、发送端目标 IP、IPv4/IPv6 设置，以及端口是否被占用。

**Q2: 为什么数据幅度或波形不对？**  
A: 多半是类型、Header 或字节布局不一致。先用 byte 类型或简单已知序列测试。

**Q3: Notify Missed Frames 必须开启吗？**  
A: 不必须。需要检测丢包时建议配合序列号 Header 开启。

**Q4: 可以多个 UDP Source 监听同一端口吗？**  
A: 通常不行，除非操作系统和 socket 选项支持端口复用。

**Q5: UDP Source 会自动按采样率输出吗？**  
A: 它按收到的数据输出，不产生精确采样时钟。实时速率由发送端和网络决定。

## 典型应用场景

**远程接收显示：**

```
远端 [UDP Sink] → 本机 [UDP Source] → [QT GUI Sink]
```

**外部设备接入：**

```
[UDP Source] → [Low Pass Filter] → [Demodulator]
```

**网络测试：**

```
[UDP Source] → [Tag/Sequence Debug] → [Null Sink]
```

## 相关 Block

- [UDP Sink](UDP_Sink.md)：UDP 数据发送
- [ZMQ SUB Source](ZeroMQ_Sub_Source.md)：ZeroMQ 流订阅
- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：时域观察
- [Null Sink](Null_Sink.md)：吞吐测试

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
