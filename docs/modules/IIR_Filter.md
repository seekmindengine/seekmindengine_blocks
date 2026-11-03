# IIR Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / IIR Filter

## 概览

IIR Filter 使用前馈与反馈系数执行递归滤波。它可实现低通、高通或陷波等响应；系数的符号、归一化和极点位置直接决定结果。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `iir_filter_xxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **高效滤波**  
   用较少的系数实现陡峭的滤波器

2. **模拟滤波器仿真**  
   数字实现经典模拟滤波器（Butterworth、Chebyshev等）

3. **音频均衡**  
   实现参数均衡器和音效处理

4. **控制系统**  
   实现反馈控制滤波器

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float->Float (Double Taps) | ✗ |
| **Feed-forward Taps** | 类型相关 | 设置 IIR 滤波器前馈系数 | [] | ✓ |
| **Feedback Taps** | 类型相关 | 设置 IIR 滤波器反馈系数 | [] | ✓ |
| **Old Style of Taps** | 枚举 | 控制是否使用兼容旧格式的抽头解释方式 | True | ✗ |

## 工作原理

Feed-forward Taps 为 b，Feedback Taps 为 a。模块忽略 a[0]，不会自动用它归一化系数。

```text
Old Style of Taps=False: y[n] = Σ b[k]x[n−k] − Σ(k≥1) a[k]y[n−k]
Old Style of Taps=True:  y[n] = Σ b[k]x[n−k] + Σ(k≥1) a[k]y[n−k]
```

常规设计工具采用第一种约定。导入系数时先保存原 a0，再将 b 和 a 全部除以 a0，选择 False；a0 必须非零。True 是默认值，反馈项直接相加，使用相同数值会得到不同响应。不要把空默认列表当作直通滤波器，应显式填写有效系数。

## 快速示例

一阶低通 `y[n]=0.1x[n]+0.9y[n−1]`：

- Type=Float->Float (Double Taps)。
- Feed-forward Taps=`[0.1]`。
- Feedback Taps=`[1,-0.9]`，Old Style of Taps=False。
- 若选择 True，则 Feedback Taps 改为 `[1,0.9]`。

Float Vector Source 输出 `[1,0,0,0,0]`、Repeat=No，结果应依次接近 `[0.1,0.09,0.081,0.0729,0.06561]`。用 File Sink 记录并按 float32 读取。

使用外部设计工具导入时：

```python
from scipy import signal
b, a = signal.butter(2, 1000, fs=48000)
a0 = a[0]
b = b / a0
a = a / a0
# 填入两组系数，Old Style of Taps=False
```

此例需自行提供相应科学计算依赖。

## 性能与部署

每个样本的计算量随前馈和反馈系数数量增加。高阶直接型滤波对系数量化更敏感，可将设计分成多个二阶节，每节用一个模块并保持相同符号约定。IIR 一般具有非线性相位，Bessel 设计也只是近似平坦群延时。运行时换系数后应重新检查瞬态。

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 低通变成振荡或响应不符 | Old Style 与反馈符号不一致 | 用上述一阶冲激示例核对 |
| 增益不符 | 系数未归一化 | 按原 a0 同时归一化 b、a |
| 输出发散或出现非有限数 | 极点、系数量化或输入幅度 | 检查稳定性，降低阶数并分级实现 |
| 初始化失败 | 使用空系数或类型不匹配 | 填入有效前馈、反馈向量 |

稳定设计的极点应在单位圆内；有限精度下仍需测试实际输入范围。

## 相关 Block

- [Single Pole IIR Filter](Single_Pole_IIR_Filter.md)：一阶平滑。
- [Low Pass Filter](Low_Pass_Filter.md)：由截止频率设计 FIR。
- [DC Blocker](DC_Blocker.md)：滑动平均结构的直流抑制。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
