# Integrate 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Integrate

## 概览

Integrate 模块对输入样本进行积分（累加）操作。它将指定数量的连续样本相加，然后输出结果并重置累加器。常用于能量检测和信号积分。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Math Operators（数学运算） |
| Block ID | `blocks_integrate_xx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **能量检测**  
   累加信号能量用于检测

2. **信号积分**  
   对信号进行数值积分

3. **平均计算**  
   配合除法实现移动平均

4. **脉冲积分**  
   积分脉冲信号

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **IO Type** | 枚举 | 选择输入输出样本类型，连接两端必须一致 | float | ✗ |
| **Decimation** | 整数 | 设置抽取倍数；输出速率为输入速率除以该值 |  | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |

## 参数说明

**1. IO Type**
- I/O 数据类型
  - complex
  - float
  - int
  - short

**2. Decimation**
- 抽取因子

**3. Vector Length**
- 向量长度

## 工作原理

```
输入: x[0], x[1], x[2], ..., x[N-1], x[N], ...
       └────────┬────────┘
            积分
输出: Σ(x[0]...x[N-1]), Σ(x[N]...x[2N-1]), ...
```

**数学表达式：**
```
y[k] = Σ(i=0 to N-1) x[k×N + i]
```

## 快速示例

**示例 1：能量检测**

```
[Signal] → [Complex to Mag²] → [Integrate] → [Threshold] → [Detector]
                                 (N=1024)
```

配置参数：
- Type: Float
- Num Items: 1024

**示例 2：移动平均**

```
[Signal] → [Integrate] → [Multiply Const] → [Output]
            (N=100)       (1/100)
```

配置参数：
- Type: Float
- Num Items: 100

**示例 3：脉冲积分**

```
[Pulse Signal] → [Integrate] → [Peak Detector]
                  (N=pulse_width)
```

## 输出速率

```
输出采样率 = 输入采样率 / Num_Items
```

例如：
- 输入：1 MHz
- Num Items：1000
- 输出：1 kHz

## 性能与部署

1. **数值溢出**  
   大量样本累加可能导致溢出，注意数据类型范围

2. **计算效率**  
   简单的累加操作，效率很高

3. **内存使用**  
   只需存储一个累加器变量

## 故障排查

**Q1: 如何实现移动平均？**  
A: Integrate 后除以 Num Items。

**Q2: 会溢出吗？**  
A: 可能会。使用足够大的数据类型（如 Float）或缩放输入。

**Q3: 输出速率是多少？**  
A: 输入速率 / Num Items。

**Q4: 可以实现滑动窗口积分吗？**  
A: 不能，这是非重叠的块积分。滑动窗口需要使用 Moving Average。

## 典型应用

**能量检测器：**
```
[Signal] → [Mag²] → [Integrate] → [Compare] → [Decision]
```

**平均功率：**
```
[Signal] → [Mag²] → [Integrate] → [Divide] → [Power]
```

**脉冲检测：**
```
[Pulse] → [Integrate] → [Threshold]
```

## 相关 Block

- **Moving Average**：滑动窗口平均
- [Add](Add.md)：简单相加
- **Multiply Const**：乘以常数（用于平均）

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
