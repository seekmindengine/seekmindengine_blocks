# UHD: USRP Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / UHD: USRP Source

## 概览

UHD: USRP Source 模块通过 UHD 驱动连接 Ettus/NI USRP 设备，将射频接收数据输出为 SeekMind Engine 样本流。它是 SDR 接收链路的硬件入口，负责配置采样率、中心频率、增益、天线、带宽、时钟源和多通道参数。

与纯软件 Source 不同，USRP Source 由硬件采样时钟驱动，通常不需要 Throttle。采样率和时间同步应以硬件能力和 UHD 配置为准。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | UHD（硬件接口） |
| Block ID | `uhd_usrp_source` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ / 设备时钟限速 |

## 何时使用

1. **射频采集**  
   从 USRP 接收复数基带 IQ 样本

2. **实时频谱监视**  
   配合 QT GUI Frequency/Waterfall Sink 观察频谱

3. **数字接收机前端**  
   为滤波、同步、解调模块提供硬件采样数据

4. **多通道接收**  
   支持多个接收通道和多主板配置

5. **硬件同步**  
   配置外部时钟、PPS、GPSDO 或多板同步

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `command` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口；端口数量由参数决定 |
| 输出 | `async_msgs` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 采样率、中心频率、增益、天线及时钟源受具体设备能力约束。首次连接应从低采样率和保守增益开始。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Output Type** | 枚举 | 输出类型：fc32、sc16、item32 | fc32 |
| **Wire Format** | 枚举 | 线上传输格式：自动、sc16、sc12、sc8 | Automatic |
| **Stream args** | 字符串 | UHD stream_args 附加参数 | "" |
| **Stream channels** | int_vector | 指定硬件通道序号 | [] |
| **Device Address** | 字符串 | UHD 设备地址 | "" |
| **Device Arguments** | 字符串 | 设备附加参数 | "" |
| **Sync** | 枚举 | 启动同步方式 | Unknown PPS |
| **Start Time (seconds)** | 浮点数 | 定时启动时间；负值表示默认 | -1 |
| **Clock Rate (Hz)** | 浮点数 | 主时钟率，0 表示默认 | 0 |
| **Num Mboards** | 整数 | 主板数量 | 1 |
| **Num Channels** | 整数 | 接收通道数量 | 1 |
| **Samp rate (Sps)** | 浮点数 | 接收采样率 | 32000 |
| **MbX: Clock Source** | 字符串 | 各主板参考时钟来源 | 空，设备默认 |
| **MbX: Time Source** | 字符串 | 各主板时间参考来源 | 空，设备默认 |
| **MbX: Subdev Spec** | 字符串 | 各主板子设备映射 | 空，设备默认 |
| **ChX: Center Freq (Hz)** | 浮点数 | 各通道中心频率 | 0 |
| **ChX: AGC** | 枚举 | 各通道自动增益控制 | Default |
| **ChX: Gain Value** | 浮点数 | 各通道增益值，单位由 Gain Type 决定 | 0 |
| **ChX: Gain Type** | 枚举 | 增益模式 | default |
| **ChX: Antenna** | 字符串 | 天线端口，必须由设备支持 | RX2 |
| **ChX: Bandwidth (Hz)** | 浮点数 | 模拟前端带宽，0 表示设备默认 | 0 |
| **ChX: LO Source** | 字符串 | 本振来源 | internal |
| **ChX: LO Export** | 枚举 | 是否导出本振 | False |
| **ChX: Enable DC Offset Correction** | 枚举 | 直流偏置校正方式 | default |
| **ChX: DC Offset Correction Value** | 复数 | 手动直流校正值 | 0+0j |
| **ChX: Enable IQ Imbalance Correction** | 枚举 | IQ 不平衡校正方式 | default |
| **ChX: IQ imbalance Correction Value** | 复数 | 手动 IQ 校正值 | 0+0j |
| **Show LO Controls** | 枚举 | 显示本振相关设置 | False |

MbX 表示定义中 Mb0..Mb7 的重复字段，ChX 表示 Ch0..Ch31 的重复字段；实际显示由主板数和通道数决定，硬件能力可能更少。

## 参数说明

**1. Output Type（输出类型）**
- fc32：复数 float32，最常用，便于后续信号处理
- sc16：复数 int16，可减少主机传输带宽
- item32：VITA word32，通常用于特殊底层场景

