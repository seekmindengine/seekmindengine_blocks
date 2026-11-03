# Repack Bits 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Repack Bits

## 概览

Repack Bits 模块将输入 byte 中的 `k` 个有效 bit 重新组合为输出 byte 中的 `l` 个有效 bit。它比 Pack/Unpack 更灵活，适合协议字段重排、调制映射前后处理和带长度标签的包处理。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_repack_bits_bb` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **bit 宽转换**  
   在 1-bit、2-bit、4-bit、8-bit 符号之间转换

2. **调制映射准备**  
   将 bit 流打包为 MPSK/QAM 所需的符号索引

3. **包长保持**  
   使用 Length Tag Key 维护包边界

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `byte` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `byte` | 连续样本流端口 |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Bits per input byte** | 整数 | 输入 byte 中有效 bit 数 k | 1 |
| **Bits per output byte** | 整数 | 输出 byte 中有效 bit 数 l | 8 |
| **Length Tag Key** | 字符串 | 包长度标签键；为空表示不使用 | "" |
| **Packet Alignment** | 枚举 | 输出或输入对齐 | Input |
| **Endianness** | 枚举 | bit 顺序：MSB 或 LSB | MSB |

## 工作原理

k、l 都在 1–8 范围内。模块读取每个输入 byte 的低 k 位，按 Endianness 约定的顺序串联，再每 l 位形成一个输出 byte。

Length Tag Key 为空时连续处理，完整输出 item 的数量由 bit 总数决定。设置长度标签后逐包处理并换算包长。若包的 bit 数不能整除 l，Packet Alignment=Input 保留不足 l 位的末项并补零；Output 只保留完整输出项、丢弃余下 bit。此选项只在 tagged stream 模式有意义。

例如 MSB、k=8、l=3，输入单字节 0xB2（10110010），Input 对齐可得到 `[5,4,4]`，末项仅高两位有效。逆变换 k=3、l=8 时选择 Output 对齐，可丢弃填充位并恢复 0xB2。

## 快速示例

Byte Vector Source 输出 `[0xA5]`，Repeat=No；连接 Repack Bits（k=8、l=1、MSB、Length Tag Key 留空）和 Byte File Sink，应得到 `[1,0,1,0,0,1,0,1]`。再接 k=1、l=8、MSB 的 Repack Bits，应恢复 0xA5。

PSK Demod 输出每 byte 一个 bit，恢复字节时使用 k=1、l=8，先完成帧与字节边界对齐。PSK Mod 本身接收打包字节并在内部拆分符号，文件字节可以直接输入；不能在前面先改成 k=8、l=2 的符号索引。只有明确接受符号索引的映射器才使用后一种配置。

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 位序颠倒 | Endianness 不一致 | 用 0xA5、0x80 等已知字节检查 |
| 包长变化或尾部多一个 byte | k/l 与包长不整除 | 按是否保留尾部 bit 选择 Packet Alignment |
| 解调后字节错误 | 输入实际每项只有一个 bit，或边界未对齐 | 用 k=1、l=8 并先同步 |
| 长度标签缺失错误 | 配置了 Length Tag Key 但输入没有相应包首标签 | 补齐 tagged stream 结构，或留空按连续流处理 |

## 相关 Block

- [Pack K Bits](Pack_K_Bits.md)：固定 bit 打包
- [Unpack K Bits](Unpack_K_Bits.md)：固定 bit 拆包
- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：生成长度标签流

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
