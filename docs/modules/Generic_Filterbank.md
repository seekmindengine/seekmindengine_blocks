# Generic Filterbank 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Generic Filterbank

## 概览

Generic Filterbank 对一路复数向量流的各分量分别执行实系数 FIR 滤波。每个向量位置对应一个滤波器，输出仍为相同长度的复数向量流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Filters（滤波器） |
| Block ID | `filterbank_vcvcf` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 对已经组织成向量的多路信号配置不同 FIR 系数。
- 用同一条向量连接传递多通道滤波结果。

它不会自动把单路宽带信号拆成频带，也没有逐通道抽取率或多个独立输出端口。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | complex × M | M 为 Taps 外层列表长度 |
| 输出 | `默认` | 样本流 | complex × M | 第 i 个分量为输入第 i 个分量的 FIR 结果 |

输入和输出向量 item 率相同。可用 Streams to Vector 组合通道，再用 Vector to Streams 拆分输出。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Taps(list of lists)** | 表达式 | 实数系数的二维列表；外层决定通道数，各内层列表长度必须相同且非空 | 需填写 | ✓ |

例如 `[[1.0], [2.0]]` 定义两个单系数 FIR。运行时可更新系数，但外层列表长度必须保持不变；改变通道数需要重新构造流程。

## 工作原理

第 i 个通道沿时间方向执行 `y_i[n] = Σ taps[i][k] × x_i[n-k]`。各向量分量之间不混合，不对向量内部的相邻通道做卷积。某一组系数全为 0 时，对应输出分量为 0。

## 快速示例

Complex Vector Source 设置 Vector=`[1+1j,10+0j,2+2j,20+0j]`、Vector Length=2、Repeat=No。Generic Filterbank 的 Taps=`[[1.0],[2.0]]`。

两个输出向量应为 `[1+1j,20+0j]`、`[2+2j,40+0j]`。接 Vector to Streams（Num Streams=2、Vector Length=1）后，可分别观察两个通道。

## 性能与部署

运算量取决于通道数、非零滤波器数量和系数长度。长 FIR 会增加历史缓冲和启动瞬态；不能据此假定实现会自动并行使用所有 CPU 核。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 构造失败 | Taps 为空或各组长度不同 | 提供非空且等长的实数系数列表 |
| 端口无法连接 | 输入向量长度不等于滤波器数量 | 对齐 Taps 外层长度与向量长度 |
| 更新系数失败 | 更新时改变了通道数 | 保持外层长度不变 |
| 期待频带拆分却没有 | 输入通道尚未组织好 | 在上游明确通道/频带的形成方式 |

## 相关 Block

- [Streams to Vector](Streams_to_Vector.md)：组合多路输入。
- [Vector to Streams](Vector_to_Streams.md)：拆分滤波器组输出。
- [Decimating FIR Filter](Decimating_FIR_Filter.md)：单路 FIR 与抽取。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
