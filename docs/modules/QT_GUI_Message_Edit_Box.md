# QT GUI Message Edit Box 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Message Edit Box

## 概览

QT GUI Message Edit Box 提供一个 Qt 输入组件，在配置的 PMT 类型与 pair 模式下接收或发送消息。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `qtgui_edit_box_msg` |
| 处理模型 | 消息 |
| 典型位置 | Control / GUI |
| 执行支持 | Python |

## 何时使用

用于从 GUI 输入 String、数值、Complex 或相应 vector PMT，也可通过输入端更新组件值。该 Block 没有多行、历史、正则验证、自动发送、字体或固定宽高参数。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `val` | 消息 | 由 Type/Pair Mode 决定 | 可选 |
| 输出 | `msg` | 消息 | 由 Type/Pair Mode 决定 | 可选 |

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Type** | enum | `String` | String、Int、Float、Double、Complex 或对应 vector 类型 |
| **Value** | string | 无 | 初始输入文本 |
| **Label** | string | 无 | 组件标签 |
| **Pair Mode** | enum | `True` | 是否输出/接收 pair |
| **Static Mode** | enum | `True` | 是否使用固定 Key |
| **Key** | string | 无 | Pair Mode 与 Static Mode 使用的 key；相关组合下不能为空 |
| **GUI Hint** | gui_hint | 空 | Qt GUI 布局位置 |

## 工作原理

Type 决定编辑文本转换到哪种 PMT。Pair Mode 控制消息是否包装为 key/value pair；Static Mode 和 Key 控制固定 key 的使用方式。具体提交交互由 `qtgui.edit_box_msg` 组件实现。

## 快速示例

```text
[QT GUI Message Edit Box] --msg--> [Message Debug]
```

先用 Type=`String`、Pair Mode=`False` 验证单值消息，再根据接收端契约启用 pair。

## 性能与部署

该组件用于低频人机交互，不应作为高吞吐消息 Source。接收端必须按配置的 PMT 类型解析。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 流程校验失败 | 需要固定 key 但 Key 为空 | 填写非空 Key 或调整 Pair/Static Mode |
| 接收端无法解析 | Type 或 Pair Mode 与接收端契约不一致 | 用 Message Debug 检查 PMT 结构 |
| 找不到多行/历史设置 | 模块未提供这些参数 | 在自定义 GUI Block 中实现 |

## 相关 Block

- [Message Debug](Message_Debug.md)：检查输出 PMT
- [QT GUI Msg Push Button](QT_GUI_Msg_Push_Button.md)：发送按钮触发的消息

---

[返回 Block 目录](../../README.md#block-目录)
