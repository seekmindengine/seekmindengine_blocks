# Costas Loop 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Costas Loop

## 概览

Costas Loop 模块用于复数 PSK 等调制信号的载波恢复。它估计输入信号中的残余相位和频率误差，并输出校正后的复数基带信号。接收机中常将它放在匹配滤波和符号同步附近，用于改善星座稳定性。

Costas Loop 不是通用频谱搬移器；它是闭环同步模块，适合跟踪相对较小的残余频偏和相位误差。大频偏通常应先通过频率估计、Frequency Shift 或调谐参数修正。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Synchronizers（同步器） |
| Block ID | `digital_costas_loop_cc` |
| 处理模型 | 连续样本流与消息 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **PSK 载波恢复**  
   校正 BPSK、QPSK、8PSK 等信号的相位旋转

2. **残余频偏跟踪**  
   跟踪前端校正后仍存在的小频偏

3. **星座稳定**  
   让星座点聚集到稳定角度，便于判决

4. **同步诊断**  
   使用 frequency、phase、error 输出观察环路状态

5. **接收机模块化设计**  
   与 Symbol Sync、RRC Filter、Constellation Decoder 等组合

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | complex | 需要载波恢复的基带信号 |
| 输入 | `noise` | 消息 | PMT real | 可选，噪声功率的 dB 值；供 Use SNR 模式使用 |
| 输出 | `0` | 样本流 | complex | 相位校正后的基带信号 |
| 输出 | `frequency`（1） | 样本流 | float | 可选，环路频率估计，单位 rad/sample |
| 输出 | `phase`（2） | 样本流 | float | 可选，环路相位估计，单位 rad |
| 输出 | `error`（3） | 样本流 | float | 可选，限制在 [-1,1] 的鉴相误差 |

可选流输出按端口序号连续连接。若要观察 error，应同时连接 0、1、2、3；不需要显示的诊断输出可接 Float Null Sink。频率估计换算为 Hz：`frequency×该段采样率/(2π)`。

noise 接收实数 PMT，例如 `pmt.from_double(-20.0)`，内部换算为线性噪声功率 0.01；它不是任意字典，也不是直接传入的 SNR 数值。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **Loop Bandwidth** | 浮点数 | 正数环路带宽参数，影响跟踪速度和抖动，不是直接以 Hz 表示的带宽 | 0.0628 | ✓ |
| **Order** | 整数 | 鉴相器阶数，支持 BPSK=2、QPSK=4、8PSK=8 | 4 | ✗ |
| **Use SNR** | 枚举 | 启用使用噪声功率估计的软判决鉴相方式 | No | ✗ |

## 工作原理

模块用内部相位估计旋转复数输入，从校正信号中检测相位误差，再更新二阶控制环路的频率和相位。环路可稳定星座旋转，但仍可能存在调制阶数对应的固定相位歧义，需要差分编码、已知导频或后续帧校验解决。

Loop Bandwidth 大时跟踪更快，也更易引入噪声抖动。仅凭 error 接近零不能证明正确锁定，应同时检查星座、频率估计和已知数据的解码结果。

## 快速示例

使用已知 QPSK 测试流，经匹配滤波和符号同步后接 Costas Loop；Order=4、Loop Bandwidth=0.0628、Use SNR=No。输出 0 接 QT GUI Constellation Sink，1 和 2 接 Float Null Sink，3 接 Float QT GUI Time Sink。对比输入与输出星座的旋转，记录频率估计并校验解码后的已知数据。

BPSK 时使用 Order=2。Costas 输出仍为 Complex；若后续使用只接受 Float 的 Binary Slicer，需要先提取实部，不能直接相连。

## 性能与部署

环路在每个输入样本上更新，输入 item 率不变。大残余频偏应先粗校正，再使用本模块跟踪；实际捕获范围取决于输入调制、幅度、噪声和环路参数，应在目标条件下测试。

## 故障排查

| 现象 | 检查点 | 处理方式 |
|---|---|---|
| 星座持续快速旋转 | 残余频偏过大或参数不合适 | 先粗校正频偏，再调 Loop Bandwidth |
| 星座稳定但数据错误 | 固定相位歧义或映射不一致 | 用导频、差分方式或帧校验消歧义 |
| noise 消息无效 | 不是 PMT real 或混淆 SNR 与噪声功率 | 按 dB 噪声功率构造消息 |
| 只接 error 时连接失败 | 中间诊断端口未连接 | 按序连接，未使用输出接 Null Sink |
| 换采样率后跟踪变差 | 环路参数仍按旧处理段配置 | 在新 item 率下重新验证 |

## 相关 Block

- [PSK Mod](PSK_Mod.md)：PSK 调制器
- [PSK Demod](PSK_Demod.md)：层级 PSK 解调器
- [Symbol Sync](Symbol_Sync.md)：符号定时恢复
- [QT GUI Constellation Sink](QT_GUI_Constellation_Sink.md)：观察星座

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
