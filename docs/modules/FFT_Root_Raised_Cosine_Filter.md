# FFT Root Raised Cosine Filter 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / FFT Root Raised Cosine Filter

## 概览

FFT Root Raised Cosine Filter 模块使用 FFT 方法实现根升余弦（RRC）滤波器。它结合了 FFT 滤波的高效性和 RRC 滤波器在数字链路实验中的作用，特别适合水声编码波形验证等需要长 RRC 滤波器的场景。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `filter_fft_rrc_filter` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | 平台内置 |

## 何时使用

1. **高效脉冲成形**  
   使用 FFT 方法实现长 RRC 滤波器

2. **匹配滤波**  
   输入端的高效匹配滤波

3. **符号成形**  
   输出端的符号脉冲成形

4. **ISI 控制**  
   最小化符号间干扰

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 滤波设计采样率应与系数作用的处理段一致；抽取型按抽取前、插值型按插值后采样率设计，并用已知信号验证频响。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float->Float (Real Taps) | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 | 1 | ✗ |
| **Gain** | 浮点数 | 设置线性增益系数 | 1 | ✓ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Symbol Rate** | 浮点数 | 设置符号率，单位为 symbols/s | 1.0 | ✓ |
| **Alpha** | 浮点数 | 设置算法平滑或滚降系数，取值约束见对应工作原理 | 0.35 | ✓ |
| **Num Taps** | 整数 | 设置滤波器抽头数量 | @{ 11 * samp_rate } | ✓ |
| **Num. Threads** | 整数 | 设置处理线程数量；增加前应测量吞吐与调度开销 | 1 | ✓ |

## 工作原理

先按 Sample Rate、Symbol Rate、Alpha、Gain 与 Num Taps 设计 RRC 系数，再通过重叠相加 FFT 卷积滤波，最后按 Decimation 抽取。它不会插值；只改变 Sample Rate 或 Symbol Rate 也不会改变实际输入速率。

Alpha 是滚降系数，通常取 0–1。RRC 的复基带双边占用宽度约为 `Symbol Rate×(1+Alpha)`，单侧边缘约为该值的一半。Num Taps 最终强制为奇数：偶数请求值会增加 1；其线性相位群延时为实际 `(N−1)/2` 个输入样本。有限输入还需考虑 FFT 分块和尾部补零。

## 快速示例

接收端已有 32 kSps、8 ksymbol/s 的 Complex 信号时，Type=Complex->Complex (Real Taps)、Sample Rate=32000、Symbol Rate=8000、Alpha=0.35、Num Taps=129、Decimation=1。输出可接按输入 SPS=4 配置的 Symbol Sync。

若先抽取到每符号两个样本，Decimation=2，后续速率改为 16000，Symbol Sync 的输入 SPS 改为 2。应验证滤波与同步性能；不能不经时序恢复就假设抽取到每符号一点一定取中了符号中心。

发射端若从符号率输入开始，需要先用插值成形结构提高采样率；不能直接将符号流接本模块并只填写更高 Sample Rate。

## 性能与部署

抽头数量影响 FFT 大小、计算量和分块延时。默认 Num Taps 是依赖 samp_rate 的表达式，使用前应检查变量是否存在，并按所需符号跨度显式设置合理抽头数。线程数与性能的关系应实测。

## 故障排查

波形速率不符时先检查实际插值/抽取链路；Num Taps 为偶数时按调整后的奇数长度计算延时。启动或短包尾部异常可能来自滤波瞬态或 FFT 分块。仅使用一个 RRC 不等于完整升余弦响应，收发匹配滤波与符号定时须配合设计。

## 相关 Block

- [Root Raised Cosine Filter](Root_Raised_Cosine_Filter.md)：时域 RRC
- [FFT Filter](FFT_Filter.md)：通用 FFT 滤波
- **Polyphase Clock Sync**：符号定时恢复
- **Constellation Decoder**：星座图解码

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
