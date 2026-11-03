# QT GUI Fast Auto-Correlator Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Fast Auto-Correlator Sink

## 概览

该 Block 接收复数样本流并显示快速自相关结果。它利用 Wiener-Khinchin 关系，通过功率谱的 FFT 计算自相关。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | GUI Widgets（界面组件） |
| Block ID | `qtgui_auto_correlator_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink / GUI |
| 执行支持 | Python |

## 何时使用

用于观察复数信号的周期性和自相关结构。它不是普通 Time Sink，也不提供多输入、窗函数、平均或归一化开关之外的通用频谱参数。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | 默认 | 样本流 | `complex` | 单路必需输入 |

## 参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| **Sample Rate** | float | `32000` | 输入样本率 |
| **FAC Size** | int | `512` | 快速自相关计算尺寸 |
| **FAC Decimation** | int | `10` | 自相关更新所用抽取设置 |
| **Output** | enum | `dB` | `dB` 或 `Normalized` |
| **Title** | string | 空 | 图标题 |
| **Show Grid** | enum | `Yes` | 是否显示网格 |
| **Auto-Scale** | enum | `Yes` | 是否自动缩放 Y 轴 |
| **Y Min** | float | `0` | 手动 Y 轴下限 |
| **Y Max** | float | `1` | 手动 Y 轴上限 |
| **GUI Hint** | gui_hint | 空 | Qt GUI 布局位置 |

## 工作原理

`FAC Size` 控制计算尺寸，相关观察长度由 Sample Rate 和 FAC Size 共同决定；具体显示尺度以组件实际坐标轴为准。

## 快速示例

```text
[Complex Signal Source] -> [Throttle] -> [QT GUI Fast Auto-Correlator Sink]
```

教程型纯软件流程可设置 Sample Rate 为 `32000`、FAC Size 为 `512`、FAC Decimation 为 `10`。

## 性能与部署

增大 FAC Size 或提高输入 item 率会增加计算和绘图负载。用目标机器测量，不承诺固定 CPU 百分比。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 无法连接 | 输入不是 `complex` | 在上游进行明确的类型转换 |
| 坐标范围不合适 | Auto-Scale 与 Y Min/Y Max 配置不合适 | 先启用 Auto-Scale，再按需要固定范围 |
| 更新过慢 | FAC Size、FAC Decimation 或输入速率影响 | 从默认值开始逐项调整 |

## 相关 Block

- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：观察时域样本
- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：观察频谱

---

[返回 Block 目录](../../README.md#block-目录)
