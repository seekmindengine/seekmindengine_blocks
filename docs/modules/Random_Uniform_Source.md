# Random Uniform Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Random Uniform Source

## 概览

Random Uniform Source 连续生成区间 `[Minimum, Maximum)` 内的均匀分布伪随机整数，支持 Byte、Short 和 Int 输出。Maximum 是不包含的上界。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_random_uniform_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

- 生成 0/1 随机比特或整数符号索引。
- 为算法提供可重复的整数测试激励。

需要 Float 或 Complex 连续幅度噪声时，可使用 Noise Source 的 Uniform 模式。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | byte、short 或 int | 每个 item 为一个随机整数 |

模块没有 Sample Rate 参数；离线处理可尽快运行，需要近似实时节奏时再接 Throttle。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Output Type** | 枚举 | Int、Short 或 Byte | int | ✗ |
| **Minimum** | 整数 | 包含的下界 | 需填写 | ✗ |
| **Maximum** | 整数 | 不包含的上界，必须大于 Minimum | 需填写 | ✗ |
| **Seed** | 整数 | 伪随机序列的初始种子 | 0 | ✗ |

保证生成的值能由所选类型表示，避免整数转换改变数值。当前实现构造时直接使用 Seed，包括 0；相同版本、种子、类型和范围用于复现实验。

## 工作原理

设 a=Minimum、b=Maximum、M=b-a，输出可取 `a,a+1,...,b-1`，每个整数的理论概率为 `1/M`。

```text
均值 = (a+b-1)/2
方差 = (M²-1)/12
```

这些是离散均匀分布的统计量；Minimum=0、Maximum=1 时只会输出 0。

## 快速示例

设置 Output Type=Byte、Minimum=0、Maximum=2、Seed=42，依次连接 Head（Byte、Num Items=10000）和 File Sink（Byte）。文件应为 10000 字节，只包含 0 和 1；大样本下两者比例接近各一半。

保持配置不变重新启动，在同一运行环境中比较文件可检查可重复性。有限离线记录无需 Throttle。

## 性能与部署

模块在运行时持续产生整数，不预先存储一段循环播放的有限序列。性能需在目标类型和速率下测量；该伪随机源用于测试与仿真，不应作为密钥生成器。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 输出全为 0 | 范围为 [0,1) | 随机比特应设置 Maximum=2 |
| 无法连接 Float 显示器 | 输出为整数 | 记录后分析，或显式做类型转换 |
| 数据超出预期/绕回 | 数值超出目标整数类型范围 | 缩小范围或使用更宽类型 |
| 多个实例输出相同 | 使用了相同种子和参数 | 需要不同测试序列时设置不同种子 |

## 相关 Block

- [Random Source](Random_Source.md)：预生成有限随机序列并选择是否重复。
- [Noise Source](Noise_Source.md)：生成连续幅度噪声。
- [GLFSR Source](GLFSR_Source.md)：生成移位寄存器伪随机序列。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
