# State Timer 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / State Timer

## 概览

State Timer 按启动延迟、触发持续时间和重复周期生成开关状态消息。它是定时消息源，没有样本流输入，也不测量输入信号的状态持续时间。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Advanced File（高级文件） |
| Block ID | `filerepeater_StateTimer` |
| 处理模型 | 消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | 平台内置 |

## 何时使用

- 周期性触发记录或控制动作。
- 为接受状态消息的模块提供开/关时序。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `trigger` | 消息 | 含状态元数据的消息 | `state` 元数据项中 1 表示开，0 表示关；可选连接 |

应连接接受这一状态格式的消息端口；与只接受键值 pair 的控件连接前，需转换消息结构。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Delay Before Start (s)** | float | 设置首次触发前的等待时间，单位为秒 | 0.0 | ✗ |
| **Trigger Time (s)** | float | 设置状态触发持续时间，单位为秒 | 10.0 | ✗ |
| **Cycle Time (s)** | float | 设置重复触发周期，单位为秒 | 30.0 | ✗ |

## 工作原理

首次等待 Delay Before Start 后开始周期：周期起点发送开状态，经过 Trigger Time 发送关状态，直到 Cycle Time 到达后开始下一周期。Cycle Time 是总周期，已包含开启和等待时间。

使用非负启动延迟、正周期，且 `0<Trigger Time≤Cycle Time`。两者相等时会在周期边界连续出现关、开消息，不产生有长度的关闭间隔。

## 快速示例

设置 Delay Before Start=2、Trigger Time=1、Cycle Time=3，将 trigger 连接到 Message Debug 的 print。预期在启动约 2 秒后收到开状态、约 3 秒收到关状态，随后约 5 秒再次开启。观察时以实际系统调度误差为准。

## 性能与部署

此处时间表示软件定时，消息派发和下游处理会增加延迟。它不能代替硬件采样时钟，也不提供样本级精确触发。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 启动后没有立即触发 | 设置了启动延迟 | 等待 Delay Before Start 或调整该值 |
| 关闭间隔与预期不符 | 把 Cycle Time 当成关闭时长 | 关闭间隔为 Cycle Time−Trigger Time |
| 下游不响应 | 状态消息格式不匹配 | 先接 Message Debug 核对结构 |
| 找不到 Threshold 或采样率参数 | 将定时器误认为检测器 | 在其他模块完成检测和计时分析 |

## 相关 Block

- [Advanced File Sink](Advanced_File_Sink.md)：按状态控制记录。
- [Message Debug](Message_Debug.md)：查看定时状态消息。
- [Message to File](Message_to_File.md)：记录消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
