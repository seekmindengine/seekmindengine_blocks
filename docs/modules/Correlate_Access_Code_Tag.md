# Correlate Access Code - Tag 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Correlate Access Code - Tag

## 概览

Correlate Access Code - Tag 在 byte 或 float 流中检测同步码，在同步码之后的第一个 item 上添加标签。数据原样输出，标签值为此次匹配的错误 bit 数。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Synchronizers（同步器） |
| Block ID | `digital_correlate_access_code_tag_xx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

标记连续 bit 流中的同步码位置，供后续协议解析或调试使用。该模块不解析包长，标签值也不表示包长。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | byte 或 float | byte 按最低位判 bit；float 按正负判 bit |
| 输出 | `默认` | 样本流 | 与输入相同 | 原样流和检测标签 |

byte 输入通常应为每字节一个 0/1 bit。Float 输入用非负值表示 1、负值表示 0，输出仍保留原 float 数值。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---|---|---|---|
| **IO Type** | 枚举 | byte 或 float | byte |
| **Access Code** | 字符串 | 1–64 位的 0/1 同步码 | `1010110011011101101001001110001011110010100011000010000011111100` |
| **Threshold** | 整数 | 允许的错误 bit 数，取 0 到同步码长度之间 | 0 |
| **Tag Name** | 字符串 | 检测标签键；标签值不是包长 | packet_len |

## 工作原理

对检测窗口计算错误 bit 数，结果不超过 Threshold 时记录命中。标签放在完整同步码之后的第一个 item，值为错误 bit 数：精确匹配时为 0。

```text
输入：  1 0 1 1 | 0 1 0
输出：  1 0 1 1 | 0 1 0
标签：          ↑ sync_errors=0（offset=4）
```

即使默认键名是 packet_len，这个值也不是长度。建议改成 sync_errors 等符合含义的键，避免被长度标签处理模块误读。

## 快速示例

Byte Vector Source 设置 Vector=`[1,0,1,1,0,1,0]`、Repeat=No；本模块设 IO Type=Byte、Access Code=`1011`、Threshold=0、Tag Name=`sync_errors`。输出接 Byte Tag Debug，应在 offset=4 看到 sync_errors=0，样本序列保持不变。

## 性能与部署

同步码越短或 Threshold 越大，随机命中的可能性越高。先用已知序列和零错误阈值验证，再依据实际误码条件调整。模块不纠正输入 bit 错误。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 找不到同步码 | bit 顺序或 Float 判决极性不符 | 使用已知 0/1 序列验证 |
| 频繁误检 | 同步码短或阈值过宽 | 延长同步码或降低阈值 |
| 下游报包长为 0 | 把错误 bit 数当成了包长 | 换用适当的头解析和长度标签处理 |

## 相关 Block

- [Correlate Access Code - Tag](Correlate_Access_Code_Tag.md)：保留输入并添加检测标签。
- [Correlate Access Code - Tag Stream](Correlate_Access_Code_Tag_Stream.md)：解析固定长度头并输出负载。
- [Tag Debug](Tag_Debug.md)：观察标签。
- [Repack Bits](Repack_Bits.md)：按约定位序重打包。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
