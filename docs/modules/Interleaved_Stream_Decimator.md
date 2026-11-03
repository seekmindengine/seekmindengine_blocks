# Interleaved Stream Decimator 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Interleaved Stream Decimator

## 概览

Interleaved Stream Decimator 对以 byte 或 short 存储的交错 I/Q 流进行成对抽取。输入布局为 `I0,Q0,I1,Q1,...`，每 Decimation 对保留第一对，输出仍保持 I/Q 交错布局。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Resamplers（重采样器） |
| Block ID | `ival_decimator` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | 平台内置 |

## 何时使用

- 对已限制带宽的整数 I/Q 数据降低存储或传输速率。
- 在保留原始 byte/short 格式的情况下进行成对样本选择。

本模块不包含抗混叠滤波，也没有通道数或相位偏移参数。任意多通道交织数据应按其布局另行拆分处理。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | byte 或 short | 连续两个标量 item 构成一对 I/Q |
| 输出 | `默认` | 样本流 | 与输入相同 | 保留的完整 I/Q 对 |

若输入 I/Q 对的速率为 Fs，标量 item 率为 2Fs；输出 I/Q 对速率为 Fs/Decimation。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Input Type** | 枚举 | byte 或 short；输出使用相同类型 | byte | ✗ |
| **Decimation** | 整数 | 每组 I/Q 对的抽取倍数，必须至少为 1 | 1 | ✗ |

## 工作原理

令 D=Decimation，输出第 k 对为输入第 kD 对：

```text
out[2k]   = in[2kD]
out[2k+1] = in[2kD+1]

D=2
输入: [I0,Q0, I1,Q1, I2,Q2, I3,Q3]
输出: [I0,Q0, I2,Q2]
```

模块直接复制选中的两个整数，不对数值做插值、缩放或 FIR 运算。

## 快速示例

Vector Source 设置 Output Type=Byte、Vector=`[10,11,20,21,30,31,40,41]`、Vector Length=1、Repeat=No。连接 Input Type=Byte、Decimation=2 的本模块，再接 Byte File Sink。文件应包含 `[10,11,30,31]`。

用 Deinterleave（两路、Block Size=1）拆分结果时，I 路为 `[10,30]`，Q 路为 `[11,31]`。

## 性能与部署

输出字节率约为输入的 1/Decimation。抽取前必须确保信号带宽满足新的采样率要求；不能用降低数据量替代抗混叠滤波。有限输入应包含完整的 I/Q 对，验证时选取能整组抽取的数据长度。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| I/Q 互换或配对错误 | 输入起点或存储布局不符 | 检查第一个元素是否为 I，以及整数宽度 |
| 频谱出现折叠 | 抽取前带宽过大 | 在正确的 I/Q 信号域先限制带宽 |
| 无法连接 Float/Complex 流 | 输入类型不支持 | 使用匹配的滤波抽取模块 |
| 末尾数据不足 | 没有完整的抽取组 | 用完整组数检查有限数据输出 |

## 相关 Block

- [Deinterleave](Deinterleave.md)：拆开交织数据。
- [Interleave](Interleave.md)：构成交织数据。
- [Decimating FIR Filter](Decimating_FIR_Filter.md)：带 FIR 滤波的抽取。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
