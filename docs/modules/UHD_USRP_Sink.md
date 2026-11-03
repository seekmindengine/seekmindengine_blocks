# UHD: USRP Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / UHD: USRP Sink

## 概览

UHD: USRP Sink 模块通过 UHD 驱动连接 USRP 设备，把 SeekMind Engine 样本流 发送到射频前端进行发射。它是 SDR 发射链路的硬件出口，负责配置发射采样率、中心频率、增益、天线、带宽、时钟源和多通道参数。

使用发射模块时必须确认频率、功率、天线连接和当地无线电规定。文档只说明模块使用方法，不代表任何发射许可。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | UHD（硬件接口） |
| Block ID | `uhd_usrp_sink` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ / 设备时钟限速 |

## 何时使用

1. **射频发射**  
   将复数基带信号送入 USRP 上变频发射

2. **数字调制发射**  
   发送 PSK、GMSK、CPM 等调制信号

3. **多通道发射**  
   支持多个输入流对应多个发射通道

4. **硬件同步发射**  
   配置外部时钟、PPS、GPSDO 或定时启动

5. **闭环测试**  
   与 USRP Source 或频谱仪配合验证收发链路

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `command` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口；端口数量由参数决定 |
| 输出 | `async_msgs` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 采样率、中心频率、增益、天线及时钟源受具体设备能力约束。首次连接应从低采样率和保守增益开始。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Input Type** | 枚举 | 输入类型：fc32、sc16、item32 | fc32 |
| **Wire Format** | 枚举 | 线上传输格式：自动、sc16、sc12、sc8 | Automatic |
| **Stream args** | 字符串 | UHD stream_args 附加参数 | "" |
| **Stream channels** | int_vector | 指定硬件发射通道 | [] |
| **Device Address** | 字符串 | UHD 设备地址 | "" |
| **Device Arguments** | 字符串 | 设备附加参数 | "" |
| **Sync** | 枚举 | 同步方式 | Unknown PPS |
| **Start Time (seconds)** | 浮点数 | 定时发射时间；负值表示默认 | -1 |
| **Clock Rate (Hz)** | 浮点数 | 主时钟率，0 表示默认 | 0 |
| **Num Mboards** | 整数 | 主板数量 | 1 |
| **Num Channels** | 整数 | 发射通道数量 | 1 |
| **Samp rate (Sps)** | 浮点数 | 发射采样率 | 32000 |
| **MbX: Clock Source** | 字符串 | 各主板参考时钟来源 | 空，设备默认 |
| **MbX: Time Source** | 字符串 | 各主板时间参考来源 | 空，设备默认 |
| **MbX: Subdev Spec** | 字符串 | 各主板子设备映射 | 空，设备默认 |
| **ChX: Center Freq (Hz)** | 浮点数 | 各通道中心频率 | 0 |
| **ChX: Gain Value** | 浮点数 | 各通道增益值，单位由 Gain Type 决定 | 0 |
| **ChX: Gain Type** | 枚举 | 增益模式 | default |
| **ChX: Antenna** | 字符串 | 天线端口，必须由设备支持 | TX/RX |
| **ChX: Bandwidth (Hz)** | 浮点数 | 模拟前端带宽，0 表示设备默认 | 0 |
| **ChX: LO Source** | 字符串 | 本振来源 | internal |
| **ChX: LO Export** | 枚举 | 是否导出本振 | False |
| **Show LO Controls** | 枚举 | 显示本振相关设置 | False |
| **TSB tag name** | 字符串 | 带长度标签的突发发送所使用的键；空表示不启用此模式 | 空 |

MbX 表示定义中 Mb0..Mb7 的重复字段，ChX 表示 Ch0..Ch31 的重复字段；实际显示由主板数和通道数决定，硬件能力可能更少。

## 参数说明

**1. Input Type（输入类型）**
- fc32：复数 float32，最常用
- sc16：复数 int16，可降低主机到设备传输压力
- item32：特殊底层数据格式，普通发射链路较少使用

