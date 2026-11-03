# QT GUI Az-El Plot 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Az-El Plot

## 概览

QT GUI Az-El Plot 创建方位角/仰角极坐标图。方位角沿圆周顺时针表示，仰角映射为半径：90 度位于中心，0 度位于外圆；负仰角显示为外圆上的空心标记。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `variable_qtgui_azelplot` |
| 处理模型 | 消息 |
| 典型位置 | Sink / GUI |
| 执行支持 | Python |

## 何时使用

用于显示已经计算出的方位角和仰角结果。该 Block 只负责可视化，不执行测向、波束形成、轨迹管理或三维定位。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `azel` | 消息 | PMT pair | car 为包含 `az`、`el` 的字典；cdr 不参与绘图 |

`az` 是方位角、`el` 是仰角，单位均为度。不要将字典放到 cdr，或改用 azimuth/elevation 键名。

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Label** | string | 空 | 图形标签 |
| **Background** | enum | `white` | 背景颜色 |
| **Dot Color** | enum | `ro` | 标记颜色和圆形样式 |
| **GUI Hint** | gui_hint | 空 | 在 Qt GUI 容器中的布局位置 |

## 工作原理

每条消息替换当前标记。方位角从北向顺时针计量；仰角 90° 位于中心，0° 及负值在边缘显示空心标记，超过 90° 的值按 90° 显示。该组件不保留历史轨迹。

## 快速示例

由消息生产者将以下消息发送到 azel：

```python
metadata = pmt.to_pmt({"az": 90.0, "el": 45.0})
message = pmt.cons(metadata, pmt.PMT_NIL)
```

应在东方、中心到边缘约一半的位置出现标记。将 el 改为 -5.0，标记应变为东方边缘的空心圆。

## 性能与部署

消息更新速度由发送端决定。若界面负载过高，应在发送端减少更新频率；本 Block 没有 Update Period 参数。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无标记 | 消息格式不符合 AzElPlot API | 用当前产品版本的示例或实现核对 payload |
| 组件未出现 | GUI Hint 或 Qt 容器配置错误 | 先清空 GUI Hint 使用默认布局 |
| 期待轨迹但只有单点 | 把显示块误当成轨迹处理器 | 在上游实现状态和轨迹逻辑 |

## 相关 Block

- [QT GUI Graphic Item](QT_GUI_Graphic_Item.md)：显示位图及消息驱动覆盖层
- [Message Debug](Message_Debug.md)：查看实际 PMT 消息

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
