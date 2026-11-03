# Correlate Access Code - Tag Stream 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Correlate Access Code - Tag Stream

## 概览

Correlate Access Code - Tag Stream 搜索同步码，随后读取两份相同的 16-bit 长度字段，校验成功后输出指定长度的负载，并在负载起点添加长度标签。同步码和长度头不会出现在输出中。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Synchronizers（同步器） |
| Block ID | `digital_correlate_access_code_xx_ts` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

处理格式为“同步码 + 16-bit 字节长度 + 同一长度再重复一次 + 负载”的 bit 流。若协议不使用这种长度头，应选择普通 Tag 检测模块，再由专门解析器处理协议。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | byte 或 float | byte 按最低位判 bit；float 按正负判 bit |
| 输出 | `默认` | 样本流 | 与输入相同 | 仅输出负载 item，并在包首添加长度标签 |

byte 输入通常应为每字节一个 0/1 bit。Float 输入用非负值表示 1、负值表示 0，输出仍保留原 float 数值。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---|---|---|---|
| **IO Type** | 枚举 | byte 或 float | byte |
| **Access Code** | 字符串 | 1–64 位的 0/1 同步码 | `1010110011011101101001001110001011110010100011000010000011111100` |
| **Threshold** | 整数 | 允许的错误 bit 数，取 0 到同步码长度之间 | 0 |
| **Tag Name** | 字符串 | 负载长度标签键 | packet_len |

## 工作原理

搜索阶段计算滑动窗口与 Access Code 的汉明距离。命中后按高位优先读取 32 bit，分成两个 16-bit 无符号长度字段；只有两份长度相等才接收该包。

Byte 模式取完整 16-bit 长度作为 L；Float 模式在校验两个 16-bit 字段相等后，只取其低 12 bit 作为 L，因此该模式应将长度限制在 1–4095 字节。长度 L 的单位是原始字节；输出负载长度为 `8×L` 个 bit item，首 item 的 Tag Name 标签值也为 `8×L`。负载接收完后重新搜索；头校验失败则丢弃该头并继续搜索。输入流标签不自动透传。

```text
输入：Access Code | L(16 bit) | L(16 bit) | 8L 个负载 bit
输出：负载 bit，首 item 标签值 = 8L
```

## 快速示例

IO Type=Byte、Access Code=`1011`、Threshold=0、Tag Name=`packet_len`。用 Byte Vector Source 输出：

```python
[1,0,1,1] + [0]*15 + [1] + [0]*15 + [1] + [1,0,1,0,0,1,0,1]
```

Repeat=No。两份长度字段都为 1，因此只输出末尾 8 个负载 bit，Tag Debug 应在输出 offset=0 看到 packet_len=8。再经 Repack Bits（k=1、l=8、MSB First，Length Tag Key 与 Tag Name 一致）可恢复字节 0xA5。

## 性能与部署

同步码越短或 Threshold 越大，随机命中的可能性越高。先用已知序列和零错误阈值验证，再依据实际误码条件调整。模块不纠正输入 bit 错误。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 找不到同步码 | bit 顺序或 Float 判决极性不符 | 使用已知 0/1 序列验证 |
| 频繁误检 | 同步码短或阈值过宽 | 延长同步码或降低阈值 |
| 命中后仍无负载 | 缺少重复长度头或两份长度不同 | 按 16+16 bit 格式构造头 |
| 包长相差 8 倍 | 混淆头部字节长度与输出 bit item 数 | 按 8×L 配置后处理 |

## 相关 Block

- [Correlate Access Code - Tag](Correlate_Access_Code_Tag.md)：保留输入并添加检测标签。
- [Correlate Access Code - Tag Stream](Correlate_Access_Code_Tag_Stream.md)：解析固定长度头并输出负载。
- [Tag Debug](Tag_Debug.md)：观察标签。
- [Repack Bits](Repack_Bits.md)：按约定位序重打包。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
