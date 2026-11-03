# QT GUI Graphic Overlay Sample Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Graphic Overlay Sample Source

## 概览

该 Block 是 Graphic Item 覆盖消息的示例 Source。它发送一个 dictionary 或 dictionary 列表，用于演示添加、移动和删除基于图像文件的覆盖项。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `qtgui_graphicoverlay` |
| 处理模型 | 消息 |
| 典型位置 | Source |
| 执行支持 | Python |

## 何时使用

用于学习或测试 QT GUI Graphic Item 的 overlay 消息格式。它不是频谱参考线、散点图、函数曲线或样本流 Source。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `overlay` | 消息 | PMT dictionary 或 dictionary list | 覆盖项更新消息 |

每个覆盖 dictionary 包含 `filename`、`x`、`y`，可选 `scalefactor`。将某个 filename 的坐标更新为 `-1,-1` 可请求删除它。

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Overlay Dict or List(dict)** | raw | 示例 dictionary 列表 | 要发送的一个或多个覆盖项 |
| **If List Send With Delay (sec)** | real | `1.0` | 列表各项之间的发送延迟 |
| **If List Repeat** | bool | `True` | 列表发送结束后是否重复 |

## 工作原理

Block 创建 `qtgui.GrGraphicOverlay`，把配置的 dictionary 或列表转换为 `overlay` 消息。列表可以用延迟逐项发送，从而演示同名覆盖图的位置变化。

## 快速示例

```text
[QT GUI Graphic Overlay Sample Source] --overlay--> [QT GUI Graphic Item]
```

```python
{'filename': 'marker.png', 'x': 10, 'y': 20, 'scalefactor': 1}
```

## 性能与部署

该 Block 面向示例和测试。生产流程可由自己的消息 Source 按相同契约生成 overlay 消息。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 没有输出连接 | 把 Block 误认为样本流 Source | 连接消息端口 `overlay` |
| 覆盖图片不可见 | filename 无法读取 | 在 Graphic Item 运行环境中检查路径 |
| 动画不重复 | If List Repeat 为 False | 按需求启用重复 |

## 相关 Block

- [QT GUI Graphic Item](QT_GUI_Graphic_Item.md)：接收并显示覆盖消息
- [Message Debug](Message_Debug.md)：观察实际消息

---

[返回 Block 目录](../../README.md#block-目录)
