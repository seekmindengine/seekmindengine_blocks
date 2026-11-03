# SeekMind Engine 快速入门

[文档首页](../README.md) / 快速入门

本教程使用纯软件信号源构建一条便于观察的流图。Throttle 在这里用于让 GUI 近似实时刷新；它不是所有纯软件流程的必需 Block。

## 准备工作

需要以下 Block：

- [Signal Source](modules/Signal_Source.md)
- [Throttle](modules/Throttle.md)
- [QT GUI Time Sink](modules/QT_GUI_Time_Sink.md)
- [QT GUI Frequency Sink](modules/QT_GUI_Frequency_Sink.md)
- [Low Pass Filter](modules/Low_Pass_Filter.md)，用于后续实验

## 1. 创建基本流程

```text
                         +-> [QT GUI Time Sink]
[Signal Source] -> [Throttle]
                         +-> [QT GUI Frequency Sink]
```

Signal Source 会按调度器允许的速度产生样本。教程加入 Throttle，把平均 item 率限制在约 32 kitem/s，避免这个可视化示例无意义地占满一个 CPU 核。离线批处理若希望尽快完成，可以不加 Throttle。

### Signal Source

| 参数 | 值 |
|---|---|
| Output Type | `float` |
| Sample Rate | `32000` |
| Waveform | `Sine` |
| Frequency | `1000` |
| Amplitude | `0.8` |
| Offset | `0` |

### Throttle

| 参数 | 值 |
|---|---|
| Type | `float` |
| Sample Rate | `32000` |
| Vector Length | `1` |
| Limit | `None` |

Throttle 的 Sample Rate 是平均 item 率上限，不会执行插值或抽取。

### QT GUI Time Sink

| 参数 | 值 |
|---|---|
| Type | `float` |
| Sample Rate | `32000` |
| Number of Points | `1024` |
| Trigger Slope | 显式选择 `Positive` |
| Update Period | `0.1` s |

显示窗口覆盖的时间约为：

```text
1024 / 32000 = 0.032 s
```

### QT GUI Frequency Sink

| 参数 | 值 |
|---|---|
| Type | `float` |
| FFT Size | `1024` |
| Center Frequency | `0` Hz |
| Bandwidth | `32000` Hz |
| Update Period | `0.1` s |

FFT bin 间隔约为：

```text
32000 / 1024 = 31.25 Hz
```

### 启动前检查

- 四个 Block 的流端口基础类型均为 `float`
- Time Sink 的 Sample Rate 与 Frequency Sink 的 Bandwidth 都对应当前 32 kSps 段
- Signal Source 的频率低于 16 kHz Nyquist 频率
- Throttle 的 Vector Length 为 1，与标量流一致

## 2. 验证输出

运行后应观察到：

- Time Sink 中幅度约为 `-0.8` 到 `+0.8`、周期约 1 ms 的正弦波
- Frequency Sink 中在 1 kHz 附近出现谱峰
- 频谱峰值的具体高度和旁瓣取决于窗函数、归一化和显示设置，不应据此假定固定 dB 值

若 GUI 没有显示预期内容，先检查终端中的第一条错误，再对照[故障排查](TROUBLESHOOTING.md)。

## 3. 改变信号参数

### 改变频率

| Frequency | 预期现象 |
|---:|---|
| 500 Hz | 时域周期约 2 ms，频谱峰值约 500 Hz |
| 2000 Hz | 时域周期约 0.5 ms，频谱峰值约 2 kHz |
| 8000 Hz | 每周期约 4 个样本 |
| 20000 Hz | 在 32 kSps 下发生混叠，离散序列对应约 12 kHz 的别名 |

### 改变采样率

将当前整段改为 48 kSps 时，同时更新：

- Signal Source Sample Rate
- Throttle Sample Rate
- Time Sink Sample Rate
- Frequency Sink Bandwidth

在 FFT Size 仍为 1024 时，bin 间隔变为约 46.875 Hz。数值比 31.25 Hz 更大，因此频率分辨率变粗，而不是提高。

推荐用一个流程变量管理这一段的速率：

```python
samp_rate = 48000
```

## 4. 加入低通滤波器

下面的例子使用 32 kSps。若上一节改为 48 kSps，请先把 Signal Source、Throttle 和两种显示模块的速率设置恢复为 32000。

```text
[Signal Source] -> [Throttle] -> [Low Pass Filter] -> [QT GUI Frequency Sink]
```

| 参数 | 值 |
|---|---|
| FIR Type | `Float->Float (Decimating)` |
| Decimation | `1` |
| Sample Rate | `32000` |
| Cutoff Freq | `2000` |
| Transition Width | `500` |
| Window | `Hamming` |
| Gain | `1` |

把信号频率依次设为 1 kHz、2.2 kHz 和 5 kHz，观察通带、过渡带和阻带的差异。实际衰减由生成的 taps 和窗参数决定，不在未测量时承诺固定的 dB 数值。

若把 Decimation 改为 `D>1`，滤波器输出段的采样率应改记为：

```text
fs_out = 32000 / D
```

下游 GUI 必须使用这个新速率，而不是继续机械地填写 32000。

## 5. 类型与布局

流端口连接要求 item size 匹配。常见正确转换示例：

```text
[Signal Source (complex)] -> [Complex to Mag] -> [Throttle (float)] -> [Time Sink (float)]
```

FFT Block 处理向量 item。若从标量流使用 FFT，应先按 FFT Size 组成向量：

```text
[Complex Stream] -> [Stream to Vector (1024)] -> [FFT (1024)]
```

## 6. Throttle 的边界

```text
纯软件实时观察： [Signal Source] -> [Throttle] -> [GUI]
离线快速处理：   [File Source] -> [Processing] -> [File Sink]
硬件采集：       [USRP Source] -> [Processing] -> [GUI]
```

- 第一种通常适合使用 Throttle
- 第二种是否限速取决于是否需要按墙上时钟实时回放
- 第三种通常由设备和 I/O 限速；额外的 Throttle 可能导致 overflow

Throttle 与 Resampler 不可互换。需要改变样本率关系时使用相应的重采样 Block。

## 下一步

- 阅读[核心概念](CONCEPTS.md)，理解消息、PDU、标签和多速率流程
- 用 [Rational Resampler](modules/Rational_Resampler.md) 实现 48 kSps 到 16 kSps
- 用 [File Sink](modules/File_Sink.md) 和 [File Source](modules/File_Source.md) 验证原始 item 格式
- 接入硬件前先阅读 [UHD USRP Source](modules/UHD_USRP_Source.md) 的设备参数

---

[核心概念](CONCEPTS.md) / [故障排查](TROUBLESHOOTING.md) / [Block 目录](../README.md#block-目录)