**2. Samp rate（采样率）**
- 必须与上游信号实际采样率一致
- 调制器、重采样器和滤波器应围绕该采样率设计
- 过高采样率可能导致 underrun

**3. Center Freq（中心频率）**
- 真正设置硬件发射频率
- 必须在设备和许可范围内
- 若只想在基带移动频率，可使用 Frequency Shift，但最终仍由此参数决定射频中心

**4. Gain（发射增益）**
- 控制发射链路输出幅度
- 建议从较低增益开始逐步增加
- 过高可能导致失真、频谱扩展或超出许可功率

**5. Antenna（天线端口）**
- 默认常见为 TX/RX
- 实际端口名称取决于设备型号和子板
- 发射前确认端口接了合适负载或天线

**6. Clock/Time Source（时钟和时间源）**
- 多设备或 MIMO 场景需要统一时钟和时间参考
- 外部参考设置错误可能导致设备无法锁定或频率漂移

## 端口说明

- **样本流输入**：每个发射通道一路输入
- **command 消息输入**：可用于运行时控制频率、增益等参数
- **async_msgs 消息输出**：输出 UHD 异步状态消息

## 工作原理

Block 按设备时钟持续消费上游基带样本，经 UHD 传送到射频前端完成数模转换、上变频和发射。上游必须以足够稳定的速率供数；当处理链或主机总线无法及时提供样本时，设备会报告欠载（underrun），射频输出也可能出现中断。

## 快速示例

**示例 1：发送调制信号**

```
[Random Source] → [GMSK Mod] → [UHD: USRP Sink]
```

配置要点：
- GMSK Mod 输出采样率与 USRP Sink Samp rate 匹配
- UHD 输入类型通常为 fc32
- 发射前先用 QT GUI Sink 检查频谱

**示例 2：播放文件 IQ**

```
[File Source] → [Throttle/Resampler] → [UHD: USRP Sink]
```

如果文件源本身没有硬件时钟，应确保上游供数速度能匹配 USRP Sink。实际硬件 Sink 会按采样率消费数据。

**示例 3：多通道发射**

```
[Signal 0] ─┐
            ├→ [UHD: USRP Sink]
[Signal 1] ─┘
```

配置要点：
- Num Channels 与输入端口数一致
- Stream channels 对应硬件通道
- 分别配置 Ch0/Ch1 的频率、增益、天线等

## 发射前检查清单

1. 频率是否合法、是否在设备支持范围内
2. 发射增益是否从低值开始
3. 天线/负载是否连接正确
4. 采样率是否与上游信号匹配
5. 频谱是否经过滤波，带外发射是否可控
6. 是否需要外部时钟或时间同步
7. 终端是否出现 underrun 或异步错误

## 性能与部署

硬件时钟决定实时节奏。出现溢出或欠载时，先降低采样率并缩短处理链，确认主机与接口吞吐余量。

## 故障排查

**Q1: 为什么出现 underrun？**  
A: 上游供数不足、CPU 负载过高、采样率过高或传输链路带宽不足都会导致 underrun。

**Q2: 可以直接发 float 音频吗？**  
A: 通常不可以。USRP Sink 主要接收复数基带 IQ 信号。音频需要先调制或转换到复数基带。

**Q3: Gain 越大越好吗？**  
A: 不是。过大可能造成失真和带外扩展，也可能违反发射限制。

**Q4: Sink 会自动滤波吗？**  
A: 它负责发射和硬件配置，不替代数字滤波。发射前应根据带宽需求设计滤波器。

**Q5: 如何确认实际发射频谱？**  
A: 先在基带用 QT GUI Frequency Sink 查看，再用频谱仪或接收机观察射频输出。

## 相关 Block

- [UHD: USRP Source](UHD_USRP_Source.md)：USRP 接收
- [GMSK Mod](GMSK_Mod.md)：数字调制
- [PSK Mod](PSK_Mod.md)：PSK 调制
- [QT GUI Sink](QT_GUI_Sink.md)：发射前观察
- [Low Pass Filter](Low_Pass_Filter.md)：带宽限制

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
