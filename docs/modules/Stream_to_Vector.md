# Stream to Vector 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Stream to Vector

## 概览

Stream to Vector 改变一路流的向量布局：每 Num Items 个连续输入 item 合并成一个输出 item。它保留元素顺序，不进行数值运算。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_stream_to_vector` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **FFT 预处理**  
   将数据流转换为 FFT 所需的向量格式

2. **批量处理**  
   将数据打包成块进行批量处理

3. **矩阵运算**  
   为矩阵运算准备向量化数据

4. **数据重组**  
   改变数据的组织方式以适应特定算法

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | IO Type × (Vector Length) | 固定一路输入 |
| 输出 | `默认` | 样本流 | IO Type × (Vector Length × Num Items) | 固定一路输出 |

Vector Length 表示较小 item 的元素数；Num Items 表示一次合并或拆分的小 item 数，不是端口数量。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **IO Type** | 枚举 | 选择输入输出样本类型，连接两端必须一致 | float | ✗ |
| **Num Items** | 整数 | 设置每次处理的条目数量 | 2 | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |

## 工作原理

输入 `[[0,1],[2,3],[4,5],[6,7]]`，Vector Length=2、Num Items=2 时，输出 `[[0,1,2,3],[4,5,6,7]]`。输出 item 率为输入的 1/Num Items。输入末尾不足一组时，不会自动补零。

## 快速示例

Float Vector Source：Vector=`[0,1,2,3,4,5,6,7]`、Vector Length=1、Repeat=No。连接 Stream to Vector（Num Items=4、Vector Length=1），再连接 Vector to Stream（相同参数）与 Float File Sink。输出应恢复 `[0,1,2,3,4,5,6,7]`。

用于 FFT 时，让 Stream to Vector 的 Num Items 等于 FFT Size，Vector Length=1。FFT 结果可接匹配长度的 File Sink，或展开后记录。频谱显示模块内部已经执行 FFT，直接观察时域信号即可。

## 性能与部署

总元素数量和字节率保持不变，调度器看到的 item 率随布局改变。合并需要先取得完整一组输入；不能把此操作当成重采样或滑动窗口。

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 端口尺寸不匹配 | 混淆 Vector Length 与 Num Items | 按端口表中的乘积检查元素数 |
| 有限输入末尾缺样本 | 合并时不足完整一组 | 在上游补齐或调整分组长度 |
| FFT 后再接频谱显示不符预期 | 对频域数据再次执行 FFT | 记录计算结果，或直接把时域信号接显示模块 |

## 相关 Block

- [Vector to Stream](Vector_to_Stream.md)：向量到流的反向转换
- [Streams to Vector](Streams_to_Vector.md)：多个流合并为一个向量流
- [FFT](FFT.md)：快速傅里叶变换，需要向量输入
- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：添加长度标签的流转换

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