**2. Wire Format（线上格式）**
- 控制设备到主机之间的传输格式
- 自动模式由 UHD 根据设备和流参数选择
- sc8/sc12/sc16 可影响带宽、动态范围和主机处理压力

**3. Device Address（设备地址）**
- 用于选择具体 USRP
- 网口设备常见写法如 `addr=192.168.10.2`
- USB 或本机唯一设备可保持默认，让 UHD 自动发现

**4. Samp rate（采样率）**
- 由硬件支持范围决定
- 下游滤波器、GUI Bandwidth、符号率计算应与该值一致
- 采样率过高可能造成 overflow 或主机处理不过来

**5. Center Freq（中心频率）**
- 设置射频调谐频率
- 每个通道可独立配置，但具体能力取决于硬件
- 与 QT GUI Sink 的 Center Frequency 只是显示标注不同，此处会真正调谐硬件

**6. Gain / AGC（增益）**
- AGC 可由硬件自动控制，若设备支持
- 手动 Gain Value 便于可重复测试
- 增益过高会削顶，过低会降低信噪比

**7. Antenna（天线）**
- 典型接收端口如 RX2、TX/RX，实际取决于设备型号
- 端口选错时可能几乎收不到信号

**8. Clock/Time Source（时钟和时间源）**
- internal：使用设备内部时钟
- external：使用外部参考
- gpsdo：使用板载 GPSDO
- mimo：部分设备支持 MIMO cable 同步

## 端口说明

- **样本流输出**：每个通道一路输出，类型由 Output Type 决定
- **command 消息输入**：可用于运行时控制频率、增益等参数
- **async_msgs 消息输出**：输出 UHD 异步状态消息

## 工作原理

Block 通过 UHD 打开并配置设备，将射频前端下变频后的基带样本按设定采样率送入流程。设备时钟决定真实数据节奏；当主机、总线或下游处理速度不足时，硬件缓冲可能溢出并造成样本不连续。多通道模式还要求通道映射、时钟源和启动时间保持一致。

## 快速示例

**示例 1：基本频谱监视**

```
[UHD: USRP Source] → [QT GUI Frequency Sink]
```

配置参数：
- Output Type: fc32
- Samp rate: 1e6
- Center Freq: 100e6
- Gain: 根据实际信号调整

**示例 2：接收机前端**

```
[UHD: USRP Source] → [Low Pass Filter] → [Quadrature Demod] → [Audio Sink]
```

适用于 FM 等模拟调制实验，滤波器采样率应与 USRP 输出采样率一致。

**示例 3：多通道接收**

```
[UHD: USRP Source] ┬→ [Channel 0 Processing]
                   └→ [Channel 1 Processing]
```

配置要点：
- Num Channels: 2
- Stream channels 与硬件通道对应
- 分别设置 Ch0/Ch1 的频率、增益、天线等参数

## 调试建议

1. 先用低采样率和 QT GUI Frequency Sink 验证设备连通
2. 确认 Device Address 能被 UHD 找到
3. 设置正确天线端口
4. 从较低增益开始，避免前端饱和
5. 观察终端是否有 overflow、timeout 或 clock 错误
6. 多设备同步前，先单设备跑通

## 性能与部署

硬件时钟决定实时节奏。出现溢出或欠载时，先降低采样率并缩短处理链，确认主机与接口吞吐余量。

## 故障排查

**Q1: 为什么不需要 Throttle？**  
A: USRP Source 由硬件采样时钟限速，不是无限速的软件源。

**Q2: 为什么看到 overflow？**  
A: 主机或下游处理跟不上采样率，或传输链路带宽不足。降低采样率、减少 GUI 开销或优化处理链路。

**Q3: Device Address 留空可以吗？**  
A: 只有在 UHD 能唯一发现设备时可以。多设备或网口设备建议明确填写。

**Q4: fc32 和 sc16 怎么选？**  
A: fc32 最方便；sc16 可减少带宽但需要确认后续模块和精度需求。

**Q5: Center Freq 设置后为何频谱轴还是不对？**  
A: GUI 模块的 Center Frequency 只是显示参数，需要同步设置为同一频率。

## 相关 Block

- [UHD: USRP Sink](UHD_USRP_Sink.md)：USRP 发射
- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：频谱监视
- [Low Pass Filter](Low_Pass_Filter.md)：接收滤波
- [File Sink](File_Sink.md)：采集保存

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
