# QT GUI Constellation Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Constellation Sink

## 概览

QT GUI Constellation Sink 把复数样本绘制在 I/Q 平面上。它可从一个或多个 complex 样本流输入，也可在 Complex Message 模式下接收消息输入。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_const_sink_x` |
| 处理模型 | 连续样本流或消息，取决于 Type |
| 典型位置 | Sink / GUI |
| 执行支持 | Python |

## 何时使用

用于观察复数样本分布、调制星座和同步前后的 I/Q 变化。该显示不能单独完成 EVM 测量、符号判决或载波恢复。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | 默认 | 样本流 | `complex` | Type=Complex 时，数量由 Number of Inputs 决定 |

运行接口支持 `in` 复数样本消息（c32vector 或相应 PDU），但当前编辑器定义未暴露该端口；本页示例使用流模式。


## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Type** | enum | `Complex` | Complex stream 或 Complex Message |
| **Name** | string | 空 | 图标题 |
| **Number of Points** | int | `1024` | 流模式下每次显示的点数 |
| **Grid** | enum | `No` | 显示网格 |
| **Autoscale** | enum | `No` | 自动缩放坐标轴 |
| **Y min** | real | `-2` | Y 轴下限 |
| **Y max** | real | `2` | Y 轴上限 |
| **X min** | real | `-2` | X 轴下限 |
| **X max** | real | `2` | X 轴上限 |
| **Number of Inputs** | int | `1` | 流模式输入数量 |
| **Update Period** | real | `0.10` s | GUI 更新周期 |
| **GUI Hint** | gui_hint | 空 | Qt GUI 布局位置 |
| **Trigger Mode** | enum | `Free` | Free、Auto、Normal 或 Tag |
| **Trigger Slope** | enum | 初始字段需重新选择 | Positive 或 Negative；首次配置时显式选择，与当前定义的初始字段不一致 |
| **Trigger Level** | float | `0.0` | 触发电平 |
| **Trigger Channel** | int | `0` | 触发输入索引 |
| **Trigger Tag Key** | string | 空 | Tag 模式使用的 key |
| **Legend** | enum | `Yes` | 显示图例 |
| **Axis Labels** | enum | `Yes` | 显示坐标轴标签 |
| **Line 1..10 Label** | string | 空 | 每个输入的图例名称 |
| **Line 1..10 Width** | int | `1` | 每个输入的线宽 |
| **Line 1..10 Color** | enum | 各通道预设色 | 每个输入的颜色 |
| **Line 1..10 Style** | enum | `None` | 每个输入的线型 |
| **Line 1..10 Marker** | enum | `Circle` | 每个输入的点标记 |
| **Line 1..10 Alpha** | float | `1.0` | 每个输入的不透明度 |

Line 参数分别用于最多 10 路输入，此处合并展示相同字段。

## 工作原理

对每个 complex 样本 `I+jQ`，横轴显示 I，纵轴显示 Q。Number of Points 和 Update Period 控制一次绘制的数据量与刷新周期；它们不执行同步或判决。

## 快速示例

```text
[Complex Modulated Signal] -> [QT GUI Constellation Sink]
```

从 Type=`Complex`、Number of Inputs=`1`、Number of Points=`1024` 和坐标范围 `[-2,2]` 开始。

## 性能与部署

增大点数、输入数量或缩短 Update Period 会增加 GUI 开销。用目标机器实测更新流畅度。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无法连接 float | 该显示要求 complex 流或 complex message | 提供 complex 输入 |
| 图上只有一个点 | 输入为常量或尚未形成调制星座 | 在上游检查样本 |
| Tag 触发无效 | Trigger Tag Key 或标签传播错误 | 用 Tag Debug 验证 key 和 offset |

## 相关 Block

- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：观察 I/Q 随时间变化
- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：观察频谱
- [Costas Loop](Costas_Loop.md)：载波相位恢复

---

[返回 Block 目录](../../README.md#block-目录)
