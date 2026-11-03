# Advanced File Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Advanced File Sink

## 概览

Advanced File Sink 将样本流或输入数据消息写入文件，可通过状态消息控制记录，并把频率、采样率和时间戳加入文件名。支持记录大小/时间限制及频率变化时开启新记录。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Advanced File（高级文件） |
| Block ID | `filerepeater_AdvFileSink` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | 平台内置 |

## 何时使用

- 按控制消息启动或停止信号记录。
- 记录不同频率条件下的数据并在文件名中保留元信息。
- 对单次记录设置大小或时长限制。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `data_in` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口；可选 |
| 输入 | `recordstate` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Base Directory** | 字符串 | 设置输出文件所在目录 | /tmp | ✗ |
| **Base Filename** | 字符串 | 设置输出文件的基础名称 | gr_record | ✗ |
| **Input Type** | 枚举 | 选择输入端样本类型 | Float | ✗ |
| **Bits per Sample** | 整数 | WAV 模式的位深度 | 8 | ✗ |
| **Frequency** | float | 记录频率元数据，单位 Hz；不对信号做频移 | 0 | ✓ |
| **Sample Rate** | float | 设置采样率，单位为 Sps | 32000 | ✗ |
| **Max File Size (B)** | 整数 | 记录大小限制，0 禁用此限制 | 0 | ✗ |
| **Max Record Time (s)** | 整数 | 设置单个文件的最长记录时间，单位为秒 | 0 | ✗ |
| **Record On Start** | 枚举 | 控制流程启动后是否立即开始记录 |  | ✗ |
| **Honor Freq Change** | 枚举 | 控制是否响应运行时频率变化请求 |  | ✗ |
| **Autostart on Freq Change** | 枚举 | 控制频率变化后是否自动开始新记录 |  | ✗ |
| **Buffered Writes** | 枚举 | 控制是否启用缓冲写入以降低 I/O 调用频率 |  | ✗ |
| **Honor Freq Tags** | 枚举 | 控制是否根据流标签更新记录频率元数据 |  | ✗ |
| **Vec Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |

## 工作原理

Record On Start 决定启动时是否记录，recordstate 用于接收记录状态控制。样本流和 data_in 都是可选输入，data_in 用于提交要记录的数据包；接入消息前应先验证其负载格式。

Base Directory 与 Base Filename 决定保存位置和基础名称，组件添加采样率、频率和时间戳。Honor Freq Change 开启时，记录中的频率变化会关闭旧文件并开始新文件；Autostart on Freq Change 还要求 Honor Freq Change 开启。

大小和时间限制设为 0 表示禁用。不要把记录限制推断为循环分卷、自动删旧文件或无限续录；连续记录策略需要在目标运行版本中明确验证。

## 快速示例

Signal Source 设置 Float、Sample Rate=32000，经 Float Throttle（32000）连接本模块。选择一个可写的 Base Directory，Base Filename=`capture`、Input Type=Float、Sample Rate=32000、Frequency=0、Record On Start=Yes，两个记录限制设为 0。运行短时间后停止流程，检查生成文件及文件名中的元信息。

首次验证使用样本流输入。需要定时控制时再接 State Timer，并先用 Message Debug 检查状态消息。

## 性能与部署

估算写入字节率时使用 item 率、Vec Length 和元素字节数。Buffered Writes=Yes 可减少系统调用，但写入缓存不等于数据已经落盘；长期记录需要监测空间和实际吞吐。Sample Rate 记录元信息，不负责限速。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 没有文件 | 目录不可写或未进入记录状态 | 检查 Base Directory 和 Record On Start |
| 改频后没有新文件 | Honor Freq Change 未启用 | 核对频率响应和自动启动设置 |
| 达到限制后行为与预期不同 | 把记录限制当成自动分卷 | 先做小文件/短时间验收，再确定记录策略 |
| 消息输入无效 | 控制/数据负载结构不符 | 先验证流输入，再逐项验证消息接口 |

## 相关 Block

- [File Sink](File_Sink.md)：直接连续写入原始文件。
- [State Timer](State_Timer.md)：发送定时状态。
- [Message Debug](Message_Debug.md)：查看控制消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
