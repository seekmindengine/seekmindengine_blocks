# Endian Swap 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Endian Swap

## 概览

Endian Swap 将每个 item 的字节顺序整体反转，用于已明确字节布局的大小端转换。它不改变 item 的字节数，也不按数值做类型转换。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_endian_swap` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 处理已明确布局的整数或复数原始数据。当前 IO Type 选项不包含 Float。
- 在文件或网络边界上转换固定宽度字的字节顺序。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | IO Type | 每个 item 为一个待反转字 |
| 输出 | `默认` | 样本流 | 与输入相同 | 对应 item 的字节整体倒序 |

Complex 对应一个 8 字节 item，整个 8 字节会倒序。这会交换 I/Q 两个 4 字节半部的位置，不等价于分别对实部和虚部做 32 位字节序转换。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---|---|---|---|
| **IO Type** | 枚举 | 选择 item 类型和反转宽度：Complex=8、Int=4、Short=2 字节 | 首项 Complex |

没有 Vec Length 参数。处理 IQ 文件时，应先明确文件按“一个 64 位字”还是“两个 32 位分量”存储。

## 工作原理

```text
2 字节: [B0 B1]                   → [B1 B0]
4 字节: [B0 B1 B2 B3]             → [B3 B2 B1 B0]
8 字节: [B0 B1 B2 B3 B4 B5 B6 B7] → [B7 B6 B5 B4 B3 B2 B1 B0]
```

反转两次恢复原字节序。模块不会根据文件头或网络协议自动判断是否需要转换。

## 快速示例

Short Vector Source 设为 `[0x1234,0x0102]`、Repeat=No；连接 IO Type=Short 的 Endian Swap，再接 Short File Sink。在常见小端主机上，转换后的数值应为 `0x3412`、`0x0201`。串联两个 Endian Swap 应恢复原始值。

## 性能与部署

该操作以固定字宽复制并反转字节。跨平台交换还要另外约定浮点表示、整数宽度、I/Q 顺序和向量布局。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 转换后更乱 | 原数据已是本机字节序 | 用固定十六进制样本核对 |
| Complex 的 I/Q 对调 | 对 8 字节整体反转 | 若需逐分量转换，按 32 位布局处理后再组装 |
| 找不到向量长度设置 | 本模块只有 IO Type | 在外部明确 item 组织方式 |

## 相关 Block

- [File Source](File_Source.md)：读取原始字节布局。
- [File Sink](File_Sink.md)：记录转换结果。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
