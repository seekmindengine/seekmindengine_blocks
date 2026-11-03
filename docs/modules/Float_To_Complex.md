# Float To Complex 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Float To Complex

## 概览

Float To Complex 将实数输入组合为复数输出：`re` 提供实部，`im` 提供虚部。`im` 是可选端口，只连接 `re` 时，输出复数的虚部为 0。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Type Converters（类型转换） |
| Block ID | `blocks_float_to_complex` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 将独立的 I、Q 两路 Float 流组合为 Complex 流。
- 为实数数据增加值为 0 的虚部，接入需要 Complex 输入的处理链。
- 在向量处理中，按元素组合相同长度的实部和虚部向量。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `re` | 样本流 | float × Vector Length | 必需；输出复数的实部 |
| 输入 | `im` | 样本流 | float × Vector Length | 可选；未连接时虚部为 0 |
| 输出 | `默认` | 样本流 | complex × Vector Length | 单路复数输出，向量长度保持不变 |

双输入时，两路数据应具有相同的 item 率、向量长度和对应的采样时刻。模块按样本位置组合数据，不会校正 I/Q 通道的时间偏移。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Vector Length** | 整数 | 每个 item 的元素数量，必须大于 0；所有端口使用相同长度 | 1 | ✗ |

输入类型固定为 Float，输出类型固定为 Complex。Vector Length 为 1 时处理标量，大于 1 时按向量中相同位置的元素分别组合。

## 工作原理

双输入时，对每个位置执行：

```text
output[k] = re[k] + j * im[k]

re:     [3, 0, 5]
im:     [4, 2, 12]
output: [3+4j, 0+2j, 5+12j]
```

只连接实部时：

```text
re:     [-1, 0, 2]
output: [-1+0j, 0+0j, 2+0j]
```

输出 item 率与每路已连接输入的 item 率相同，向量长度也保持不变。两路输入组合成一路复数流时，item 数量不会翻倍。

## 快速示例

```text
[Vector Source: 3,0,5]  --> re [Float To Complex] --> [Complex to Mag] --> [File Sink]
[Vector Source: 4,2,12] --> im
```

两个 Vector Source 均设置 Output Type=`Float`、Vector Length=`1`、Repeat=`No`；Float To Complex 和 Complex to Mag 的 Vector Length 均为 `1`；File Sink 类型选择 Float。

复数中间结果应为 `[3+4j, 0+2j, 5+12j]`，经过 Complex to Mag 后，输出文件应包含 `[5, 2, 13]` 三个 float 样本。

验证可选输入时，断开 `im`，保留 `re` 输入 `[3, 0, 5]`；复数中间结果应为 `[3+0j, 0+0j, 5+0j]`，幅度输出应为 `[3, 0, 5]`。

## 性能与部署

- 模块执行逐元素组合；向量长度增加时，应按元素总数估算数据量。
- 单个 Float 元素通常为 4 字节，单个 Complex 元素为 8 字节；单输入转换时，输出字节率是输入的两倍。
- 双输入时，两路供数速度需要匹配。只需实部时直接留空 `im`，无需额外生成零值流。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无法连接输入 | 输入不是 Float，或向量长度不一致 | 核对输入类型及两端 Vector Length |
| 无输出或流程停滞 | `re` 未连接，或已连接的 `im` 没有供数 | 接通 `re`；不需要虚部时断开 `im` |
| I/Q 结果交换 | 两路接到了错误端口 | 确认 I 接 `re`、Q 接 `im` |
| 复数结果的相位异常 | 两路输入存在时延或采样时刻不一致 | 在组合前核对通道同步和数据对齐 |
| 单路交织 I/Q 数据无法直接组合 | 输入仍是一路交织流 | 先用 Deinterleave 拆成 I、Q 两路，再分别连接 |

## 相关 Block

- [Complex to Mag](Complex_to_Mag.md)：观察组合后复数信号的幅度。
- [Deinterleave](Deinterleave.md)：将交织的 I/Q 数据拆为两路实数流。
- [Interleave](Interleave.md)：将多路数据按顺序交织为一路。
- [Vector Source](Vector_Source.md)：提供已知实部、虚部序列用于验证。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
