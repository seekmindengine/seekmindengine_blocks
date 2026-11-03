# Goertzel 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Goertzel

## 概览

Goertzel 模块实现 Goertzel 算法，用于计算单个频率点的离散傅里叶变换（DFT）。相比完整的 FFT，当只需要检测少数几个频率时，Goertzel 算法更加高效。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Fourier Analysis（傅里叶分析） |
| Block ID | `goertzel_fc` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **DTMF 检测**  
   检测双音多频（电话按键音）信号

2. **单频检测**  
   检测特定频率的存在

3. **频率估计**  
   精确估计单个频率分量

4. **音调检测**  
   检测音频中的特定音调

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | float | 连续标量时域样本 |
| 输出 | `默认` | 样本流 | complex | 每 Length 个输入产生一个频点结果 |

输出 item 率为输入的 1/Length；不需要先接 Stream to Vector。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Rate** | 整数 | 输入采样率，必须设为正数 | 0（需填写） | ✓ |
| **Length** | 整数 | 每次分析的不重叠窗口长度，必须为正数 | 0（需填写） | ✗ |
| **Frequency** | 浮点数 | 目标频率，单位 Hz | 0 | ✓ |

## 工作原理

令 N=Length、ω=2π×Frequency/Rate。每窗口从零状态计算：

```text
s[n] = x[n] + 2cos(ω)s[n−1] − s[n−2]
out = (cos(ω)s[N−1] − s[N−2] + j sin(ω)s[N−1]) / N
```

当前实现按 N 归一化。Frequency 恰为整数 DFT bin 时，可与同窗口 FFT 对应 bin 除以 N 比较；任意非整数 bin 的复相位还需按上式处理。模块不自动加窗；目标频率偏离输入或观察窗口不含整数周期时存在泄漏。

## 快速示例

Float Signal Source：Sample Rate=8000、Frequency=1000、Amplitude=1、Offset=0；Goertzel：Rate=8000、Length=80、Frequency=1000。每 10 ms 输入数据产生一个 Complex 结果；接 Complex to Mag 后，稳定的幅值应接近 0.5。显示结果时下游采样率填写 100 item/s。

检测多个音调时，将同一输入分支给多个不同 Frequency 的 Goertzel，再比较幅值。

## 性能与部署

每个频点每窗口计算量为 O(N)。少量频点可评估本模块，完整频谱通常用 FFT；具体性能分界须实测。增大 N 缩小频点分辨尺度，同时增加观察窗口时长。

## 故障排查

Rate 和 Length 的默认 0 不能用于实际运行，应先填写有效值。幅值相差 N 倍时检查归一化约定；时轴相差 N 倍时检查输出 item 率。频点输出是复数，连接 Float 显示前应提取幅度、实部或虚部。

## 相关 Block

- [FFT](FFT.md)：完整的傅里叶变换
- [Log Power FFT](Log_Power_FFT.md)：对数功率谱
- [Complex to Mag](Complex_to_Mag.md)：计算幅度
- **Threshold**：阈值检测

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
