# Signal Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Signal Source

## 概览

Signal Source 模块是一个通用的信号发生器，可以生成多种类型的波形，包括正弦波、余弦波、方波、三角波、锯齿波和常数，适用于实验激励、流程验证和算法调试。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_sig_source_x` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **测试信号生成**  
   为信号处理链提供已知的测试信号

2. **激励信号生成**  
   生成测试或主动声学实验所需的激励信号

3. **本地振荡器**  
   提供混频所需的本振信号

4. **仿真环境**  
   在无硬件的情况下模拟信号源

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `cmd` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 先核对输出类型与数据含义；离线处理可尽快运行，需要近似实时显示时再配置速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Output Type** | 枚举 | 选择输出端样本类型 | float | ✗ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Waveform** | 原始 | 选择信号源波形 | Cosine | ✓ |
| **Frequency** | 浮点数 | 设置输出或处理频率，单位为 Hz | 1000 | ✓ |
| **Amplitude** | 浮点数 | 设置输出幅度 | 1 | ✓ |
| **Offset** | 类型相关 | 设置叠加到输出的直流偏置 | 0 | ✓ |
| **Initial Phase (Radians)** | 浮点数 | 设置初始相位，单位为弧度 | 0 | ✓ |
| **Show Msg Ports** | 枚举 | 控制是否显示运行时控制消息端口 | No | ✗ |

## 参数说明

**1. Output Type**
- 输出数据类型
  - complex
  - float
  - int
  - short
  - byte

**2. Sample Rate**
- 采样率（Hz）

**3. Waveform**
- 波形类型
  - **Constant**：analog.GR_CONST_WAVE
  - **Sine**：analog.GR_SIN_WAVE
  - **Cosine**：analog.GR_COS_WAVE
  - **Square**：analog.GR_SQR_WAVE
  - **Triangle**：analog.GR_TRI_WAVE
  - **Saw Tooth**：analog.GR_SAW_WAVE

**4. Frequency**
- 频率（Hz）

**5. Amplitude**
- 信号幅度

**6. Offset**
- 直流偏移

**7. Initial Phase (Radians)**
- 初始相位，单位为弧度。
**8. Show Msg Ports**
- 是否显示消息端口
  - **Yes**：True
  - **No**：False

## 工作原理

Signal Source 根据数学公式生成波形：

**余弦波：**
```
output(t) = Amplitude × cos(2π × Frequency × t + Phase) + Offset
```

**复数输出（Complex）：**
```
output(t) = Amplitude × [cos(2π × Frequency × t + Phase)
                         + j sin(2π × Frequency × t + Phase)] + Offset
```

对复数类型，Offset 本身可以是复数。当前集成实现中 Complex 的 Sine 和 Cosine 选项都使用复数正交输出；其他波形的复数 I/Q 细节以产品集成版本为准。

## 快速示例

**示例 1：生成 1 kHz 正弦波**

```
[Signal Source] → [Throttle] → [QT GUI Time Sink]
  (1kHz sine)     (32k sps)
```

配置参数：
- Output Type: Float
- Sample Rate: 32000
- Waveform: Sine
- Frequency: 1000
- Amplitude: 1
- Offset: 0
- Phase: 0

**示例 2：生成复数测试信号**

```
[Signal Source] → [Throttle] → [QT GUI Frequency Sink]
  (10kHz complex)      (48k)
```

配置参数：
- Output Type: Complex
- Sample Rate: 48000
- Waveform: Cosine
- Frequency: 10000
- Amplitude: 1

**示例 3：生成带偏移的方波**

```
[Signal Source] → [Throttle] → [QT GUI Time Sink]
  (square)
```

配置参数：
- Output Type: Float
- Sample Rate: 32000
- Waveform: Square
- Frequency: 100
- Amplitude: 2
- Offset: 2.5  (输出范围 0.5 到 4.5)

## 波形特性

| 波形类型 | 频谱特性 | 典型应用 |
|---------|---------|---------|
| Cosine/Sine | 单一频率分量 | 激励、测试信号 |
| Square | 奇次谐波丰富 | 数字信号、时钟 |
| Triangle | 奇次谐波衰减快 | 音频合成 |
| Saw Tooth | 所有谐波 | 音频合成、扫频 |
| Constant | 直流分量 | 偏置、参考电平 |

## 性能与部署

- 纯软件 Source 会按调度器允许的速度产生样本；需要近似实时观察时可在流程中加入 Throttle
- Frequency 由内部 NCO 的相位增量实现，不要求是 `Sample Rate / N` 的整数倍
- 数值精度、相位累积和波形细节以产品集成版本的 `sig_source` 实现为准

## 故障排查

**Q1: 为什么看不到输出波形？**  
A: 先检查流程错误、端口类型和 GUI 配置。Throttle 只用于限制纯软件流程的平均执行速率；缺少 Throttle 通常导致流程尽快运行，而不是 Signal Source 不产生数据。

**Q2: Complex 输出和 Float 输出有什么区别？**  
A: Complex 输出包含 I 和 Q 两个分量，可以表示正负频率；Float 只有实部。

**Q3: 如何生成多个不同频率的信号？**  
A: 使用多个 Signal Source 模块，然后用 Add 模块相加。

**Q4: 可以动态改变频率吗？**  
A: 可以，通过消息端口发送频率更新消息，或使用 VCO（压控振荡器）模块。

**Q5: 为什么频谱中出现镜像频率？**  
A: 使用 Float 输出时会出现正负频率镜像，使用 Complex 输出可避免。

## 相关 Block

- [Noise Source](Noise_Source.md)：生成噪声信号
- [Constant Source](Constant_Source.md)：生成常数值
- **VCO**：压控振荡器，频率可变
- [Throttle](Throttle.md)：控制信号生成速率

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
