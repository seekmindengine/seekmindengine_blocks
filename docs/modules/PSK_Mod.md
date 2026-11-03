# PSK Mod 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / PSK Mod

## 概览

PSK Mod 将打包字节流按高位优先展开为符号，经映射、可选差分编码和根升余弦脉冲成形，输出复数 PSK 基带样本。可配置 BPSK、QPSK、8PSK 等星座。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Modulators（调制器） |
| Block ID | `digital_psk_mod` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

- 将原始文件字节或协议字节调制为 PSK 波形。
- 评估星座阶数、Gray 映射、差分编码与成形带宽。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | byte | 每个 byte 含 8 个有效 bit，高位优先 |
| 输出 | `默认` | 样本流 | complex | 脉冲成形后的基带样本 |

输入不是“一字节一个符号索引”。若已有 0/1 bit 流，应先按高位优先打包为字节；原始文件字节可直接输入。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Number of Constellation Points** | 整数 | 星座点数，例如 2、4、8 | 8 |
| **Gray Code** | 枚举 | 是否使用 Gray 编码 | Yes |
| **Differential Encoding** | 枚举 | 是否启用差分编码 | Yes |
| **Samples/Symbol** | 整数 | 每符号采样点数 | 2 |
| **Excess BW** | 浮点数 | 成形滤波滚降系数 | 0.35 |
| **Verbose** | 枚举 | 是否打印详细信息 | Off |
| **Log** | 枚举 | 是否输出调试日志 | Off |

## 工作原理

```text
打包字节 → 每 log2(M) bit 分组 → Gray 映射（可选）
         → 差分编码（可选）→ 星座点 → RRC 成形/插值 → complex
```

设 M 为星座点数、k=log2(M)、S=Samples/Symbol，长期输出样本率约为输入字节率的 `8S/k` 倍。8PSK 的 3-bit 分组可跨字节边界；有限输入还需考虑分组余数和滤波瞬态。

星座阶数、映射和差分约定须与接收端一致。接收端 Samples/Symbol 应按到达接收机时的实际采样率计算。

## 快速示例

Random Source 设为 Byte、Minimum=0、Maximum=256、Num Samples=10000、Repeat=Yes，直接连接 PSK Mod。设置星座点数=4、Gray Code=Yes、Differential Encoding=Yes、Samples/Symbol=2、Excess BW=0.35。

输出接 Complex Throttle（32000）和 QT GUI Frequency Sink（Complex、Bandwidth=32000）。此时符号率为 16000 symbol/s，输入字节率约为 4000 byte/s。观察脉冲成形后的频谱；直接观察过采样波形的星座时，也会看到符号间过渡轨迹。

## 性能与部署

成形滤波和插值增加输出数据量。Log=On 会写内部调试数据，长时间运行应评估磁盘占用。持续输入速率、输出样本率和硬件端时钟必须匹配。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 大量重复符号或数据率偏低 | 将 0/1 或符号索引当成完整字节输入 | 先把 bit 流打包，或直接使用原始字节 |
| 解调 bit 系统性错误 | Gray/差分设置不匹配 | 对齐收发映射与编码 |
| 星座有过渡点 | 观察的是成形后的过采样波形 | 在符号同步后再判读星座点 |
| 输出与输入字节数量不对应 | 混淆字节、bit、符号和采样点 | 按 8S/log2(M) 核对长期速率 |

## 相关 Block

- [PSK Demod](PSK_Demod.md)：输出恢复的 0/1 bit。
- [Pack K Bits](Pack_K_Bits.md)：将 bit 流打包为字节。
- [Random Source](Random_Source.md)：生成测试字节。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
