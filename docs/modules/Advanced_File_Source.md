# Advanced File Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Advanced File Source

## 概览

Advanced File Source 回放单个原始数据文件，支持首次启动延迟、重复间隔、有限播放次数和两种 8-bit IQ 到 Complex 的转换方式。延迟期间按模块约定输出零值。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Advanced File（高级文件） |
| Block ID | `filerepeater_file_repeater_ex` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | 平台内置 |

## 何时使用

- 重复播放已知信号，在两次播放之间插入静默区间。
- 延迟开始测试数据回放。
- 从支持的有符号或无符号 8-bit IQ 文件生成 Complex 流。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **File** | 文件路径 | 文件路径 | - |
| **Output Type** | 枚举 | 输出数据类型 | float |
| **Complex Conversion** | 枚举 | 复数转换方式 | 0 |
| **Repeat** | 枚举 | 循环播放 | Yes |
| **Delay first start (sec)** | 浮点数 | 首次启动延迟（秒） | 0.0 |
| **ms Delay between repeats** | 整数 | 重复间隔（毫秒） | 0 |
| **Only repeat n times** | 整数 | 重复次数 | 0 |
| **Vec Length** | 整数 | 向量长度 | 1 |
| **Verbose** | 枚举 | 是否输出详细信息 | No |

## 工作原理

按 Output Type 与 Vec Length 解释文件数据；Complex Conversion=None 时按所选原始类型读取。Complex 模式还可选择 From Signed8/HackRF 或 From Unsigned8/RTLSDR。

首次延迟以秒计，重复间隔以毫秒计。Only repeat n times=0 表示不限制播放次数；按组件定义的回放约定，Repeat=Yes、Only repeat n times=1 用于播放一次后继续输出零。

本模块没有文件列表、时间戳同步、Offset、Length 或 Add Begin Tag 参数；需要偏移截取时使用 File Source 等模块。

## 快速示例

先准备一个 Float 原始样本文件。设置 Output Type=Float、Complex Conversion=None、Repeat=Yes、Only repeat n times=1、Delay first start=0、Vec Length=1，接 Float Throttle 和 QT GUI Time Sink。两者速率按文件记录时的样本率设置。应先看到文件波形，播放结束后转为零值。

需要重复回放时将次数设为 0，再把 ms Delay between repeats 设为 1000，检查每次回放之间的静默区间。

## 性能与部署

文件不会自动携带样本率或限速信息。需要按实际时间回放时，在无设备时钟约束的链路中配置限速；等待时长和系统调度不能当作精确采样时钟。文件字节数应是完整 item 大小的整数倍。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 输出全零 | 首次延迟未结束，或有限回放已经结束 | 核对延迟与次数 |
| 数值异常 | 文件布局、类型或转换方式不匹配 | 用小段已知数据核对格式 |
| 回放速度不对 | 未按记录采样率限速 | 检查硬件或 Throttle 的速率约束 |
| 找不到偏移和长度参数 | 误用了普通 File Source 的接口 | 按本页参数配置，或改用 File Source |

## 相关 Block

- [File Source](File_Source.md)：按 Offset/Length 读取原始文件。
- [Throttle](Throttle.md)：近似实时回放限速。
- [Advanced File Sink](Advanced_File_Sink.md)：控制信号记录。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
