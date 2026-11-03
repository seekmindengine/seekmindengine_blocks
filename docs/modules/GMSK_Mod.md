# GMSK Mod 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / GMSK Mod

## 概览

GMSK Mod 将输入数据映射为 ±1 符号，经高斯成形与连续相位调制，输出复数基带信号。Unpack 决定输入是打包字节还是每 byte 一个 bit。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Modulators（调制器） |
| Block ID | `digital_gmsk_mod` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

1. **GMSK 发射链路**  
   将 bit/byte 数据调制为连续相位复数信号

2. **窄带数字通信仿真**  
   生成频谱相对紧凑的调制波形

3. **协议原型验证**  
   快速搭建发射端，验证前导码和包结构

4. **SDR 发射前级**  
   连接 UHD Sink 进行硬件发射实验

5. **教学观察**  
   对比 BT、Samples/Symbol 对频谱和波形的影响

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `byte` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `complex` | 连续样本流端口 |

> 收发两端应约定调制和编码方式；每符号采样数按当前处理段的采样率计算，接收环路参数则按输入信号与同步需求设置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Samples/Symbol** | 整数 | 每符号采样点数 | 2 |
| **BT** | 浮点数 | 高斯滤波器带宽时间积 | 0.35 |
| **Verbose** | 枚举 | 是否打印详细信息 | Off |
| **Log** | 枚举 | 是否输出调试日志 | Off |
| **Unpack** | 枚举 | 是否将输入 byte 拆为 bit | On |

## 工作原理

Unpack=On 时，按 MSB 优先将一个 byte 拆成 8 个 bit；Off 时每个输入 byte 必须为 0 或 1。bit 随后映射为 −1/+1，经高斯滤波和频率调制产生恒包络复数输出。

Samples/Symbol=S 必须为至少 2 的整数。On 时平均每个输入 byte 产生 8S 个输出样本；Off 时产生 S 个。BT 控制高斯成形的带宽时间积，较小值会收窄频谱并增加码间影响。

## 快速示例

Byte Vector Source 输出 `[0xA5]` 并循环，GMSK Mod 设置 Unpack=On、Samples/Symbol=2、BT=0.35。将输出接 Complex Throttle（32000）后分支到频谱观察与 File Sink。对应符号率为 16000 bit/s，输入打包字节率为 2000 byte/s。

改为循环 bit 序列 `[1,0,1,0,0,1,0,1]` 时，将 Unpack 设为 Off，可表示相同 bit 模式。滤波器启动瞬态后再比较信号。

## 性能与部署

按输出采样率配置显示、文件说明及硬件接口。Log=On 会写入内部调试数据文件，普通运行保持 Off。端到端比较须排除启动瞬态并校正符号、bit 和帧边界。

## 故障排查

**Q1: 输出为什么是 complex？**  
A: GMSK 调制结果是复数基带 IQ 信号。

**Q2: BT 越小越好吗？**  
A: 不一定。BT 小会压缩频谱，但可能增加码间干扰和接收难度。

**Q3: Unpack 应该开还是关？**  
A: 取决于输入是原始字节还是 0/1 bit 序列。不能只看端口类型，因为端口都是 byte。

**Q4: 可以直接接 Audio Sink 吗？**  
A: 不适合。输出是复数基带调制信号，不是音频。

## 相关 Block

- [GMSK Demod](GMSK_Demod.md)：GMSK 解调器
- [Continuous Phase Modulation](Continuous_Phase_Modulation.md)：通用 CPM 调制
- [Unpack K Bits](Unpack_K_Bits.md)：字节拆 bit
- [UHD: USRP Sink](UHD_USRP_Sink.md)：SDR 发射

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
