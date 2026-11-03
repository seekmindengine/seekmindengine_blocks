# Unpack K Bits 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Unpack K Bits

## 概览

Unpack K Bits 模块把输入 byte 中的 K 个 bit 拆成 K 个输出 byte，每个输出 byte 通常为 0 或 1。它常用于把文件字节展开为调制器可使用的 bit 流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_unpack_k_bits_bb` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

1. **字节转 bit 流**  
   将紧凑字节展开为 0/1 序列

2. **调制前处理**  
   为 BPSK、GMSK 等 bit 输入调制器准备数据

3. **协议字段分析**  
   逐 bit 查看和处理数据

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `byte` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `byte` | 连续样本流端口 |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **K** | 整数 | 每个输入 byte 拆出的 bit 数，可选 1-8 | 8 |

## 工作原理

每个输入 byte 只取低 K 位，按 bit K−1 到 bit 0 的顺序依次输出。每个输出 byte 严格为 0 或 1，输出 item 率为输入的 K 倍；K 在 1–8 范围内。

K=8、输入 0xB2 时得到 `[1,0,1,1,0,0,1,0]`。K=3 时只取低三位 010，得到 `[0,1,0]`。

## 快速示例

Byte Vector Source 输出 `[0xB2]`、Repeat=No，连接 K=8 的 Unpack K Bits 和 Byte File Sink，检查上述八个输出值。接到 GMSK Mod 时将 Unpack 设置为 Off，避免重复拆位。

PSK Mod 接收打包字节并自行拆位，File Source 可直接接入，不应在前面加入本模块。Byte bit 流也不能直接接只接受 Float/Complex 的 QT GUI Time Sink；可先记录文件，或显式转换类型后显示。

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

输入和输出都是 Byte，但含义不同。若结果数量扩大 64 倍，检查是否连续执行了两次 K=8 拆位。与 Pack K Bits 配对时使用相同 K；K<8 时高位已被丢弃，不能恢复原来的高位。

## 相关 Block

- [Pack K Bits](Pack_K_Bits.md)：bit 打包为 byte
- [Repack Bits](Repack_Bits.md)：灵活 bit 重打包
- [GMSK Mod](GMSK_Mod.md)：GMSK 调制器

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
