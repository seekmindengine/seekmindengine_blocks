# Log Power FFT 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Log Power FFT

## 概览

Log Power FFT 将标量样本流转换为对数功率谱向量流。模块包含分帧、整帧抽取、Blackman-Harris 加窗、FFT、功率平均和对数换算，不创建显示窗口。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Fourier Analysis（傅里叶分析） |
| Block ID | `logpwrfft_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

- 将频谱向量交给后续检测或特征提取算法。
- 以较低的频谱帧率保存监测结果。
- 在功率域平滑后输出对数谱。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | float 或 complex | 标量时域样本 |
| 输出 | `默认` | 样本流 | float × FFT Size | 一帧含 FFT Size 个对数功率频点 |

输出不是时域波形。QT GUI Frequency Sink 会自行做 FFT，不适合直接显示这一路已计算的频谱；可保存向量，或交给按向量绘制/处理的下游。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Input Type** | 枚举 | float 或 complex | float | ✗ |
| **Sample Rate** | 浮点数 | 输入样本率，用于计算整帧抽取比例 | 32000 | ✓ |
| **FFT Size** | 整数 | 每帧样本数及输出向量长度 | 1024 | ✗ |
| **Reference Scale** | 浮点数 | 正数参考幅度尺度 R；用于对数谱归一化 | 2 | ✗ |
| **Frame Rate** | 浮点数 | 期望输出帧率，实际值受整数抽取约束 | 30 | ✗ |
| **Average** | 枚举 | 是否在取对数前平均线性功率 | Off | ✓ |
| **Average Alpha** | 浮点数 | 新一帧功率的权重，范围 [0,1] | 1.0 | ✓ |
| **FFT Shift** | 枚举 | 将零频移动到向量中心 | Off | ✗ |

Sample Rate、Frame Rate 必须为正，FFT Size 必须为有效正整数。Average=Off 时等效 Alpha=1；Alpha 越小，时间平滑越强。

## 工作原理

设采样率 Fs、FFT 点数 N、目标帧率 F。模块先组成长度 N 的非重叠向量，再以 `D=max(1, round(Fs/(N×F)))` 做整帧抽取，因此实际输出帧率为 `Fs/(N×D)`。

```text
标量输入 → 分帧/抽取 → Blackman-Harris 窗 → FFT
         → |X|² → 单极点功率平均 → 10log10 与归一化 → float 向量
```

开启平均时，`P[n]=α|X[n]|²+(1-α)P[n-1]`。设窗系数为 w、Reference Scale 为 R，则输出为：

```text
10log10(P) - 20log10(N) - 10log10(Σw²/N) - 20log10(R/2)
```

这是带窗功率校正后的对数谱，不直接表示 dBm 或每 Hz 的功率谱密度。频点间隔为 Fs/N；Shift=Off 时直流位于首元素，Shift=On 时零频位于中心附近。

## 快速示例

Signal Source 设置 Complex、Sample Rate=32000、Frequency=1000、Amplitude=1；Log Power FFT 设置 Complex、FFT Size=1024、Frame Rate=30、Average=Off、FFT Shift=Off。

输出接 Head（Float、Vector Length=1024、Num Items=10），再接 File Sink（Float、Vector Length=1024）。记录应包含 10×1024 个 float 值；频谱峰值位于从 0 计数的第 32 个频点附近。此配置 D=1，实际帧率为 31.25 帧/秒。

需要按真实时间观察时，在输入端加 Sample Rate=32000 的 Complex Throttle。

## 性能与部署

FFT Size 增大会缩小频点间隔，同时增加单帧计算量、缓冲和时间跨度。降低 Frame Rate 可跳过部分整帧，但不提供短事件必捕获保证。输出帧率由输入速率和抽取比例决定，不受 GUI 刷新率控制。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 下游无法连接 | 期望标量而实际是向量 | 对齐 Float 类型和 FFT Size 向量长度 |
| 帧率与设置略有差别 | 抽取倍数只能为整数 | 用 Fs/(N×D) 计算实际值 |
| 平均后仍明显波动 | Average 关闭或 Alpha 接近 1 | 开启平均并减小 Alpha |
| 幅度与时域峰值直接换算不符 | 忽略窗功率和参考尺度 | 按归一化公式比较 |
| 频谱被再次变换 | 接到了自行计算 FFT 的显示模块 | 改用向量处理或记录链路 |

## 相关 Block

- [FFT](FFT.md)：直接执行向量 FFT。
- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：从时域流直接显示频谱。
- [File Sink](File_Sink.md)：记录频谱向量数据。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
