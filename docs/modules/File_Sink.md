# File Sink 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / File Sink

## 概览

File Sink 模块用于将样本流写入二进制文件。生成的文件可由 MATLAB、C、Python 等环境读取，也可通过 SeekMind Engine 的 File Source Block 重新载入。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | File Operators（文件操作） |
| Block ID | `blocks_file_sink` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

1. **信号录制**  
   将采集到的声学或振动信号保存到文件中供后续分析

2. **数据导出**  
   将处理后的数据导出到其他工具进行进一步分析

3. **调试和验证**  
   保存中间处理结果用于调试信号处理链

4. **数据采集**  
   长时间录制信号数据用于离线处理

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **File** | file_save | 设置读取或写入的文件路径 |  | ✓ |
| **Input Type** | 枚举 | 选择输入端样本类型 | float | ✗ |
| **Vector Length** | 整数 | 设置每个向量包含的元素数量 | 1 | ✗ |
| **Unbuffered** | 枚举 | 控制是否绕过用户态缓冲直接执行文件写入 | Off | ✓ |
| **Append file** | 枚举 | 控制启动时追加写入还是覆盖目标文件 | Overwrite | ✗ |

## 参数说明

**1. File**
- 文件路径

**2. Input Type**
- 输入数据类型
  - complex
  - float
  - int
  - short
  - byte

**3. Vector Length**
- 向量长度

**4. Unbuffered**
- 启用后减少用户态写缓冲，数据更快落盘但会增加 I/O 调用开销。
  - **Off**：False
  - **On**：True

**5. Append file**
- 是否追加文件
  - **Append**：True
  - **Overwrite**：False

## 工作原理

File Sink 模块的工作流程：

1. **打开文件**：根据指定路径创建或打开文件
2. **接收数据**：从输入端口接收数据流
3. **写入文件**：按照 Input Type 格式写入二进制数据
4. **缓冲管理**：根据 Unbuffered 参数管理写入缓冲
5. **关闭文件**：流图停止时关闭文件

```
输入流 → 格式转换 → 缓冲区 → 写入磁盘
                      ↓
              Unbuffered=Yes → 立即刷新
```

## 快速示例

**示例 1：录制传感器采集信号**

```
[Acquisition Source] → [File Sink]
  (complex)      (complex)
```

配置参数：
- File: "/home/user/recordings/signal.dat"
- Input Type: Complex
- Vec Length: 1
- Unbuffered: No
- Append: No

**示例 2：保存 FFT 结果**

```
[Signal Source] → [Stream to Vector] → [FFT] → [File Sink]
                    (1024)             (1024)   (complex, vec=1024)
```

配置参数：
- File: "fft_output.dat"
- Input Type: Complex
- Vec Length: 1024
- Unbuffered: No

**示例 3：分段录制**

```
[Audio Source] → [File Sink]
  (float)         (float, append=Yes)
```

配置参数：
- File: "audio_recording.bin"
- Input Type: Float
- Append: Yes  (每次运行追加新数据)

## 文件格式说明

**二进制文件结构：**
- 纯二进制格式，无文件头或元数据
- Complex 类型：交错存储 I-Q-I-Q-I-Q...（32位浮点 I + 32位浮点 Q）
- Float: 32位 IEEE 754 浮点数
- Int: 32位有符号整数
- Short: 16位有符号整数
- Byte: 8位无符号整数

**读取文件示例（Python）：**
```python
import numpy as np

# 读取 Complex 数据
data = np.fromfile('signal.dat', dtype=np.complex64)

# 读取 Float 数据
data = np.fromfile('audio.bin', dtype=np.float32)
```

## 性能与部署

1. **磁盘空间**  
   高采样率会快速消耗磁盘空间。例如：2 MHz 复数采样率 = 16 MB/s

2. **写入性能**  
   - 使用 SSD 提高写入速度
   - Unbuffered=No 可提高性能
   - 避免写入网络驱动器

3. **缓冲区大小**  
   系统默认缓冲区通常足够，特殊需求可调整

4. **文件大小限制**  
   注意文件系统的单文件大小限制（FAT32: 4GB, ext4/NTFS: 更大）

## 故障排查

**Q1: 如何估算录制时间对应的文件大小？**  
A: 文件大小 = 采样率 × 时间 × 每样本字节数  
   例如：2 MHz Complex，10秒 = 2,000,000 × 10 × 8 = 160 MB

**Q2: 为什么文件写入速度跟不上采样率？**  
A: 检查磁盘写入速度，考虑使用更快的存储设备或降低采样率。

**Q3: Unbuffered 模式什么时候使用？**  
A: 当需要确保数据立即写入磁盘时使用，例如关键数据采集或系统可能意外中断的场景。

**Q4: 如何在文件中保存采样率等元数据？**  
A: File Sink 不保存元数据。考虑使用 File Meta Sink 或在文件名中包含参数信息。

**Q5: 可以同时写入多个文件吗？**  
A: 可以，在流图中使用多个 File Sink 模块即可。

## 相关 Block

- [File Source](File_Source.md)：从二进制文件读取数据
- [Wav File Sink](Wav_File_Sink.md)：写入 WAV 格式音频文件
- **File Meta Sink**：写入带元数据的文件
- [Throttle](Throttle.md)：控制数据流速率

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
