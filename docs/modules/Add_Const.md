# Add Const 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Add Const

## 概览

Add Const 模块对每个输入样本加上指定常数，输出类型与输入类型一致。它适合做直流偏置、零点平移、简单标定和测试数据构造。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Math Operators（数学运算） |
| Block ID | `blocks_add_const_vxx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **直流偏置**  
   给信号增加固定 DC 分量

2. **数值平移**  
   将数据整体上移或下移

3. **测试构造**  
   快速生成带偏置的测试流

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **IO Type** | 枚举 | 输入和输出数据类型：complex、float、int、short、byte | float |
| **Constant** | 数值 | 要加到每个样本上的常数 | 0 |
| **Vector Length** | 整数 | 每个流项目包含的元素个数 | 1 |

## 工作原理

```
out[n] = in[n] + Constant
```

对于复数类型，Constant 可以是复数；对于整型类型，应注意溢出和取值范围。

## 参数说明

**1. IO Type（输入输出类型）**
- 输入和输出类型相同
- complex 类型可用于给 IQ 信号添加复数偏置
- float 类型常用于实数偏置或零点校正
- byte/short/int 类型要注意范围限制

**2. Constant（常数）**
- 加到每个样本或向量元素上的固定值
- 类型应与 IO Type 兼容
- 对 complex 可写成 `1+2j` 这类复数表达式

**3. Vector Length（向量长度）**
- 默认 1 表示标量流
- 大于 1 时对向量中每个元素分别加 Constant

## 配置注意

1. **整数溢出**  
   对 byte、short、int 使用较大 Constant 时，可能出现截断或回绕。

2. **偏置不是增益**  
   Add Const 改变直流偏移，不改变信号幅度比例。幅度缩放应使用 Fast Multiply Const。

3. **复数偏置含义**  
   给 complex 信号加常数会同时影响 I/Q 平面上的中心位置，可用于构造或校正 DC offset。

## 快速示例

```
[Signal Source] → [Add Const] → [QT GUI Time Sink]
                   Constant=1.0
```

**示例 2：复数 DC 偏移测试**

```
[Signal Source] → [Add Const] → [QT GUI Constellation Sink]
                   Constant=0.1+0.05j
```

**示例 3：判决门限调整**

```
[Quadrature Demod] → [Add Const] → [Binary Slicer]
                     Constant=-threshold
```

## 典型应用场景

- 给测试信号增加 DC 分量
- 将传感器读数做零点校正
- 在 Binary Slicer 前改变等效判决门限
- 构造星座图偏移测试样本

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 可以运行时修改 Constant 吗？**  
A: 可以，模块支持通过回调更新常数值。

**Q2: byte 类型加常数会怎样？**  
A: 输出仍为 byte 类型，数值范围有限，配置时需要避免不期望的截断或回绕。

## 相关 Block

- [Add](Add.md)：多路输入相加
- [Fast Multiply Const](Fast_Multiply_Const.md)：常数乘法
- [Constant Source](Constant_Source.md)：常数信号源

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
