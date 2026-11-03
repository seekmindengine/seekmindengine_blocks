# Constant Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Constant Source

## 概览

Constant Source 模块产生恒定值的数据流，持续输出指定的常数值。支持 Complex、Float、Int、Short 等多种数据类型。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `analog_const_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **直流偏置**  
   为信号添加直流分量

2. **参考电平**  
   提供固定的参考值

3. **测试信号**  
   生成已知的常数用于测试

4. **初始化**  
   为某些算法提供初始常数值

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | 由数据类型参数决定 | 连续样本流端口 |

> 先核对输出类型与数据含义；离线处理可尽快运行，需要近似实时显示时再配置速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Output Type** | 枚举 | 选择输出端样本类型 | float | ✗ |
| **Constant** | 类型相关 | 设置参与运算的常量值 | 0 | ✓ |

## 参数说明

**1. Output Type**
- 输出数据类型
  - complex
  - float
  - int
  - short
  - byte

**2. Constant**
- 持续输出的常量值；其类型由 Output Type 决定。
## 工作原理

```
Constant Source → 持续输出常数值
output[n] = Constant (对所有 n)
```

## 快速示例

**示例 1：添加直流偏置**

```
[Signal Source] → [Add] → [QT GUI Time Sink]
                    ↑
            [Constant Source]
              (offset=1.0)
```

配置参数：
- Output Type: Float
- Constant: 1.0

**示例 2：复数常数**

```
[Constant Source] → [Multiply] → [Output Sink]
  (1+0j)              ↑
                [Audio Source]
```

配置参数：
- Output Type: Complex
- Constant: 1+0j

**示例 3：测试模块**

```
[Constant Source] → [Your Custom Block] → [Vector Sink]
  (test value)
```

配置参数：
- Output Type: Float
- Constant: 3.14159

## 性能与部署

1. **CPU 使用率**  
   非常低，只是简单的常数复制

2. **内存使用**  
   最小，只存储一个常数值

3. **与 Throttle 配合**  
   在仿真环境中需要 Throttle 限制速率

## 故障排查

**Q1: Constant Source 和 Signal Source (Constant) 有什么区别？**  
A: Constant Source 更简单高效，专门用于输出常数。Signal Source 功能更丰富但开销稍大。

**Q2: 如何动态改变常数值？**  
A: 通过消息端口发送新的常数值。

**Q3: 为什么需要 Throttle？**  
A: Constant Source 会尽可能快地产生数据，在仿真环境中会导致 CPU 100%。

**Q4: 可以输出复数常数吗？**  
A: 可以，选择 Complex 类型，输入如 1+2j 的复数值。

## 典型应用

**信号偏置：**
```
[Signal] → [Add Const] → [Output]
```

**增益控制：**
```
[Signal] → [Multiply Const] → [Output]
```

**测试输入：**
```
[Constant Source] → [DUT] → [Verification]
```

## 相关 Block

- [Signal Source](Signal_Source.md)：多功能信号发生器
- [Add Const](Add_Const.md)：为信号添加常数
- **Multiply Const**：信号乘以常数
- [Throttle](Throttle.md)：控制数据流速率

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
