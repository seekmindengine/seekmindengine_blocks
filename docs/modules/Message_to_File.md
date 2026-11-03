# Message to File 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Message to File

## 概览

Message to File 将 msg 端口收到的 PMT 消息转换为文本并写入文件，可选附加写入时的时间戳。它是消息日志 Sink，不输出样本流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Advanced File（高级文件） |
| Block ID | `filerepeater_msg_to_file` |
| 处理模型 | 消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | 平台内置 |

## 何时使用

- 保存控制消息、状态变化和调试事件。
- 留存可人工阅读的消息日志。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `msg` | 消息 | `按消息格式` | 离散消息端口 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **File** | file_open | 设置读取或写入的文件路径 |  | ✗ |
| **Add Timestamp** | 枚举 | 控制写入记录时是否附加时间戳 | No | ✗ |
| **File Disposition** | 枚举 | 选择目标文件已存在时的处理方式 | Append | ✗ |

## 工作原理

构造时按 File Disposition 打开文件；Append 保留已有内容并追加，Overwrite 从本次启动开始覆盖。每条消息按其文本表示写入，Add Timestamp 可增加记录时的本地时间。

模块没有 JSON/CSV 格式选项，也不把 PDU 的二进制负载直接当成原始样本文件。需要结构化字段或二进制存储时，应使用相应的序列化/文件处理逻辑。

## 快速示例

QT GUI Msg Push Button 设置 Type=Integer、Message Property Name=`event`、Message Value=1，将 pressed 连接到 msg。选择一个可写文件，File Disposition=Append、Add Timestamp=No。点击后应新增一条包含该 PMT pair 文本的记录；文本的具体标点以实际输出为准。

## 性能与部署

消息量和磁盘写入速度决定日志开销。高频消息应先评估吞吐；时间戳表示写入时刻，不是样本时间。部署前用一条消息验证文件能创建并正确关闭。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 启动时报文件打开错误 | 路径、权限或安装实现的问题 | 检查首条异常；若提示文本不支持无缓冲写入，需更新组件实现 |
| 旧日志消失 | 使用 Overwrite | 需要保留历史时选 Append |
| 无法按 JSON/CSV 解析 | 输出是 PMT 文本表示 | 使用明确的结构化日志转换逻辑 |
| 时间戳不能对齐采样点 | 记录的是消息处理时刻 | 在上游消息中携带采样时间信息 |

## 相关 Block

- [Message Debug](Message_Debug.md)：在终端查看消息。
- [File Sink](File_Sink.md)：写原始样本流。
- [QT GUI Msg Push Button](QT_GUI_Msg_Push_Button.md)：产生测试消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
