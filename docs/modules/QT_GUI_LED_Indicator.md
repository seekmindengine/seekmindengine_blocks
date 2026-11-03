# QT GUI LED Indicator 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI LED Indicator

## 概览

QT GUI LED Indicator 根据消息中的布尔值或整数切换开、关两种颜色，用于显示已经计算好的状态。它没有流输入，也不进行阈值检测、滞回或闪烁计时。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `qtgui_ledindicator` |
| 处理模型 | 消息 |
| 典型位置 | Control（控制或界面） |
| 执行支持 | 平台内置 |

## 何时使用

- 显示检测器或控制器发送的开关状态。
- 为按钮或消息链路提供可视反馈。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `state` | 消息 | PMT pair | 读取 pair 的 cdr，接受 bool 或整数 |

布尔值 True/False 分别对应开/关；整数只有 1 表示开，其余值表示关。car 部分不用于状态判定。不能直接接收 Float 样本流或单独的 PMT bool。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Label** | 字符串 | 设置界面或曲线显示名称 |  | ✗ |
| **Label Position** | 枚举 | 设置文字相对组件的位置 | Above | ✗ |
| **State** | 字符串 | 设置组件的初始开关状态 | False | ✓ |
| **On Color** | 枚举 | 设置开启状态的显示颜色 | green | ✗ |
| **Off Color** | 枚举 | 设置关闭状态的显示颜色 | red | ✗ |
| **Size** | 整数 | 设置界面组件尺寸 | 40 | ✗ |
| **Cell Alignment** | 枚举 | 设置组件在网格单元中的水平对齐方式 | Center | ✗ |
| **Vertical Alignment** | 枚举 | 设置组件在网格单元中的垂直对齐方式 | Center | ✗ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |

## 工作原理

初始颜色由 State 决定。收到消息后读取 pair 的值，转换为开关状态，分别使用 On Color 或 Off Color。需要阈值、滞回或告警保持时，在消息生产者中实现。

## 快速示例

将两个 QT GUI Msg Push Button 的 `pressed` 端口都连到 `state`：按钮一 Type=Boolean、Message Value=True，按钮二 Type=Boolean、Message Value=False；Message Property Name 可设为 `state`。

LED 保持 On Color=green、Off Color=red，点击两个按钮应分别变绿和变红。等价的输入消息为：

```python
pmt.cons(pmt.intern("state"), pmt.from_bool(True))
```

## 性能与部署

刷新由消息驱动；高频状态变化应由上游节流或合并。该组件需要图形界面，不用于无界面后台日志记录。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 不响应消息 | 发了标量而不是 pair | 把 bool/int 放在 pair 的 cdr |
| 整数 2 让指示灯关闭 | 只有整数 1 对应开 | 发送 bool 或 0/1 |
| 找不到 On Value/Off Value | 本模块没有阈值参数 | 在上游完成检测 |

## 相关 Block

- [QT GUI Msg Push Button](QT_GUI_Msg_Push_Button.md)：发送开关消息。
- [Message Debug](Message_Debug.md)：检查实际消息结构。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
