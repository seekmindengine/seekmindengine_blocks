# Continuous Phase Modulation 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Continuous Phase Modulation

## 概览

Continuous Phase Modulation 模块将 byte 符号流调制为连续相位复数基带信号。CPM 通过保持相位连续来获得较好的频谱特性，GMSK 就是常见的 CPM 形式之一。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Modulators（调制器） |
| Block ID | `digital_cpmmod_bc` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **CPM 信号生成**  
   生成 LREC、LRC、LSRC、TFM、Gaussian 等相位响应信号

2. **频谱受限调制**  
   降低相位突变带来的带外扩展

3. **数字通信仿真**  
   构建连续相位调制发射链路

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `byte` | 按有符号 8-bit 幅值解释的符号，不是打包 bit |
| 输出 | `默认` | 样本流 | `complex` | 连续样本流端口 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **CPM Type** | 枚举 | 相位响应类型 | LREC |
| **Modulation Index** | 浮点数 | 调制指数 h | 0.5 |
| **Samples/Symbol** | 整数 | 每符号采样点数 | 4 |
| **Pulse Duration (Symbols)** | 整数 | 相位脉冲持续符号数 L | 4 |
| **Phase Response Parameter (BT or Beta)** | 浮点数 | Gaussian BT 或其他响应参数 | 0.3 |

## 工作原理

输入 byte 按有符号 char 转为 Float，直接进入插值成形滤波器，再按 π×h 的灵敏度进行相位累积。二进制 CPM 常使用 −1/+1 符号，对应原始 byte 0xFF/0x01；不能把 0/1 或任意打包字节直接当成同样的符号。输出率为输入符号率乘 Samples/Symbol。

模块根据输入符号、调制指数和相位响应滤波器累积相位，并输出：

```
out[n] = exp(j × phase[n])
```

## 快速示例

Byte Vector Source 循环输出 `[255,1,255,1]`，在该接口中表示 `[−1,+1,−1,+1]`。CPM Type=LREC、Modulation Index=0.5、Samples/Symbol=4、Pulse Duration (Symbols)=1。输出经 Complex Throttle（32000）送到 QT GUI Frequency Sink，Bandwidth=32000；对应输入符号率为 8000 symbol/s。

比较 Gaussian 响应时再调整类型、脉冲长度与 BT，保持输出采样率一致。

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: Samples/Symbol 越大越好吗？**  
A: 更高采样点数能更细致地表示波形，但计算量和采样率也会增加。

**Q2: Gaussian 类型和 GMSK Mod 有什么关系？**  
A: GMSK 可看作 Gaussian 滤波的 MSK，GMSK Mod 是更直接的专用封装。

## 相关 Block

- [GMSK Mod](GMSK_Mod.md)：GMSK 调制器
- [Random Source](Random_Source.md)：随机符号源
- [QT GUI Frequency Sink](QT_GUI_Frequency_Sink.md)：频谱观察

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
