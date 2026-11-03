# Pack K Bits 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Pack K Bits

## 概览

Pack K Bits 模块从 byte 输入流中读取低位 bit，并将每 K 个 bit 打包成一个输出 byte。它常用于数字通信中将硬判决 bit 流压缩为字节流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_pack_k_bits_bb` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **bit 到字节转换**  
   将 0/1 流打包为紧凑字节

2. **解调后处理**  
   将 Binary Slicer 输出恢复为字节数据

3. **文件保存**  
   减少 bit 流保存时的空间占用

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `byte` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `byte` | 连续样本流端口 |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **K** | 整数 | 每个输出 byte 打包的 bit 数 | 8 |

## 工作原理

每次从 K 个输入 byte 各取最低位，按输入顺序写入输出 byte 的 bit K−1 到 bit 0，高位补零。使用 K=1–8，输出 item 率为输入的 1/K。

K=8、输入 `[1,0,1,1,0,0,1,0]` 输出 0xB2；K=3、输入 `[1,0,1]` 输出 0x05。输入值不必只为 0/1，但只有最低位参与，例如 2 的有效 bit 为 0、255 为 1。

## 快速示例

Byte Vector Source 输出 `[1,0,1,1,0,0,1,0]`、Repeat=No，接 K=8 的 Pack K Bits，再接 Byte File Sink，应得到一个 byte：0xB2。

解调 bit 流在打包前需先确定正确字节边界。普通 Access Code - Tag 只添加检测标签，不会自动让本模块从同步码之后重新分组；需要由上游截取并对齐负载，或使用支持长度标签的处理链。

## 性能与部署

只对完整的 K 项分组输出；有限输入末尾不足 K 项时不会自动补零。模块不识别包头或长度标签，适合已对齐的连续 bit 流。

## 故障排查

字节值不对时先核对分组起点和 MSB 优先位序。需要可选位序、不同 bit 宽度或逐包尾项处理时，使用 Repack Bits。

## 相关 Block

- [Unpack K Bits](Unpack_K_Bits.md)：字节拆成 bit
- [Repack Bits](Repack_Bits.md)：灵活 bit 重打包
- [Binary Slicer](Binary_Slicer.md)：浮点判决为 bit

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
