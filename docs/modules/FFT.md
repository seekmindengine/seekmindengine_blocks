# FFT 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / FFT

## 概览

FFT 模块对输入的向量数据执行快速傅里叶变换（Fast Fourier Transform），将时域信号转换为频域表示。这是频谱分析和频域处理的核心模块。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Fourier Analysis（傅里叶分析） |
| Block ID | `fft_vxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **频谱分析**  
   将时域信号转换到频域进行频谱分析

2. **频域滤波**  
   在频域进行滤波操作

3. **信号检测**  
   检测特定频率分量的存在

4. **编码波形处理**  
   OFDM 等复数编码波形的核心处理

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和 FFT 长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `complex` × FFT 长度 | 连续样本流端口 |

> FFT 点数、窗函数和采样率共同决定频率分辨率与幅度表现；比较结果时必须保持这些配置一致。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Input Type** | 枚举 | 选择输入端样本类型 | float | ✗ |
| **FFT Size** | 整数 | 设置 FFT 点数；点数增大会提高频率分辨率并增加计算与延迟 | 1024 | ✗ |
| **Forward/Reverse** | 枚举 | 选择正向或反向处理顺序 | Forward | ✗ |
| **Window** | real_vector | 选择 FFT 窗函数 | window.blackmanharris(1024) | ✓ |
| **Shift** | 枚举 | 设置移位位数或数据位置偏移 | Yes | ✗ |
| **Num. Threads** | 整数 | 设置处理线程数量；增加前应测量吞吐与调度开销 | 1 | ✓ |

## 参数说明

**1. Input Type**
- 输入数据类型
  - complex
  - float

**2. FFT Size**
- FFT 计算点数；增大点数可提高频率分辨率，但会增加计算量和观察延迟。
**3. Forward/Reverse**
- 正向/反向变换
  - **Forward**：True
  - **Reverse**：False

**4. Window**
- 窗函数类型

**5. Shift**
- 是否进行频谱搬移
  - **Yes**：True
  - **No**：False

**6. Num. Threads**
- 线程数

## 工作原理

**正向 FFT：**
```
时域向量 [x₀, x₁, ..., x_{N-1}]
    ↓ FFT
频域向量 [X₀, X₁, ..., X_{N-1}]

X_k = Σ(n=0 to N-1) x_n · e^(-j2πkn/N)
```

**频率分辨率：**
```
Δf = Sample_Rate / FFT_Size
```

**频率映射（Shift=False）：**
```
bin 0:       DC (0 Hz)
bin 1:       Δf
bin k:       k·Δf
bin N/2:     fs/2 (Nyquist)
bin N/2+1:   -fs/2 + Δf (负频率)
```

正向与逆向变换均不自动做 1/N 归一化；在不加窗且 Shift 配置匹配时，FFT 后接逆变换得到 N 倍输入，需要显式乘以 1/N 恢复幅度。

## 快速示例

**示例 1：基本频谱分析**

```
[Signal Source] → [Throttle] → [Stream to Vector] → [FFT] → [Complex to Mag] → [Vector to Stream] → [File Sink]
                                  (1024)            (1024)    (1024)
```

配置参数：
- Type: Complex
- FFT Size: 1024
- Forward/Reverse: Forward
- Window: []
- Shift: False

**示例 2：使用窗函数的 FFT**

```python
# 在 Python 中生成窗函数
import numpy as np
window = np.hamming(1024)

# 在 FFT 模块中使用
```

配置参数：
- FFT Size: 1024
- Window: window (Hamming 窗)
- Shift: True  (频谱中心化)

**示例 3：对数幅度观察**

```
[Source] → [Stream to Vector] → [FFT] → [Complex to Mag²] → [Log10] → [Multiply Const] → [Display]
            (2048)              (2048)   (2048)              (2048)     (10)
```

配置参数：
- FFT Size: 2048
- Forward/Reverse: Forward
- Shift: True

上述第三个示例只计算对数谱量，未包含按采样率、FFT 点数和窗能量的 PSD 标定，不能直接标为功率谱密度。QT GUI Frequency Sink 自带 FFT；观察频谱时应直接连接时域输入。

## FFT 参数选择指南

**FFT Size 选择：**
- 频率分辨率要求：Δf = fs / N
- 时间分辨率要求：Δt = N / fs
- 计算资源：更大的 N 需要更多计算
- 推荐：1024 或 2048（平衡性能和分辨率）

**窗函数选择：**
| 窗函数 | 主瓣宽度 | 旁瓣抑制 | 适用场景 |
|--------|---------|---------|---------|
| 矩形窗 | 最窄 | 差(-13dB) | 瞬态信号 |
| Hamming | 中等 | 好(-43dB) | 通用，推荐 |
| Hann | 中等 | 中(-31dB) | 通用 |
| Blackman | 宽 | 优(-58dB) | 高动态范围 |

## 性能与部署

1. **计算复杂度**  
   O(N log N)，N 为 FFT Size

2. **内存使用**  
   需要存储输入向量和输出向量

3. **实时性**  
   大 FFT 可能影响实时性能

4. **FFTW 优化**  
   运行时使用 FFTW 库，首次运行时会进行优化

## 故障排查

**Q1: 为什么 FFT 需要向量输入？**  
A: FFT 对一组数据进行批量处理。使用 Stream to Vector 将流转换为向量。

**Q2: FFT Size 必须是 2 的幂次吗？**  
A: 不是必须的，但 2 的幂次计算效率最高。

**Q3: 如何提高频率分辨率？**  
A: 增大 FFT Size 或降低采样率。频率分辨率 = 采样率 / FFT Size。

**Q4: Shift 参数什么时候使用？**  
A: 当需要将 DC 分量放在频谱中心时使用，便于观察正负频率。

**Q5: 为什么频谱有镜像？**  
A: 实数信号的 FFT 具有共轭对称性。使用复数信号可避免镜像。

## 典型应用

**频谱监测：**
```
[Acquisition Source] → [Stream to Vector] → [FFT] → [Processing] → [Display]
```

**OFDM 编码波形处理：**
```
[OFDM Encoded Waveform] → [FFT] → [Subcarrier Extraction] → [Symbol Detection]
```

**频域滤波：**
```
[Signal] → [FFT] → [Frequency Domain Filter] → [IFFT] → [Output]
```

## 相关 Block

- [Stream to Vector](Stream_to_Vector.md)：将流转换为 FFT 所需的向量
- [Vector to Stream](Vector_to_Stream.md)：将 FFT 输出转换回流
- [Complex to Mag](Complex_to_Mag.md)：计算 FFT 输出的幅度
- [Log Power FFT](Log_Power_FFT.md)：直接输出对数功率谱

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
