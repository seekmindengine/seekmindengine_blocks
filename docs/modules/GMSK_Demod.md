# GMSK Demod 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / GMSK Demod

## 概览

GMSK Demod 模块将复数基带 GMSK 信号解调为 byte 输出。它封装了 GMSK 接收链路中常用的鉴频、符号同步和判决处理，适合快速构建 GMSK 接收机原型。

输出端口类型是 byte，但每个 byte 表示一个恢复出的 0/1 bit。若要恢复原始字节，还需要 Pack K Bits、帧同步或协议解析。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Demodulators（解调器） |
| Block ID | `digital_gmsk_demod` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

1. **GMSK 接收链路**  
   将复数 IQ GMSK 信号恢复为 bit 流

2. **端到端仿真**  
   与 GMSK Mod 组合测试链路参数

3. **SDR 数据解调**  
   对 USRP Source 或文件中的 GMSK IQ 数据进行解调

4. **窄带数字通信实验**  
   验证 BT、Samples/Symbol、频偏等因素影响

5. **协议解析前级**  
   为 Access Code、Pack Bits 和包解析提供 bit 输入

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `complex` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `byte` | 连续样本流端口 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Samples/Symbol** | 整数 | 每符号采样点数，需与输入信号匹配 | 2 |
| **Gain Mu** | 浮点数 | 时钟恢复相关增益 | 0.175 |
| **Mu (Unused)** | 浮点数 | 保留字段，当前实现不使用 | 0.5 |
| **Omega Relative Limit** | 浮点数 | 符号速率相对偏差限制 | 0.005 |
| **Freq Error** | 浮点数 | 预期 bit 率相对误差（无量纲） | 0.0 |
| **Verbose** | 枚举 | 是否打印详细信息 | Off |
| **Log** | 枚举 | 是否输出调试日志 | Off |

## 参数说明

**1. Samples/Symbol**
- 必须与输入信号的实际过采样率一致
- 若前级进行了重采样，需按重采样后采样率计算

**2. Gain Mu**
- 影响符号时钟恢复的调整速度
- 值过大可能抖动，过小可能锁定慢
- 建议从默认值开始调整

**3. Omega Relative Limit**
- 限制符号速率估计偏离范围
- 输入采样率或符号率误差较大时可能需要调整

**4. Freq Error**
- 修正名义每符号输入样本数：`omega=Samples/Symbol×(1+Freq Error)`
- 这是 bit 率相对误差，不是载波频偏 Hz；载波频偏需要在前级另行校正

## 工作原理

```
complex GMSK 输入 → 鉴频/同步 → bit 判决 → byte 输出
```

内部使用鉴频、M&M 定时误差检测的 Symbol Sync 和 Binary Slicer。Gain Mu 被换算为定时环路带宽，Omega Relative Limit 用于限定样本/符号估计的变化；Mu (Unused) 不参与计算。

## 快速示例

**示例 1：仿真解调**

```
[Random Source] → [GMSK Mod] → [Channel Model] → [GMSK Demod] → [Pack K Bits]
```

配置要点：
- Mod/Demod 的 Samples/Symbol 一致
- 输入 bit 组织方式与后处理一致

**示例 2：SDR 接收**

```
[UHD: USRP Source] → [Low Pass Filter] → [GMSK Demod] → [Correlate Access Code - Tag]
```

前级应完成调谐、滤波和大频偏校正。

**示例 3：文件 IQ 解调**

```
[File Source] → [Throttle] → [GMSK Demod] → [Pack K Bits] → [File Sink]
```

文件数据类型必须是 complex IQ，并且采样率对应 Samples/Symbol。

## 调试建议

1. 先使用 GMSK Mod + GMSK Demod 做无噪声闭环
2. 确认 Samples/Symbol 设置正确
3. 加入噪声前先确认 bit 打包/拆包顺序
4. 真实信号解不出时，先观察频谱和时域幅度
5. 频偏明显时先用 Frequency Shift 校正

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 输出是原始字节吗？**  
A: 通常不是。输出一般是 0/1 bit，需要 Pack K Bits 才能恢复字节。

**Q2: 为什么和 GMSK Mod 直连也解不对？**  
A: 检查 Samples/Symbol、Unpack 设置和后端 Pack K Bits 的 bit 顺序。

**Q3: Gain Mu 怎么调？**  
A: 从默认值开始。锁定慢可适当增大；抖动明显可减小。

**Q4: 能处理大频偏吗？**  
A: 容忍度有限。大频偏应先在前级校正。

## 典型应用场景

**GMSK 包接收：**

```
[Filtered IQ] → [GMSK Demod] → [Correlate Access Code - Tag] → [Packet Parser]
```

**闭环测试：**

```
[Vector Source] → [GMSK Mod] → [GMSK Demod] → [Message/File Check]
```

## 相关 Block

- [GMSK Mod](GMSK_Mod.md)：GMSK 调制器
- [Pack K Bits](Pack_K_Bits.md)：bit 打包
- [Correlate Access Code - Tag](Correlate_Access_Code_Tag.md)：帧同步
- [Frequency Shift](Frequency_Shift.md)：频偏校正

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
