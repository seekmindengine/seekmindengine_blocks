# Frequency Shift 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Frequency Shift

## 概览

Frequency Shift 模块将输入信号在频域中进行平移，即改变信号的中心频率。这通过将输入信号与复指数信号相乘实现，是频率转换的基本操作。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Math Operators（数学运算） |
| Block ID | `blocks_freqshift_cc` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | 平台内置 |

## 何时使用

1. **频率转换**  
   将信号从一个频率搬移到另一个频率

2. **频带转换**  
   将目标信号频带搬移到便于分析的频率范围

3. **频率校正**  
   补偿频率偏差

4. **多频带处理**  
   在多频带信号中选择目标频率分量

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `complex` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `complex` | 连续样本流端口 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Sample Rate** | 浮点数 | 设置采样率，单位为 Sps | 32000 | ✓ |
| **Frequency Shift** | 浮点数 | 设置 Frequency Shift 数值；有效范围受当前 Block 配置约束 | 0.0 | ✓ |

## 工作原理

对第 n 个复数输入乘以旋转因子，逐样本相位增量为 `2π×Frequency Shift/Sample Rate`。正频移将频谱向正频率方向移动，负频移向负频率移动。模块不改变 item 率，也不滤除搬移后超出奈奎斯特范围的频谱。

当前面板只有 Sample Rate 和 Frequency Shift；没有 Phase 参数，也没有暴露消息端口。通过流程变量更新这两个参数时，模板会更新相位增量。

## 快速示例

Complex Signal Source 产生 32 kSps、频率 +5000 Hz 的单音。Frequency Shift 设置 Sample Rate=32000、Frequency Shift=−4000；输出经限速后接 QT GUI Frequency Sink（Bandwidth=32000、Center Frequency=0），谱峰应移到 +1000 Hz。

若测得输入频偏为 +1500 Hz，校正量应取 −1500 Hz。Float 信号要先用 Float To Complex 组成复数输入；如需单边解析信号，可使用 Hilbert 后再搬移。

## 性能与部署

1. **计算复杂度**  
   每个样本需要一次复数乘法

2. **数值精度**  
   长时间运行时注意相位累积误差

3. **频率范围**  
   频移量应在奈奎斯特范围内

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 频偏反而增大 | 频移符号错误 | 设为估计偏差的相反数 |
| 搬移量不对 | Sample Rate 与该段速率不一致 | 按重采样后的实际速率设置 |
| 找不到 Phase 或控制消息端口 | 当前面板没有这些接口 | 用 Frequency Shift 参数及变量更新 |
| Float 不能连接 | 输入必须为 Complex | 先明确所需复数转换方式 |

## 相关 Block

- **Multiply**：信号相乘
- [Signal Source](Signal_Source.md)：生成复指数信号
- **VCO**：压控振荡器，动态频移
- **Rotator**：相位旋转

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
