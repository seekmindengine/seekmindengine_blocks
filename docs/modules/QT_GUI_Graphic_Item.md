# QT GUI Graphic Item 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Graphic Item

## 概览

QT GUI Graphic Item 显示一个图像文件，并可通过消息在运行时更换底图或添加、移动、删除覆盖图。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `qtgui_graphicitem` |
| 处理模型 | 消息 |
| 典型位置 | Sink / GUI |
| 执行支持 | Python |

## 何时使用

用于显示位图和基于文件的覆盖层。它不是通用的矢量绘图、文本、按钮、可拖拽对象或函数曲线组件。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `filename` | 消息 | PMT string | 可选；切换底图文件 |
| 输入 | `overlay` | 消息 | PMT dictionary 或 dictionary list | 可选；更新覆盖图 |

覆盖项使用 `filename`、`x`、`y`，并可带 `scalefactor`。同名文件作为覆盖项索引；把 `x` 和 `y` 都设为 `-1` 可删除该覆盖项。

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **File** | file_open | 无 | 初始图像文件 |
| **Scale Image** | bool | `False` | 是否缩放图像 |
| **Fixed Size** | bool | `False` | 未缩放时是否使用固定组件尺寸 |
| **Width** | int | `0` | 固定宽度 |
| **height** | int | `0` | 固定高度；界面参数名为小写 `height` |
| **GUI Hint** | gui_hint | 空 | Qt GUI 布局位置 |

## 工作原理

Block 创建 `qtgui.GrGraphicItem`。`filename` 端口更新主图，`overlay` 端口根据 dictionary 内容添加或更新覆盖图。它不声明颜色、边框、透明度、旋转、文本、点击或拖拽参数。

## 快速示例

```text
[QT GUI Graphic Overlay Sample Source] --overlay--> [QT GUI Graphic Item]
```

在 Graphic Item 的 File 中选择底图，Sample Source 发送覆盖项 dictionary。

## 性能与部署

大图像、频繁文件切换和大量覆盖项会增加 GUI 开销。文件路径必须对运行流程的进程可读。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 图像不显示 | File 路径错误或格式不可读 | 使用绝对路径验证文件可读性 |
| 覆盖项不出现 | 缺少 `filename`、`x` 或 `y` | 用 Message Debug 查看 dictionary |
| 覆盖项未删除 | 删除坐标未同时设为 `-1,-1` | 将 `x` 和 `y` 都设为 `-1` 后发送更新消息 |

## 相关 Block

- [QT GUI Graphic Overlay Sample Source](QT_GUI_Graphic_Overlay_Sample_Source.md)：生成示例覆盖消息
- [Message Debug](Message_Debug.md)：检查覆盖消息

---

[返回 Block 目录](../../README.md#block-目录)
