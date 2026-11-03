# SeekMind Engine 模块文档

![SeekMind Engine](assets/brand/seekmindengine-wordmark-horizontal.png)

SeekMind Engine 是面向振动、声学、水声、通信与通用信号处理任务的图形化流程平台。它将数据采集、算法组合、实时观察、文件记录和硬件部署组织在统一的 Block 工作流中，帮助研发团队从实验验证平稳过渡到可重复运行的工程流程。用户可以通过连接模块、配置参数和观察处理结果，逐步构建从信号输入、滤波与变换、特征分析到显示与存储的完整链路，开展算法验证、设备联调、数据回放和持续监测等工作。

SeekMind Engine 底层兼容 GNU Radio、NumPy 等信号处理与科学计算生态，并集成 FFTW、Qt/PyQt5、ZeroMQ 和 UHD，为频域计算、实时可视化、网络通信与硬件接入提供支持。平台提供 Python 与 C++ 模块扩展方式，可将专用算法与现有模块组合使用，逐步积累面向具体业务的处理组件。通过显式记录模块参数、数据类型和连接关系，研发团队能够复现实验配置、定位处理链路中的问题，并在后续项目中复用已经验证的流程。

## 设计理念

SeekMind Engine 使用数据流架构，将信号处理任务分解为可组合的 Block。每个 Block 封装明确的处理功能，并通过端口、数据类型和参数定义其接口。

**核心优势：**

- **可视化编程**：通过图形化界面组织处理流程，降低开发门槛，提高开发效率
- **流式处理**：由运行时调度 Block 并管理流式缓冲区
- **硬件接口**：通过 UHD 和音频 Block 连接文档目录中列出的设备类型
- **模块化设计**：松耦合的 Block 架构便于流程调试、测试和维护
- **接口可检查**：流程生成前检查端口域、类型、向量长度和参数约束

## 文档导航

