# Interleave 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Interleave

## 概览

Interleave 将多路输入样本流按端口顺序交织为一路输出。它每次从一个输入取出 Block Size 个 item，再切换到下一个输入；所有输入处理一轮后，重新从第一个输入开始。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_interleave` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 把多路独立通道交织为一路，便于按固定顺序记录或传输。
- 为需要交织布局的下游模块组织输入数据。
- 与 Deinterleave 配合，验证多通道数据的合并与拆分。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Num Streams-1` | 样本流 | 由 IO Type 决定 | 全部必需；各端口的类型和向量长度必须一致 |
| 输出 | `默认` | 样本流 | 与输入相同 | 单路交织输出，向量长度保持不变 |

Vector Length 大于 1 时，一个完整向量是一个 item，交织不会拆开向量内部的元素。模块按数据到达顺序处理，不负责采集设备之间的时钟同步。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **IO Type** | 枚举 | 输入和输出类型：complex、float、int、short、byte | float | ✗ |
| **Num Streams** | 整数 | 输入端口数量，必须大于 0 | 2 | ✗ |
| **Block Size** | 整数 | 每次从一个输入取出的连续 item 数，必须大于 0 | 1 | ✗ |
| **Vector Length** | 整数 | 每个 item 的元素数量，必须大于等于 1 | 1 | ✗ |

更改 Num Streams 后，应重新核对输入连接。Block Size 的单位是 item；Vector Length 为 4、Block Size 为 2 时，每次从一个端口取出两个完整向量，共 8 个标量元素。

## 工作原理

两路标量输入、Block Size 为 1：

```text
输入0: [1, 3, 5]
输入1: [2, 4, 6]
输出:  [1, 2, 3, 4, 5, 6]
```

两路标量输入、Block Size 为 2：

```text
输入0: [1, 2, 5, 6]
输入1: [3, 4, 7, 8]
输出:  [1, 2, 3, 4, 5, 6, 7, 8]
```

每轮从 N 个输入各消费 B 个 item，输出 N × B 个 item。若各输入的 item 率均为 R，持续运行时输出的 item 率为 N × R。该关系来自数据交织，模块不对各通道做插值或重采样。

## 快速示例

```text
[Vector Source: 1,3,5] --> 输入0 [Interleave] --> [File Sink]
[Vector Source: 2,4,6] --> 输入1
```

两个 Vector Source 均设置 Output Type=`Float`、Vector Length=`1`、Repeat=`No`；Interleave 保持默认参数，File Sink 类型选择 Float。输出文件应包含六个 float 样本，顺序为 `[1, 2, 3, 4, 5, 6]`。

需要拆回原通道时，在输出端连接 Deinterleave，设置两路输出、Block Size=`1`、Vector Length=`1`，应分别恢复 `[1, 3, 5]` 和 `[2, 4, 6]`。

## 性能与部署

- 输出链路需要承载所有输入的数据总量，记录或传输时按总 item 率估算带宽。
- 某个必需输入供数不足，会影响整轮交织的推进；先用长度一致、能够按 Block Size 完整分组的有限序列验证连接。
- 增大 Block Size 会改变通道切换粒度，下游拆分必须使用相同的值。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无输出或流程停滞 | 某个输入未连接或没有持续供数 | 核对全部 Num Streams 个输入及各自数据源 |
| 输出顺序不符合预期 | 端口顺序或 Block Size 设置错误 | 用已知序列检查每轮各端口的取数顺序 |
| 拆分后通道错位 | Deinterleave 的路数、类型、向量长度或 Block Size 不一致 | 统一两端参数并从数据起点重新运行 |
| 输出显示速度或时间轴错误 | 下游仍按单路输入的 item 率配置 | 按所有输入合并后的 item 率配置下游 |

## 相关 Block

- [Deinterleave](Deinterleave.md)：按相同分组规则将交织流拆回多路。
- [Streams to Vector](Streams_to_Vector.md)：将多路输入组合成向量 item。
- [Vector Source](Vector_Source.md)：生成可复现的交织测试序列。
- [Float To Complex](Float_To_Complex.md)：将两路实数分别作为实部和虚部，生成复数流。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
