# QT GUI Msg Push Button 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Msg Push Button

## 概览

QT GUI Msg Push Button 在每次点击时，从 pressed 端口发送一个预设的键值对消息。键由 Message Property Name 指定，值及其类型由 Message Value 和 Type 决定。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `variable_qtgui_msg_push_button` |
| 处理模型 | 消息 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python |

## 何时使用

- 手动发送控制命令或状态值。
- 验证下游的消息处理逻辑。

按钮只负责发消息；启动、停止、切换流程等行为须由接收方实现。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `pressed` | 消息 | PMT pair | `(属性名符号, 类型化的值)` |

Type 可选 Integer、Float、String、Boolean。String 值以 PMT symbol 发送。模块不会自动在释放时发送第二条消息，也不自动在 True/False 之间切换。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Label** | 字符串 | 设置界面或曲线显示名称 |  | ✗ |
| **Type** | 枚举 | 选择消息值的类型：Integer、Float、String 或 Boolean | Integer | ✗ |
| **Message Property Name** | 字符串 | 设置输出消息的属性键名 | pressed | ✗ |
| **Message Value** | 类型相关 | 设置按钮触发时发送的消息值 | 1 | ✓ |
| **Button Background** | 枚举 | 设置按钮背景色 | default | ✗ |
| **Button Font Color** | 枚举 | 设置按钮文字颜色 | default | ✗ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |

## 工作原理

用户完成一次按钮点击后，组件以 Message Property Name 构造键，并将 Message Value 转为指定的 PMT 类型，组成 pair 后发布到 pressed。运行时修改 Message Value 影响后续点击发送的值。

## 快速示例

设置 Label=`设置增益`、Type=Integer、Message Property Name=`gain`、Message Value=10，将 `pressed` 连接到 Message Debug 的 `print`。

每次点击应输出等价于 `(gain . 10)` 的 PMT pair。若接实际设备或算法控制端口，键名、值类型和取值范围必须符合接收方接口。

## 性能与部署

按钮适合人工触发的低频控制。它需要 Qt 图形界面，不承担周期消息发生器或精确时序触发器的功能。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 点击后没有动作 | 下游没有处理该消息键或类型 | 先接 Message Debug 检查 pair |
| 每次发送相同值 | Message Value 未改变 | 按需求使用两个按钮或更新消息值 |
| 期待释放消息但没有 | 误解点击事件 | 需要按下/释放两种事件时使用专门控件 |

## 相关 Block

- [Message Debug](Message_Debug.md)：打印按钮消息。
- [QT GUI LED Indicator](QT_GUI_LED_Indicator.md)：显示 bool/int 状态。
- [QT GUI Message Edit Box](QT_GUI_Message_Edit_Box.md)：编辑后发送消息。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
