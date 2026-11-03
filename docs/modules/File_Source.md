# File Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / File Source

## 概览

File Source 模块用于从指定文件中读取原始二进制格式的数据值。该文件可以是使用 File Sink 模块捕获的文件、通过计算机程序生成的文件，或从音频编辑器（如 Audacity）保存的 RAW 格式文件。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | File Operators（文件操作） |
| Block ID | `blocks_file_source` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **回放录制的信号**  
   读取之前通过 File Sink 保存的信号数据进行回放和分析

2. **导入外部数据**  
   将其他程序生成的二进制数据导入 SeekMind Engine 处理流程

3. **离线信号处理**  
   对预先录制的信号进行离线分析和处理

4. **测试和调试**  
   使用已知的测试数据验证信号处理算法

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **File** | file_open | 设置读取或写入的文件路径 |  | ✓ |
| **Output Type** | 枚举 | 选择输出端样本类型 | float | ✗ |
| **Repeat** | 枚举 | 控制到达文件末尾后是否从头继续读取 | Yes | ✓ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |
| **Add begin tag** | 原始 | 控制文件起始位置是否添加标签 | pmt.PMT_NIL | ✓ |
| **Offset** | 整数 | 设置叠加到输出的直流偏置 | 0 | ✗ |
| **Length** | 整数 | 设置处理长度或保留的条目数量 | 0 | ✗ |

## 参数说明

**1. File**
- 文件路径

**2. Output Type**
- 输出数据类型
  - complex
  - float
  - int
  - short
  - byte

**3. Repeat**
- 是否重复
  - **Yes**：True
  - **No**：False

**4. Vector Length**
- 向量长度

**5. Add begin tag**
- 添加起始标签

**6. Offset**
- 直流偏移

**7. Length**
- 长度

## 工作原理

File Source 模块的工作流程：

1. **打开文件**：根据指定路径打开二进制文件
2. **定位位置**：跳过 Offset 指定的样本数
3. **读取数据**：按照 Output Type 指定的格式读取数据
4. **输出流**：将读取的数据作为流输出
5. **循环控制**：根据 Repeat 参数决定是否循环

```
文件 → 跳过Offset → 读取Length个样本 → 输出流
                                    ↓
                            Repeat=Yes → 返回文件开头
```

## 快速示例

**示例 1：播放录制的 IQ 数据**

```
[File Source] → [Throttle] → [QT GUI Frequency Sink]
  (complex)      (2M sps)
```

配置参数：
- File: "recorded_signal.dat"
- Output Type: Complex
- Repeat: Yes
- Offset: 0
- Length: 0

**示例 2：读取特定数据段**

```
[File Source] → [Low Pass Filter] → [File Sink]
  (float)
```

配置参数：
- File: "audio_data.bin"
- Output Type: Float
- Repeat: No
- Offset: 48000  (跳过前1秒，假设采样率48kHz)
- Length: 96000  (读取2秒数据)

## 文件格式说明

**二进制文件结构：**
- 数据以原始二进制格式存储，无文件头
- Complex 类型：交错存储 I-Q-I-Q-I-Q...
- Float/Int/Short/Byte：连续存储

**文件大小计算：**
- Complex: 文件大小 = 样本数 × 8 字节
- Float: 文件大小 = 样本数 × 4 字节
- Int: 文件大小 = 样本数 × 4 字节
- Short: 文件大小 = 样本数 × 2 字节
- Byte: 文件大小 = 样本数 × 1 字节

## 性能与部署

1. **文件 I/O 性能**  
   大文件读取可能受磁盘速度限制，建议使用 SSD

2. **内存使用**  
   模块会缓冲部分数据，超大文件不会一次性加载到内存

3. **采样率匹配**  
   使用 Throttle 模块控制播放速率，避免 CPU 过载

## 故障排查

**Q1: 为什么提示"file is too small"错误？**  
A: 文件大小必须至少 8 字节。检查文件是否为空或损坏。

**Q2: 如何确定文件的数据类型？**  
A: 查看生成文件时使用的 File Sink 配置，或根据文件大小和已知样本数反推。

**Q3: 可以读取 WAV 或 MP3 文件吗？**  
A: 不能直接读取。File Source 只支持原始二进制格式。对于 WAV 文件，使用 Wav File Source 模块。

**Q4: Repeat 模式下如何检测循环边界？**  
A: 使用 Add Begin Tag 参数添加标签，然后用 Tag Debug 模块监控标签。

## 相关 Block

- [File Sink](File_Sink.md)：将数据流写入二进制文件
- [Wav File Source](Wav_File_Source.md)：读取 WAV 格式音频文件
- [Throttle](Throttle.md)：控制文件播放速率
- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：为数据流添加标签

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
