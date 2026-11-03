# Tag Debug 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Tag Debug

## 概览

Tag Debug 消费样本流，并在终端打印其中的流标签，包括输入编号、绝对 item 偏移、键、值及来源。它是调试 Sink，没有样本流输出或消息输出。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Tag Tools（流标签工具） |
| Block ID | `blocks_tag_debug` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

- 核对标签键、值和偏移是否符合预期。
- 在变速率或向量转换模块前后分支观察标签。
- 调试长度标签和同步检测标签。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Num Inputs-1` | 样本流 | Input Type × Vector Length | 消费样本并读取标签 |

需要继续处理数据时，从上游分出另一条连接，不要把 Tag Debug 串接在处理路径中。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Input Type** | 枚举 | 选择输入端样本类型 | float | ✗ |
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **Key Filter** | 字符串 | 只查看此键的标签；为空时查看全部 |  | ✗ |
| **Num Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |
| **Display** | 枚举 | 控制是否在终端打印标签 | On | ✓ |

## 工作原理

每次调度读取本批次 item 范围内的标签，按 Key Filter 筛选，再按 Display 开关打印。offset 按该输入流的完整 item 计数；向量流中一个向量是一个 item。

模块不修改标签，也不会把标签转换成 PMT 消息。没有符合条件的标签时，可能完全不打印。

## 快速示例

Float Vector Source 输出 `[0,1,2,3,4,5,6,7]`，Repeat=No；连接 Stream to Tagged Stream（Float、Packet Length=4、Length Tag Key=packet_len），再接 Tag Debug（Float、Key Filter=packet_len、Display=On）。终端应在 offset=0 和 4 看到值为 4 的标签。

## 性能与部署

终端输出可能明显降低吞吐。稳定运行时关闭 Display 或去掉调试分支；需要机器可读日志时使用专门的记录逻辑。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 没有打印 | 无标签、过滤键不匹配或 Display 关闭 | 清空 Key Filter 并用已知标签源检查 |
| 不能继续连接下游 | 本模块是 Sink | 从上游另分一条数据连接 |
| offset 与元素数不一致 | 输入是向量流 | 按 item 而不是标量数解释 |
| 想连接 Message Debug | 本模块没有消息输出 | 分别调试流标签和消息端口 |

## 相关 Block

- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：生成固定间隔长度标签。
- [Message Debug](Message_Debug.md)：观察独立消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
