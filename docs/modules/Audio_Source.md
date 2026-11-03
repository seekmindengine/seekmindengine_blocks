# Audio Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Audio Source

## 概览

Audio Source 模块用于从音频设备（麦克风、线路输入等）采集音频数据。它从指定的音频设备创建一个源，以指定的采样率捕获音频信号。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Audio（音频） |
| Block ID | `audio_source` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ / 设备时钟限速 |

## 何时使用

1. **音频采集**  
   从麦克风或线路输入采集音频信号

2. **语音处理**  
   实时语音识别、分析或处理

3. **实验激励输入**  
   将音频测试信号接入处理或播放实验链路

4. **声音监测**  
   环境声音监测和分析

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | `float` | 连续样本流端口；端口数量由参数决定 |

> 采样率、通道数和设备名称必须得到音频设备支持。实时播放或采集时避免在同一路径加入额外速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Sample Rate** | 整数 | 设置采样率，单位为 Sps | 32000 | ✗ |
| **Device Name** | 字符串 | 设置要打开的设备名称或系统标识 |  | ✗ |
| **OK to Block** | 枚举 | 控制缓冲区满时是否允许阻塞等待 | Yes | ✗ |
| **Num Outputs** | 整数 | 设置输出端口数量 | 1 | ✗ |

## 参数说明

**1. Sample Rate**
- 采样率（Hz）

**2. Device Name**
- 目标音频设备标识；留空时使用系统默认设备。
**3. OK to Block**
- 允许音频 I/O 在设备暂时无法及时处理时阻塞流程。
  - **Yes**：True
  - **No**：False

**4. Num Outputs**
- 输出数量

## 工作原理

```
麦克风 → 音频设备 → 音频缓冲区 → 格式转换 → 输出流
        (硬件)                    (Float)
```

**数据流程：**
1. 音频硬件按采样率采集数据
2. 数据存入音频设备缓冲区
3. 模块从缓冲区读取数据
4. 转换为浮点格式（-1.0 到 +1.0）
5. 输出到 SeekMind Engine 处理流程

## 快速示例

**示例 1：录制音频到文件**

```
[Audio Source] → [Wav File Sink]
  (48kHz)         (48kHz)
```

配置参数：
- Sample Rate: 48000
- Device Name: ""
- OK to Block: True
- Num Outputs: 1

**示例 2：实时音频处理**

```
[Audio Source] → [Low Pass Filter] → [Audio Sink]
  (48kHz)         (4kHz cutoff)       (48kHz)
```

配置参数：
- Sample Rate: 48000
- Device Name: ""
- OK to Block: True

**示例 3：实验信号输出链路**

```
[Audio Source] → [Rational Resampler] → [Test Processing] → [Output Device]
  (48kHz)         (48k→192k)            (实验链路)          (输出)
```

配置参数：
- Sample Rate: 48000
- Num Outputs: 1

**示例 4：立体声采集**

```
[Audio Source] → [File Sink]
  (stereo)         (left channel)
       ↓
  [File Sink]
  (right channel)
```

配置参数：
- Sample Rate: 48000
- Num Outputs: 2  (立体声)

## 音频数据格式

**输出数据格式：**
- 类型：Float (32位浮点)
- 范围：-1.0 到 +1.0
- 单声道：一个输出流
- 立体声：两个独立的输出流

**幅度特性：**
- 静音时输出接近 0.0
- 最大音量时接近 ±1.0
- 实际幅度取决于输入增益设置

## 性能与部署

1. **缓冲区大小**  
   音频设备有内部缓冲区，影响延迟和稳定性

2. **采样率匹配**  
   确保设备支持所选采样率，否则可能失败

3. **实时性要求**  
   音频采集是实时操作，流图必须能够及时处理数据

4. **设备独占**  
   某些系统上，音频设备同时只能被一个应用使用

## 故障排查

**Q1: 为什么没有音频输入？**  
A: 检查：
- 麦克风是否正确连接
- 系统输入音量是否打开
- 设备是否被其他程序占用
- Device Name 是否正确

**Q2: 如何调整输入音量？**  
A: 使用系统音频设置调整输入增益，或在流图中使用 Multiply Const 模块。

**Q3: 为什么音频有延迟？**  
A: 音频采集有固有的缓冲延迟，通常几十毫秒。这是正常的。

**Q4: 如何查看可用的音频设备？**  
A: 
- Linux: `arecord -l` 或 `arecord -L`
- macOS: 系统偏好设置 → 声音
- Windows: 控制面板 → 声音

**Q5: 立体声输入如何使用？**  
A: 设置 Num Outputs=2，模块会有两个输出端口，分别对应左右声道。

## 系统配置

**Linux (ALSA):**
```bash
# 查看音频输入设备
arecord -l
arecord -L

# 测试音频输入
arecord -f cd -d 5 test.wav
aplay test.wav

# 调整输入音量
alsamixer
```

**macOS:**
```bash
# 使用系统偏好设置
# 系统偏好设置 → 声音 → 输入
```

**Windows:**
- 控制面板 → 声音 → 录制
- 右键点击麦克风 → 属性 → 级别

## 典型应用场景

**语音处理实验：**
```
[Audio Source] → [处理链路] → [Output Device]
```

**音频分析：**
```
[Audio Source] → [QT GUI Frequency Sink]
```

**回声测试：**
```
[Audio Source] → [Delay] → [Audio Sink]
```

**音频录制：**
```
[Audio Source] → [Wav File Sink]
```

## 相关 Block

- [Audio Sink](Audio_Sink.md)：音频输出到设备
- [Wav File Source](Wav_File_Source.md)：从 WAV 文件读取音频
- [Rational Resampler](Rational_Resampler.md)：采样率转换
- **Multiply Const**：调整音频幅度

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
