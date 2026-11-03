# Fast Multiply Const 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Fast Multiply Const

## 概览

Fast Multiply Const 模块将输入流的每个样本乘以指定常数，常用于增益调整、符号翻转、幅度缩放和简单标定。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Math Operators（数学运算） |
| Block ID | `blocks_multiply_const_xx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **增益控制**  
   对信号幅度进行固定比例缩放

2. **相位或符号调整**  
   对实数信号乘以 -1，或对复数信号乘以复常数

3. **单位换算**  
   将采样值转换到工程单位

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **IO Type** | 枚举 | 输入和输出类型：complex、float、int、short | float |
| **Constant** | 数值 | 乘法常数 | 0 |
| **Vector Length** | 整数 | 每个流项目的向量长度 | 1 |

## 工作原理

```
out[n] = in[n] * Constant
```

## 参数说明

**1. IO Type（输入输出类型）**
- 输入和输出类型保持一致
- complex 类型可用于复数增益、相位旋转或 IQ 缩放
- float 类型常用于音频和幅度缩放
- int/short 类型要注意乘法后的范围

**2. Constant（乘法常数）**
- 对每个样本或向量元素执行乘法
- Constant=1 表示原样通过
- Constant=0 会将输出全部置零
- complex 常数可同时改变幅度和相位

**3. Vector Length（向量长度）**
- 默认 1 表示标量流
- 大于 1 时逐元素乘以同一个 Constant

## 配置注意

1. **增益和溢出**  
   整数类型乘以较大常数时可能溢出。需要保真缩放时优先使用 float。

2. **复数相位旋转**  
   complex 信号乘以 `exp(j*theta)` 等价于相位旋转。

3. **与 Add Const 区别**  
   Multiply Const 改变比例；Add Const 改变偏置。

## 快速示例

```
[Audio Source] → [Fast Multiply Const] → [Audio Sink]
                  Constant=0.5
```

**示例 2：复数信号幅度缩放**

```
[USRP Source] → [Fast Multiply Const] → [QT GUI Sink]
                 Constant=0.1
```

**示例 3：相位翻转**

```
[Complex Signal] → [Fast Multiply Const] → [Processing]
                    Constant=-1
```

## 典型应用场景

- 音量或幅度调整
- 发射前降低基带幅度
- 将 ADC 计数换算为工程单位
- 复数相位或符号翻转

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: Constant 默认为 0 会发生什么？**  
A: 输出会全部变为 0。用于实际信号缩放时通常应设置为非零值。

**Q2: 和 Multiply 模块有什么区别？**  
A: 本模块乘以固定常数，计算更简单；Multiply 通常用于多路输入逐样本相乘。

## 相关 Block

- [Add Const](Add_Const.md)：加固定常数
- [Add](Add.md)：多路相加
- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：观察缩放效果

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
