# QT GUI Number Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Number Sink

## 概览

QT GUI Number Sink 显示输入的数值，可对输入做单极点平滑，并用数字及水平或垂直条形图呈现。显示功率、频率、电压等物理量时，需要上游先完成对应的测量和标定。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_number_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

- 显示算法已经输出的幅度、频率或统计结果。
- 比较多个输入的数值。
- 用 Factor 和 Unit 调整显示比例与单位文字。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Number of Inputs-1` | 样本流 | float、short 或 byte | 每路为标量数值；不支持 complex |

需要显示复数幅度时，先使用 Complex to Mag。Unit 只改变单位文字，不会把未经标定的输入转换为真实物理测量值。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **Input Type** | 枚举 | 选择输入端样本类型 |  | ✗ |
| **Autoscale** | 枚举 | 控制坐标范围是否根据输入数据自动调整 | No | ✗ |
| **Average** | float | 单极点平滑系数；0 关闭平滑，使用时取 0<Average≤1 | 0 | ✓ |
| **Graph Type** | 枚举 | 选择图形的显示形式 |  | ✗ |
| **Number of Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Min** | float | 设置有效范围下限 | -1 | ✗ |
| **Max** | float | 设置有效范围上限 | 1 | ✗ |
| **Update Period** | float | 设置界面刷新周期，单位为秒 | 0.10 | ✓ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |
| **Line 1..10 Label** | 字符串 | 设置各路曲线的图例名称 | 各通道预设值 | ✗ |
| **Line 1..10 Unit** | 字符串 | 设置各路曲线的显示单位 |  | ✗ |
| **Line 1..10 Color** | 枚举 | 设置各路曲线的显示颜色 | 各通道预设值 | ✗ |
| **Line 1..10 Factor** | float | 设置各路曲线的数值缩放系数 | 1 | ✗ |

Line 1..10 为重复的通道样式参数，按当前输入数量使用；各通道初值以面板为准。

## 工作原理

Average=α>0 时，逐样本更新 `y[n]=αx[n]+(1-α)y[n-1]`；系数越小，平滑越强。Average=0 时关闭平滑，在界面更新时读取当前处理批次中的一个样本。它不是“最近 N 个样本的算术平均”。

显示值再乘以对应 Line Factor，附加 Unit 文字。Graph Type 只有 Horizontal、Vertical 和 None；None 保留数值显示，不绘制条形图。Min/Max 用于显示范围，不裁剪上游数据。

## 快速示例

Constant Source 设置 Float、Constant=2.5，经过 Float Throttle（Sample Rate=1000）连接本模块。设置 Input Type=Float、Average=0、Graph Type=Horizontal、Min=0、Max=5、Line 1 Factor=1、Line 1 Unit=`V`。

显示应为约 2.5 V。把 Factor 改为 1000、Unit 改为 mV 后，应显示约 2500 mV；这里假定上游数值已经按伏特标定。

## 性能与部署

Update Period 控制界面更新节奏；Average>0 时，后台仍对输入样本进行平滑。需要每个样本都被记录时，应另接 File Sink，不能用屏幕刷新代替采集记录。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| Average=100 等配置失败或结果异常 | 将系数误当成样本数 | 使用 0 或 (0,1] 内系数 |
| 数值抖动 | 关闭平滑或输入波动较大 | 在上游计算合适测量量，或减小正的 Average |
| 无法连接复数流 | 输入类型不支持 | 先计算需要显示的实数测量量 |
| 标注 dBm 却数值不对 | 只改变了 Unit | 在上游完成校准和对数功率换算 |

## 相关 Block

- [Complex to Mag](Complex_to_Mag.md)：将复数流转换为幅度。
- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：观察波形。
- [Constant Source](Constant_Source.md)：提供固定测试值。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
