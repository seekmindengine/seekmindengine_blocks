# Binary Slicer 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Binary Slicer

## 概览

Binary Slicer 模块将 float 输入按零门限切分为 byte 输出，通常负值判为 0，非负值判为 1。它常用于解调链路末端，把软判决信号转换为 bit 流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Demodulators（解调器） |
| Block ID | `digital_binary_slicer_fb` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **硬判决**  
   将连续幅度值转换为 0/1

2. **FSK/FM 解调后处理**  
   对鉴频输出进行二进制判决

3. **bit 流生成**  
   为 Pack K Bits 或协议解析提供输入

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `float` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `byte` | 连续样本流端口 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

本模块无可配置参数。

## 工作原理

```
out[n] = 1,  in[n] >= 0
out[n] = 0,  in[n] < 0
```

## 输入输出说明

**输入：**
- float 流
- 通常来自鉴频器、匹配滤波器、同步器或软判决输出

**输出：**
- byte 流
- 每个输出 byte 表示一个 bit 值 0 或 1
- 输出不是打包后的字节流，如果需要恢复字节，应继续使用 Pack K Bits

## 配置注意

1. **固定零门限**  
   本模块没有门限参数。需要非零门限时，可在前面使用 Add Const 做偏移。

2. **符号极性要确认**  
   如果 0/1 反了，可能需要乘以 -1 或在后续协议解析中反转 bit。

3. **输入幅度影响抗噪声能力**  
   幅度越接近 0，噪声越容易导致误判。判决前应保证同步和滤波效果。

4. **输出还不是包数据**  
   Binary Slicer 只做逐样本判决，不知道包边界、字节边界或协议结构。

## 快速示例

```
[Quadrature Demod] → [Binary Slicer] → [Pack K Bits] → [File Sink]
```

**示例 2：调整门限后判决**

```
[Float Signal] → [Add Const] → [Binary Slicer]
                 Constant=-0.2
```

**示例 3：接入帧同步**

```
[Demod] → [Binary Slicer] → [Correlate Access Code - Tag]
```

## 典型应用场景

- FSK/GMSK 鉴频后的硬判决
- 软判决数据转 bit 流
- Access Code 检测前处理
- bit 打包前处理

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 门限可以配置吗？**  
A: 此模块使用固定零门限。需要其他门限时，可先用 Add Const 调整偏置。

**Q2: 输出是 bit 还是 byte？**  
A: 输出端口类型是 byte，但每个 byte 表示一个 bit 值 0 或 1。

## 相关 Block

- [Quadrature Demod](Quadrature_Demod.md)：鉴频解调
- [Pack K Bits](Pack_K_Bits.md)：bit 打包
- [Add Const](Add_Const.md)：调整判决偏置

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