| 文档 | 目标读者 | 内容概要 |
|---|---|---|
| [快速入门](docs/GETTING_STARTED.md) | 初次使用者 | 10 分钟构建并运行第一条信号处理流程 |
| [核心概念](docs/CONCEPTS.md) | 所有用户 | 数据流模型、采样率、类型系统、消息传递与性能调优 |
| [故障排查](docs/TROUBLESHOOTING.md) | 工程师与运维人员 | 系统化的问题诊断方法和常见故障解决方案 |
| [Block 参考手册](#block-目录) | 开发者 | 内置 Block 的中文参考页 |

## 核心能力

### 信号处理能力
- **多域处理**：时域、频域、调制域的完整处理链路
- **实时分析**：FFT、滤波、重采样、同步、解调等高性能算法
- **数字通信**：PSK/GMSK/CPM 调制解调、符号同步、载波恢复
- **流结构处理**：标量/向量转换、标签、选择、限长和比特重组

### 系统集成能力
- **硬件接口**：USRP 射频前端和音频设备
- **网络协议**：UDP 与 ZeroMQ 流式或消息传递
- **文件格式**：原始二进制、WAV 音频、带元数据的分段记录
- **实时可视化**：时域波形、频谱、瀑布图、星座图、统计直方图

### 工程化特性
- **流程可复现**：所有参数和连接关系显式声明，支持版本控制
- **模块化设计**：Block 独立开发、测试和部署，降低系统复杂度
- **性能可测量**：可用 Null Sink 和分段流程定位吞吐瓶颈
- **错误可诊断**：结合流程校验、运行时错误和调试 Block 排查

## 快速开始

### 第一个信号处理流程（5 分钟）

创建最小可运行链路验证系统功能：

```text
[Signal Source] → [Throttle] → [QT GUI Time Sink]
```

**配置参数：**

| Block | 参数 | 推荐值 | 说明 |
|---|---|---|---|
| Signal Source | Output Type | `float` | 实数信号输出 |
| Signal Source | Sample Rate | `32000` | 32 kSps 采样率 |
| Signal Source | Waveform | `Sine` | 正弦波测试信号 |
| Signal Source | Frequency | `1000` | 1 kHz 频率 |
| Throttle | Type | `float` | 匹配信号源类型 |
| Throttle | Sample Rate | `32000` | 匹配信号源采样率 |
| QT GUI Time Sink | Type | `float` | 匹配数据类型 |
| QT GUI Time Sink | Sample Rate | `32000` | 用于正确显示时间轴 |
| QT GUI Time Sink | Trigger Slope | `Positive` | 显式选择，避免当前定义的初始字段不一致 |

**预期结果：**
- 时域窗口显示稳定的正弦波形，幅度 ±1.0
- 波形周期为 1 ms（1 kHz）
- CPU 占用稳定在合理水平（Throttle 限制执行速率）

**常见问题：**
- 若无法连接：检查三处 `Type` 参数是否都为 `float`
- 若时间轴错误：检查三处 `Sample Rate` 是否都为 `32000`
- 若本教程占用一个 CPU 核：检查是否正确添加 Throttle Block；离线快速处理不要求 Throttle

完整教程请参阅[快速入门指南](docs/GETTING_STARTED.md)。

## 设计原则

### 1. 连接契约优先
每条连接必须同时满足：
- **数据类型兼容**：Complex、Float、Int、Short、Byte 必须精确匹配
- **向量长度一致**：标量流（长度 1）与向量流不能直接连接
- **端口模型匹配**：样本流端口与消息端口使用不同的传输机制，不能混用

### 2. 按处理段维护采样率
采样率是**语义参数**，不是由连接器自动验证的类型信息：
- 滤波器截止频率、重采样比率、频谱显示范围都依赖正确的采样率
- 在没有 rate change 的同一处理段中应保持一致
- 经过抽取、插值或重采样后，下游必须使用换算后的新采样率

### 3. 区分速率变换与执行限速
- **硬件设备**（USRP、音频卡）：通常已经由设备和 I/O 限速，不需要额外 Throttle
- **纯软件实时观察**：可使用 Throttle 限制平均 item 率
- **离线处理**：可不使用 Throttle，让流程尽快完成
- **文件回放**：只有需要按墙上时钟实时回放时才需要限速

⚠️ **常见错误**：
- 在硬件采集链路中添加 Throttle（引入不必要的背压）
- 用 Throttle 替代 Resampler（无法改变信号的采样率语义）
- 把 Throttle 的 Sample Rate 当成连接中自动传播的采样率元数据

### 4. 渐进式验证策略
按以下顺序构建和验证流程：
1. **最小链路验证**：使用 Signal Source + Throttle + GUI Sink 验证基础功能
2. **算法验证**：使用已知输入信号验证处理算法的正确性
3. **硬件集成**：用实际设备替换模拟信号源
4. **性能优化**：在功能正确的基础上优化吞吐量和延迟
5. **生产部署**：添加错误处理、日志记录和监控机制

## 典型应用场景

| 应用领域 | 核心 Block | 技术要点 |
|---|---|---|
| **频谱监测与分析** | Signal Source、FFT、QT GUI Frequency Sink、Waterfall Sink | 实时频谱显示、长时间瀑布图记录、功率谱估计 |
| **数字通信系统** | PSK Mod/Demod、Symbol Sync、Costas Loop、Correlate Access Code | 调制解调、符号同步、载波恢复、帧同步 |
| **软件定义无线电** | UHD USRP Source/Sink、Frequency Shift、Low Pass Filter | 射频采集、数字下变频、基带处理 |
| **音频信号处理** | Audio Source/Sink、Band Pass Filter、Hilbert、Quadrature Demod | 音频采集、滤波、解调、播放 |
| **数据记录与回放** | File Source/Sink、Advanced File Sink、Wav File Source/Sink | 原始数据记录、分段存储、格式转换 |
| **网络信号传输** | UDP Source/Sink、ZMQ PUB/SUB、Message Tools | 分布式处理、远程数据采集、多节点协同 |
| **测试与仿真** | Signal Source、Noise Source、Add、Fast Multiply Const、Throttle | 信号生成、组合、缩放和限速观察 |

## 按功能选择 Block

| 功能需求 | 推荐 Block | 使用场景 |
|---|---|---|
| **生成测试信号** | [Signal Source](docs/modules/Signal_Source.md)、[Noise Source](docs/modules/Noise_Source.md)、[Vector Source](docs/modules/Vector_Source.md) | 正弦波、方波、三角波；高斯/均匀噪声；自定义波形序列 |
| **实时可视化** | [QT GUI Time Sink](docs/modules/QT_GUI_Time_Sink.md)、[QT GUI Frequency Sink](docs/modules/QT_GUI_Frequency_Sink.md)、[QT GUI Waterfall Sink](docs/modules/QT_GUI_Waterfall_Sink.md)、[QT GUI Constellation Sink](docs/modules/QT_GUI_Constellation_Sink.md) | 时域波形、频谱分析、瀑布图、星座图、直方图 |
| **频率选择滤波** | [Low Pass Filter](docs/modules/Low_Pass_Filter.md)、[Band Pass Filter](docs/modules/Band_Pass_Filter.md)、[High Pass Filter](docs/modules/High_Pass_Filter.md)、[FFT Filter](docs/modules/FFT_Filter.md) | 抗混叠、带宽限制、噪声抑制、频带提取 |
| **采样率转换** | [Rational Resampler](docs/modules/Rational_Resampler.md)、[Polyphase Arbitrary Resampler](docs/modules/Polyphase_Arbitrary_Resampler.md)、[Decimating FIR Filter](docs/modules/Decimating_FIR_Filter.md) | 整数倍/有理数倍/任意倍率重采样，滤波与重采样一体化 |
| **数据存储与加载** | [File Source](docs/modules/File_Source.md)、[File Sink](docs/modules/File_Sink.md)、[Advanced File Sink](docs/modules/Advanced_File_Sink.md)、[Wav File Source/Sink](docs/modules/Wav_File_Source.md) | 原始二进制数据、WAV 音频、自动分段存储 |
| **网络数据传输** | [UDP Source](docs/modules/UDP_Source.md)/[Sink](docs/modules/UDP_Sink.md)、[ZMQ PUB Sink](docs/modules/ZeroMQ_Pub_Sink.md)/[SUB Source](docs/modules/ZeroMQ_Sub_Source.md) | 实时流式传输、分布式处理、进程间通信 |
| **射频硬件接口** | [UHD: USRP Source](docs/modules/UHD_USRP_Source.md)、[UHD: USRP Sink](docs/modules/UHD_USRP_Sink.md) | USRP 系列 SDR 硬件的射频接收与发射 |
| **数字调制解调** | [PSK Mod](docs/modules/PSK_Mod.md)/[Demod](docs/modules/PSK_Demod.md)、[GMSK Mod](docs/modules/GMSK_Mod.md)/[Demod](docs/modules/GMSK_Demod.md)、[Symbol Sync](docs/modules/Symbol_Sync.md)、[Costas Loop](docs/modules/Costas_Loop.md) | BPSK/QPSK/8PSK、GMSK、符号同步、载波恢复 |
| **流结构操作** | [Stream to Vector](docs/modules/Stream_to_Vector.md)、[Vector to Stream](docs/modules/Vector_to_Stream.md)、[Interleave](docs/modules/Interleave.md)、[Deinterleave](docs/modules/Deinterleave.md)、[Keep M in N](docs/modules/Keep_M_in_N.md)、[Head](docs/modules/Head.md) | 标量/向量转换、多路流交织与拆分、数据选择、流截断 |
| **实数与复数处理** | [Float To Complex](docs/modules/Float_To_Complex.md)、[Complex to Mag](docs/modules/Complex_to_Mag.md) | I/Q 组合、实数转复数、复数幅度提取 |

## Block 目录

下列目录与 SeekMind Engine 当前内置组件树一致。

### Advanced File（高级文件）

面向持续记录、自动分段和带元数据的数据管理。

| Block | Block |
|---|---|
| [Advanced File Sink](docs/modules/Advanced_File_Sink.md) | [State Timer](docs/modules/State_Timer.md) |
| [Advanced File Source](docs/modules/Advanced_File_Source.md) | [Message to File](docs/modules/Message_to_File.md) |
| [Vector To Text File](docs/modules/Vector_To_Text_File.md) |  |

### Audio（音频）

连接系统音频设备进行实时采集与播放。

| Block | Block |
|---|---|
| [Audio Sink](docs/modules/Audio_Sink.md) | [Audio Source](docs/modules/Audio_Source.md) |

### File Operators（文件操作）

读取或保存裸数据与 WAV 音频。

| Block | Block |
|---|---|
| [File Sink](docs/modules/File_Sink.md) | [File Source](docs/modules/File_Source.md) |
| [Wav File Sink](docs/modules/Wav_File_Sink.md) | [Wav File Source](docs/modules/Wav_File_Source.md) |

### Filters（滤波器）

完成频带选择、成形、延迟和滤波器组处理。

| Block | Block |
|---|---|
| [Band Pass Filter](docs/modules/Band_Pass_Filter.md) | [Band Reject Filter](docs/modules/Band_Reject_Filter.md) |
| [DC Blocker](docs/modules/DC_Blocker.md) | [FFT Filter](docs/modules/FFT_Filter.md) |
| [FFT Low Pass Filter](docs/modules/FFT_Low_Pass_Filter.md) | [FFT Root Raised Cosine Filter](docs/modules/FFT_Root_Raised_Cosine_Filter.md) |
| [Filter Delay](docs/modules/Filter_Delay.md) | [Generic Filterbank](docs/modules/Generic_Filterbank.md) |
| [Decimating FIR Filter](docs/modules/Decimating_FIR_Filter.md) | [High Pass Filter](docs/modules/High_Pass_Filter.md) |
| [Hilbert](docs/modules/Hilbert.md) | [IIR Filter](docs/modules/IIR_Filter.md) |
| [Interpolating FIR Filter](docs/modules/Interpolating_FIR_Filter.md) | [Low Pass Filter](docs/modules/Low_Pass_Filter.md) |
| [Root Raised Cosine Filter](docs/modules/Root_Raised_Cosine_Filter.md) | [Single Pole IIR Filter](docs/modules/Single_Pole_IIR_Filter.md) |

### Fourier Analysis（傅里叶分析）

进行频域变换、功率谱和单频检测。

| Block | Block |
|---|---|
| [FFT](docs/modules/FFT.md) | [Goertzel](docs/modules/Goertzel.md) |
| [Log Power FFT](docs/modules/Log_Power_FFT.md) |  |

### Instrumentation（仪器测量）

提供时域、频域、星座图和统计视图。

| Block | Block |
|---|---|
| [QT GUI Constellation Sink](docs/modules/QT_GUI_Constellation_Sink.md) | [QT GUI Frequency Sink](docs/modules/QT_GUI_Frequency_Sink.md) |
| [QT GUI Histogram Sink](docs/modules/QT_GUI_Histogram_Sink.md) | [QT GUI Number Sink](docs/modules/QT_GUI_Number_Sink.md) |
| [QT GUI Sink](docs/modules/QT_GUI_Sink.md) | [QT GUI Time Raster Sink](docs/modules/QT_GUI_Time_Raster_Sink.md) |
| [QT GUI Time Sink](docs/modules/QT_GUI_Time_Sink.md) | [QT GUI Waterfall Sink](docs/modules/QT_GUI_Waterfall_Sink.md) |

### GUI Widgets（界面组件）

构建交互控件、状态指示和专用可视化。

| Block | Block |
|---|---|
| [QT GUI Fast Auto-Correlator Sink](docs/modules/QT_GUI_Fast_Auto_Correlator_Sink.md) | [QT GUI Az-El Plot](docs/modules/QT_GUI_Az_El_Plot.md) |
| [QT GUI Message Edit Box](docs/modules/QT_GUI_Message_Edit_Box.md) | [QT GUI Graphic Item](docs/modules/QT_GUI_Graphic_Item.md) |
| [QT GUI Graphic Overlay Sample Source](docs/modules/QT_GUI_Graphic_Overlay_Sample_Source.md) | [QT GUI LED Indicator](docs/modules/QT_GUI_LED_Indicator.md) |
| [QT GUI Msg Push Button](docs/modules/QT_GUI_Msg_Push_Button.md) |  |

### Math Operators（数学运算）

执行逐样本、逐向量或多输入数学运算。

| Block | Block |
|---|---|
| [Frequency Shift](docs/modules/Frequency_Shift.md) | [Integrate](docs/modules/Integrate.md) |
| [Add](docs/modules/Add.md) | [Add Const](docs/modules/Add_Const.md) |
| [Argmax](docs/modules/Argmax.md) | [Max](docs/modules/Max.md) |
| [Fast Multiply Const](docs/modules/Fast_Multiply_Const.md) |  |

### Message Tools（消息工具）

观察和诊断离散消息。

| Block | Block |
|---|---|
| [Message Debug](docs/modules/Message_Debug.md) |  |

### Misc（其他）

提供流程控制和自定义处理能力。

| Block | Block |
|---|---|
| [Python Block](docs/modules/Python_Block.md) | [Throttle](docs/modules/Throttle.md) |
| [Selector](docs/modules/Selector.md) |  |

### Modulators（调制器）

将符号或比特映射为调制波形。

| Block | Block |
|---|---|
| [Continuous Phase Modulation](docs/modules/Continuous_Phase_Modulation.md) | [GMSK Mod](docs/modules/GMSK_Mod.md) |
| [PSK Mod](docs/modules/PSK_Mod.md) |  |

### Demodulators（解调器）

从调制信号恢复符号、比特或瞬时频率。

| Block | Block |
|---|---|
| [Quadrature Demod](docs/modules/Quadrature_Demod.md) | [Binary Slicer](docs/modules/Binary_Slicer.md) |
| [GMSK Demod](docs/modules/GMSK_Demod.md) | [PSK Demod](docs/modules/PSK_Demod.md) |

### Resamplers（重采样器）

改变采样率并控制抗混叠行为。

| Block | Block |
|---|---|
| [Interleaved Stream Decimator](docs/modules/Interleaved_Stream_Decimator.md) | [Polyphase Arbitrary Resampler](docs/modules/Polyphase_Arbitrary_Resampler.md) |
| [Rational Resampler](docs/modules/Rational_Resampler.md) |  |

### Synchronizers（同步器）

完成码元、载波和访问码同步。

| Block | Block |
|---|---|
| [Correlate Access Code - Tag](docs/modules/Correlate_Access_Code_Tag.md) | [Correlate Access Code - Tag Stream](docs/modules/Correlate_Access_Code_Tag_Stream.md) |
| [Symbol Sync](docs/modules/Symbol_Sync.md) | [Costas Loop](docs/modules/Costas_Loop.md) |

### Waveform Generators（波形发生器）

生成确定性、随机或伪随机测试数据。

| Block | Block |
|---|---|
| [Constant Source](docs/modules/Constant_Source.md) | [Fast Noise Source](docs/modules/Fast_Noise_Source.md) |
| [Noise Source](docs/modules/Noise_Source.md) | [Random Source](docs/modules/Random_Source.md) |
| [Random Uniform Source](docs/modules/Random_Uniform_Source.md) | [Signal Source](docs/modules/Signal_Source.md) |
| [GLFSR Source](docs/modules/GLFSR_Source.md) | [Vector Source](docs/modules/Vector_Source.md) |

### Stream Tag Tools（流标签工具）

创建、传播和观察样本流元数据。

| Block | Block |
|---|---|
| [Stream to Tagged Stream](docs/modules/Stream_to_Tagged_Stream.md) | [Tag Debug](docs/modules/Tag_Debug.md) |

### Stream Operators（流操作）

重组、选择、限长或调整样本流布局。

| Block | Block |
|---|---|
| [Stream to Vector](docs/modules/Stream_to_Vector.md) | [Streams to Vector](docs/modules/Streams_to_Vector.md) |
| [Vector to Stream](docs/modules/Vector_to_Stream.md) | [Vector to Streams](docs/modules/Vector_to_Streams.md) |
| [Pack K Bits](docs/modules/Pack_K_Bits.md) | [Unpack K Bits](docs/modules/Unpack_K_Bits.md) |
| [Repack Bits](docs/modules/Repack_Bits.md) | [Skip Head](docs/modules/Skip_Head.md) |
| [Endian Swap](docs/modules/Endian_Swap.md) | [PDU To Stream](docs/modules/PDU_to_Stream.md) |
| [Null Sink](docs/modules/Null_Sink.md) | [Head](docs/modules/Head.md) |
| [Keep M in N](docs/modules/Keep_M_in_N.md) | [Keep 1 in N](docs/modules/Keep_One_In_N.md) |
| [Deinterleave](docs/modules/Deinterleave.md) | [Interleave](docs/modules/Interleave.md) |

### Type Converters（类型转换）

在常用样本表示之间转换。

| Block | Block |
|---|---|
| [Complex to Mag](docs/modules/Complex_to_Mag.md) | [Float To Complex](docs/modules/Float_To_Complex.md) |

### UHD（硬件接口）

连接 USRP 硬件进行射频采集和发射。

| Block | Block |
|---|---|
| [UHD: USRP Source](docs/modules/UHD_USRP_Source.md) | [UHD: USRP Sink](docs/modules/UHD_USRP_Sink.md) |

### Networking Tools（网络工具）

通过 UDP 交换连续样本数据。

| Block | Block |
|---|---|
| [UDP Sink](docs/modules/UDP_Sink.md) | [UDP Source](docs/modules/UDP_Source.md) |

### ZeroMQ（ZeroMQ）

通过 ZeroMQ 交换样本流或离散消息。

| Block | Block |
|---|---|
| [ZMQ PULL Message Source](docs/modules/ZeroMQ_Pull_Msg_Source.md) | [ZMQ PUSH Message Sink](docs/modules/ZMQ_PUSH_Message_Sink.md) |
| [ZMQ PUB Message Sink](docs/modules/ZMQ_PUB_Message_Sink.md) | [ZMQ PUB Sink](docs/modules/ZeroMQ_Pub_Sink.md) |
| [ZMQ SUB Message Source](docs/modules/ZMQ_SUB_Message_Source.md) | [ZMQ SUB Source](docs/modules/ZeroMQ_Sub_Source.md) |

## 数据类型系统

流端口通过 item size、基础类型和向量长度描述数据布局。流程编辑器通常会在生成前发现不兼容连接，部分错误也可能在流程构造或启动时报告。

| 类型标识 | 常见 item 元素宽度 | 典型应用场景 |
|---|---:|---|
| **Complex** | 8 字节 | 两个 32-bit float 组成的复数基带或 IQ 数据 |
| **Float** | 4 字节 | 音频、幅度、实数运算和显示数据 |
| **Int** | 4 字节 | 整数样本或协议字段 |
| **Short** | 2 字节 | 16-bit 整数样本 |
| **Byte** | 1 字节 | 字节流、比特打包和协议数据；有无符号解释以具体 Block 为准 |

**类型转换注意事项：**
- Complex → Float：需要选择提取方式（幅度/相位/实部/虚部）
- Float → Int/Short/Byte：注意截断、溢出和量化误差
- Int/Short → Byte：检查数值范围，避免意外的模运算
- 所有转换都应在转换后使用 GUI Sink 或统计 Block 验证数值范围

## 文档规范

本文档遵循统一的结构化规范，每个 Block 文档包含以下标准章节：

| 章节 | 内容 | 目的 |
|---|---|---|
| **概览** | Block 功能的一句话描述 | 快速判断是否是所需功能 |
| **模块信息** | 分类、ID、处理模型、执行支持 | 技术规格查询 |
| **何时使用** | 典型应用场景列表 | 理解适用范围 |
| **输入与输出** | 端口定义、数据类型、约束条件 | 设计连接关系 |
| **参数** | 完整参数表、类型、默认值、运行时可调性 | 配置 Block 行为 |
| **工作原理** | 算法描述、数学公式、处理流程 | 理解内部实现 |
| **快速示例** | 可运行的配置示例 | 快速上手 |
| **性能与部署** | 计算复杂度、内存占用、优化建议 | 生产环境部署 |
| **故障排查** | 常见问题与解决方案 | 快速定位问题 |
| **相关 Block** | 相关功能的 Block 链接 | 扩展知识 |

**文档质量标准：**
- 接口、参数和默认值可追溯到产品集成版本的模块定义或项目自定义实现
- 运行时可调性必须由 callback、setter 或消息接口支持
- 示例明确前提和预期现象，不承诺未经测量的性能数字
- 集成模块与 SeekMind Engine 自定义模块分别核对其实际定义

新增或修订 Block 文档时，请参考 [Block 文档模板](docs/BLOCK_DOCUMENTATION_TEMPLATE.md)。

## 适用范围与限制

**本文档覆盖范围：**
- SeekMind Engine 内置 Block 的中文参考页
- 核心概念、入门流程和通用故障排查方法

**不在覆盖范围：**
- ❌ 用户自行安装的第三方扩展 Block
- ❌ 自定义开发的 Python Block 内部实现
- ❌ 特定硬件的详细规格（请参考硬件厂商文档）
- ❌ 操作系统特定的安装和配置步骤

**重要声明：**
- 硬件能力取决于设备型号、固件版本、驱动程序和操作系统
- 网络性能取决于协议选择、网络拓扑、带宽和对端实现
- 参数默认值可能随软件版本更新而调整
- 生产部署前必须在目标环境中验证完整流程
- 未给出测试环境和方法的性能数字不视为产品保证

## 文档状态与复核依据

**2026-11-03** 对现有 108 个模块页进行技术复核，保留 Interleave、Float To Complex，并对照 Editor 当前工作区的内置定义（所在提交 `aa9bfae`）检查参数、默认值、端口及回调。`common` 扩展内容暂未纳入本轮。

底层行为以运行包对应的 [GNU Radio 3.10.12.0 源码](https://github.com/gnuradio/gnuradio/tree/v3.10.12.0)为对照基线，结合本地安装的头文件与 Python 实现核对。100 个模块可匹配官方静态定义；UHD Source/Sink 与 Python Block 另按生成型定义核对；5 个高级文件模块按项目实际定义和可取得的实现核对，不作同名标准模块的等同假设。产品定制的参数和端口以 Editor 实际定义为准。

重点修订涉及数据打包与位序、标签语义、抽取相位、滤波公式、消息格式和显示输入。例如 [IIR 的反馈约定](https://github.com/gnuradio/gnuradio/blob/v3.10.12.0/gr-filter/include/gnuradio/filter/iir_filter.h)、[Access Code 长度头解析](https://github.com/gnuradio/gnuradio/blob/v3.10.12.0/gr-digital/lib/correlate_access_code_bb_ts_impl.cc)与 [PDU 转流行为](https://github.com/gnuradio/gnuradio/blob/v3.10.12.0/gr-pdu/lib/pdu_to_stream_impl.cc)均对照了实现。

已通过 108 个模块的定义对照与文档结构、链接、术语检查，并在本机 3.10.12.0 参考运行环境完成 14 组有限数据流验证。此结果不等于全部模块、Editor 代码生成、GUI、硬件或跨平台验收；高级文件模块的完整运行验证仍待补齐。当前已知的集成限制见各模块的使用说明。
