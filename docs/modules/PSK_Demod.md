# PSK Demod 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / PSK Demod

## 概览

PSK Demod 对复数 PSK 基带信号进行增益调整、频率与定时恢复、星座判决及解映射，输出 0/1 bit 流。每个输出 byte 只承载一个 bit，符号内按高位优先输出。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Demodulators（解调器） |
| Block ID | `digital_psk_demod` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

- 构建与 PSK Mod 配套的接收链路。
- 从 PSK 波形恢复 bit，交给同步和协议解析模块。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | complex | 成形后的 PSK 基带信号 |
| 输出 | `默认` | 样本流 | byte | 每个 item 为一个恢复的 bit，值为 0 或 1 |

M 阶 PSK 每个恢复符号输出 log2(M) 个 bit item。恢复文件字节前，还需完成帧/字节对齐并用 Pack K Bits（K=8）打包。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Number of Constellation Points** | 整数 | 星座点数 | 4 |
| **Differential Encoding** | 枚举 | 是否启用差分解码 | Yes |
| **Samples/Symbol** | 整数 | 输入每符号采样点数 | 2 |
| **Excess BW** | 浮点数 | 成形滤波滚降系数 | 0.35 |
| **Frequency BW** | 浮点数 | 面板保留字段；当前生成模板未传入此值，修改它不改变频率环路配置 | 0.0628 |
| **Timing BW** | 浮点数 | 定时恢复环路带宽 | 0.0628 |
| **Phase BW** | 浮点数 | 相位恢复环路带宽 | 0.0628 |
| **Gray Code** | 枚举 | 是否按 Gray 编码解映射 | Yes |
| **Verbose** | 枚举 | 是否打印详细信息 | Off |
| **Log** | 枚举 | 是否输出调试日志 | Off |

## 工作原理

```text
complex → AGC → 频率恢复 → RRC 匹配滤波/定时恢复
        → 星座判决 → 差分解码（可选）→ 解映射 → 0/1 bit 流
```

Samples/Symbol 至少为 2，并与输入的实际过采样率一致。Timing BW 和 Phase BW 分别影响定时与相位恢复；Frequency BW 当前未由流程模板传给构造器，频率环路使用运行接口默认值。

同步过程会引入延迟和启动误码，不能将输出第一个 bit 直接视为输入第一个 bit。

## 快速示例

将重复的 Byte 测试序列送入 PSK Mod，Mod 与 Demod 均设置星座点数=4、Gray Code=Yes、Differential Encoding=Yes、Samples/Symbol=2、Excess BW=0.35。中间以 Complex Throttle（32000）控制观察速度，解调输出接 Byte File Sink 或 bit 检查器。

先检查输出只有 0/1，再用已知前导码对齐收发 bit 序列、排除启动瞬态，最后计算误码；不要直接比较输入字节文件与未打包的解调输出。

## 性能与部署

实际锁定能力取决于频偏、定时误差、信噪比和成形匹配。误码评估要说明同步、丢弃启动样本与对齐方法；Log=On 会增加内部数据记录开销。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 输出文件大小远大于输入 | 一字节只表示一个 bit | 完成帧对齐后按 8 bit 打包 |
| 首段误码或位置偏移 | 环路启动和滤波延迟 | 用前导码对齐后再比较 |
| 调 Frequency BW 没有效果 | 当前模板没有传入该字段 | 不把该字段作为有效调参手段 |
| 持续误码 | 映射、差分、采样率或同步条件不符 | 先用无噪声的配套流程核对 |

## 相关 Block

- [PSK Mod](PSK_Mod.md)：生成配套测试波形。
- [Pack K Bits](Pack_K_Bits.md)：把恢复的 bit 打包为字节。
- [Correlate Access Code - Tag](Correlate_Access_Code_Tag.md)：标记同步码。

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
