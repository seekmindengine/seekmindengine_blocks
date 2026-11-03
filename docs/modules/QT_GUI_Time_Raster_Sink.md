# QT GUI Time Raster Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / QT GUI Time Raster Sink

## 概览

QT GUI Time Raster Sink 把连续样本按固定列数排列成二维栅格，以颜色表示数值，适合观察重复结构和周期模式。支持 Byte、Float 及对应消息模式。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Instrumentation（仪器测量） |
| Block ID | `qtgui_time_raster_sink_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python |

## 何时使用

- 按已知帧长度观察重复序列。
- 显示 0/1 bit 流的结构。
- 比较周期样本中的幅度变化。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Number of Inputs-1` | 样本流 | byte 或 float | 对应流模式 |
| 输入 | `in` | 消息 | u8vector/f32vector 或相应 PDU | 对应消息模式 |

Byte 流显示实现按有符号 8 位值读取；观察 0/1 bit 时不受符号差异影响，完整 0..255 幅度数据需先明确转换规则。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Type** | 枚举 | 选择样本数据类型，必须与相连端口一致 | Float | ✗ |
| **Name** | 字符串 | 设置界面标题或实例名称 |  | ✗ |
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✗ |
| **Num. Rows** | 整数 | 设置网格行数 | 256 | ✓ |
| **Num. Cols** | 整数 | 设置网格列数 | 256 | ✓ |
| **X-Axis Label** | 字符串 | 设置 X 轴标题 |  | ✗ |
| **X-Axis Start Value** | float | 设置 X 轴起始值 | 0.0 | ✗ |
| **X-Axis End Value** | float | 设置 X 轴结束值 | 0.0 | ✗ |
| **Y-Axis Label** | 字符串 | 设置 Y 轴标题 |  | ✗ |
| **Y-Axis Start Value** | float | 设置 Y 轴起始值 | 0.0 | ✗ |
| **Y-Axis End Value** | float | 设置 Y 轴结束值 | 0.0 | ✗ |
| **Grid** | 枚举 | 控制绘图区网格是否显示 | No | ✗ |
| **Int. min** | 浮点数 | 设置整数输出下限 | -1 | ✗ |
| **Int. max** | 浮点数 | 设置整数输出上限 | 1 | ✗ |
| **Multiplier** | real_vector | 设置输入样本的乘法系数 | [] | ✓ |
| **Offset** | real_vector | 设置叠加到输出的直流偏置 | [] | ✓ |
| **Number of Inputs** | 整数 | 设置输入端口数量 | 1 | ✗ |
| **Update Period** | 浮点数 | 设置界面刷新周期，单位为秒 | 0.10 | ✓ |
| **GUI Hint** | gui_hint | 设置组件在界面布局中的位置与跨度 |  | ✗ |
| **Axis Labels** | 枚举 | 控制坐标轴标签是否显示 | Yes | ✗ |
| **Line 1..10 Label** | 字符串 | 设置各路曲线的图例名称 | 各通道预设值 | ✗ |
| **Line 1..10 Color** | 枚举 | 设置各路曲线的显示颜色 | 各通道预设值 | ✗ |
| **Line 1..10 Alpha** | float | 设置各路曲线的透明度 | 各通道预设值 | ✗ |

Line 1..10 为重复的通道样式参数，按当前输入数量使用；各通道初值以面板为准。

## 工作原理

每 Num. Cols 个样本形成一行，保留 Num. Rows 行用于显示。每路先按 Multiplier 与 Offset 做显示数值变换，再映射到 Int. min/Int. max 对应的颜色范围。

Sample Rate 用于时间轴标注，不改变输入速率。无跳帧的样本排列下，每行对应 Num. Cols/Sample Rate 秒；GUI 更新和缓冲不构成完整记录保证。此模块不执行 FFT，纵向历史也不是频谱。

## 快速示例

Byte Vector Source 设置 Vector=`[0,0,1,1,0,0,1,1]`、Repeat=Yes、Vector Length=1，经 Byte Throttle（800）接本模块。Type=Byte、Sample Rate=800、Num. Cols=8、Num. Rows=32、Int. min=0、Int. max=1。每行应重复同一条明暗模式。

把 Num. Cols 改为 7，模式会逐行偏移，可用于检查周期与行宽的关系。

## 性能与部署

较大的行列数和更多输入会增加缓冲与绘图开销。Multiplier/Offset 留空使用默认的 1/0；填写列表时必须满足当前输入通道的维度要求。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 图案逐行漂移 | 行宽与数据周期不一致 | 用已知序列调整 Num. Cols |
| 图像几乎只有一种颜色 | Int. min/max 不合适 | 按实际显示值设置范围 |
| 构造时报列表维度错误 | Multiplier/Offset 长度不匹配 | 先留空，再按输入通道配置 |
| 字节值大于 127 后变负 | 字节符号解释不同 | 转换为明确的 Float 幅度再显示 |

## 相关 Block

- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：查看波形。
- [QT GUI Waterfall Sink](QT_GUI_Waterfall_Sink.md)：显示频谱历史。
- [Vector Source](Vector_Source.md)：生成重复序列。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
