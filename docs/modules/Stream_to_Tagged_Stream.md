# Stream to Tagged Stream 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Stream to Tagged Stream

## 概览

Stream to Tagged Stream 原样传递输入数据，并每隔 Packet Length 个 item 添加一个长度标签。输出仍是连续样本流，长度标签供下游按包处理。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Tag Tools（流标签工具） |
| Block ID | `blocks_stream_to_tagged_stream` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 为已对齐的数据流划分固定长度的数据包。
- 给需要长度标签的后续模块提供包长信息。

模块不会搜索同步字、补写协议头、将流转换为 PDU，也不会按墙上时间产生突发间隔。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | Type × Vector Length | 原始流 |
| 输出 | `默认` | 样本流 | 与输入相同 | 数据不变，增加周期性长度标签 |

Vector Length 大于 1 时，一个完整向量计为一个 item；Packet Length 与标签 offset 都按 item 计数。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Type** | 枚举 | complex、float、int、short 或 byte | float | ✗ |
| **Vector Length** | 整数 | 每个 item 的元素数量，至少为 1 | 1 | ✗ |
| **Packet Length** | 整数 | 每包的 item 数，必须大于 0 | 需填写 | ✓ |
| **Length Tag Key** | 字符串 | 长度标签键名，与下游约定一致 | `packet_len` | ✗ |

运行时更新 Packet Length 会同时更新插入间隔和标签值；不要在下游正在处理一个包时随意改变包长。

## 工作原理

从输出 offset=0 开始添加标签，后续偏移为 L、2L、3L…，每个标签值均为 L=Packet Length。

```text
Packet Length=3，Vector Length=2
item 偏移: 0        1        2        3        4        5
数据:      [a,b]    [c,d]    [e,f]    [g,h]    [i,j]    [k,l]
标签:      len=3                      len=3
```

一个包包含 3 个向量，即 6 个标量。Packet Length 不需要是 Vector Length 的整数倍。模块不会缓存到满包才输出，也不会在输入结束时自动补齐最后一包。

## 快速示例

Float Vector Source 设置 Vector=`[0,1,2,3,4,5,6,7]`、Vector Length=1、Repeat=No。本模块设置 Type=Float、Vector Length=1、Packet Length=4、Length Tag Key=`packet_len`，输出接 Float Tag Debug。

应在 offset 0 和 4 看到值为 4 的 `packet_len` 标签，数据仍为原来的八个数。

## 性能与部署

模块主要执行复制和标签插入。包长越短，标签越密集。标签不会增加样本数量；下游改变 item 率或向量组织方式时，要重新核对包长单位。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 下游找不到长度标签 | 两端键名不一致 | 统一 Length Tag Key |
| 包长相差一个向量倍数 | 把元素数当成 item 数 | 按完整向量计数 |
| 最后一包不完整 | 有限输入长度不是包长的倍数 | 上游保证完整包，或明确处理尾包 |
| 包边界与协议不符 | 输入起点未对齐 | 在加标签前先完成协议同步 |

## 相关 Block

- [Tag Debug](Tag_Debug.md)：观察标签位置和值。
- [Stream to Vector](Stream_to_Vector.md)：改变 item 的向量组织方式。
- [PDU to Stream](PDU_to_Stream.md)：将 PDU 负载展开为样本流。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
