# Audio Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Audio Sink

## 概览

Audio Sink 模块用于将数据流输出到音频设备（扬声器、耳机等）进行播放。它以指定的采样率将音频数据送入所选输出设备。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Audio（音频） |
| Block ID | `audio_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ / 设备时钟限速 |

## 何时使用

1. **音频播放**  
   播放采集或处理后的音频信号

2. **实时监听**  
   实时监听采集或处理后的声学信号

3. **音频测试**  
   测试音频信号处理算法的效果

4. **声音反馈**  
   为用户提供听觉反馈

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `float` | 连续样本流端口；端口数量由参数决定 |

> 采样率、通道数和设备名称必须得到音频设备支持。实时播放或采集时避免在同一路径加入额外速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Sample Rate** | 整数 | 设置采样率，单位为 Sps | 32000 | ✗ |
| **Device Name** | 字符串 | 设置要打开的设备名称或系统标识 |  | ✗ |
| **OK to Block** | 枚举 | 控制缓冲区满时是否允许阻塞等待 | Yes | ✗ |
| **Num Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |

## 参数说明

**1. Sample Rate**
- 采样率（Hz）

**2. Device Name**
- 目标音频设备标识；留空时使用系统默认设备。
**3. OK to Block**
- 允许音频 I/O 在设备暂时无法及时处理时阻塞流程。
  - **Yes**：True
  - **No**：False

**4. Num Inputs**
- 输入数量

## 工作原理

```
输入流 → 格式转换 → 音频缓冲区 → 音频设备 → 扬声器
         (Float)                    (硬件)
```

**数据流程：**
1. 接收浮点数据流（范围通常 -1.0 到 +1.0）
2. 转换为音频设备所需的格式
3. 写入音频设备的缓冲区
4. 音频硬件按采样率播放

## 快速示例

**示例 1：播放音频文件**

```
[Wav File Source] → [Audio Sink]
  (48kHz)            (48kHz)
```

配置参数：
- Sample Rate: 48000
- Device Name: ""
- OK to Block: True
- Num Inputs: 1

**示例 2：目标声提取结果输出**

```
[Microphone Source] → [Signal Processing] → [Rational Resampler] → [Audio Sink]
  (192kHz)           (目标声提取)       (192k→48k)            (48kHz)
```

配置参数：
- Sample Rate: 48000
- Device Name: ""
- OK to Block: True

**示例 3：立体声输出**

```
[Signal Source] → [Audio Sink]
  (left)            (stereo)
[Signal Source] →     ↑
  (right)
```

配置参数：
- Sample Rate: 48000
- Num Inputs: 2  (立体声)

## 音频数据格式

**输入数据要求：**
- 类型：Float (32位浮点)
- 范围：-1.0 到 +1.0（推荐）
- 超出范围的值会被裁剪（clipping），导致失真

**幅度控制：**
```text
# 如果信号幅度过大，使用 Multiply Const 调整
信号 → [Multiply Const (0.5)] → [Audio Sink]
```

## 性能与部署

1. **缓冲区大小**  
   音频设备有内部缓冲区，通常几十到几百毫秒

2. **延迟**  
   音频播放有固有延迟（缓冲区大小决定）

3. **采样率转换**  
   如果信号采样率与音频设备不匹配，需要重采样

4. **CPU 负载**  
   音频播放是实时操作，需要保证足够的 CPU 资源

## 故障排查

**Q1: 为什么听到的声音断断续续？**  
A: CPU 负载过高或数据流速率不稳定。检查流图性能，可能需要优化。

**Q2: 为什么没有声音输出？**  
A: 检查：
- 音频设备是否正确连接
- 系统音量是否打开
- 采样率是否匹配
- 输入数据幅度是否合适

**Q3: 如何选择合适的采样率？**  
A: 48000 Hz 是最通用的选择，大多数音频设备都支持。

**Q4: 输入数据超出 [-1, 1] 范围会怎样？**  
A: 会被裁剪，导致音频失真（削波失真）。使用 Multiply Const 调整幅度。

**Q5: 如何指定特定的音频设备？**  
A: 在 Linux 上使用 `aplay -L` 查看设备列表，然后设置 Device Name。

## 系统配置

**Linux (ALSA):**
```bash
# 查看音频设备
aplay -l
aplay -L

# 测试音频设备
speaker-test -c 2 -r 48000
```

**macOS:**
- 使用系统偏好设置查看音频设备
- 默认设备通常工作良好

**Windows:**
- 使用设备管理器查看音频设备
- 默认设备通常工作良好

## 相关 Block

- [Audio Source](Audio_Source.md)：从音频设备采集数据
- [Wav File Sink](Wav_File_Sink.md)：保存音频到 WAV 文件
- [Rational Resampler](Rational_Resampler.md)：采样率转换
- **Multiply Const**：调整音频幅度

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
