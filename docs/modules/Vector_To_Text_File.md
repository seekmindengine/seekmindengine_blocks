# Vector To Text File 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Vector To Text File

## 概览

Vector To Text File 模块接收固定长度 float 向量，并将每个向量作为一条逗号分隔文本记录写入指定文件。它适合保存频谱、特征向量、测量快照和周期性统计结果，便于后续用 Excel、Python、MATLAB 等工具分析。

这是 SeekMind Engine 的文件记录模块，为 SeekMind Engine 专用扩展模块。其行为以本项目 block 定义和 filerepeater 扩展实现为准。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Advanced File（高级文件） |
| Block ID | `filerepeater_VectorToTxtFile` |
| 处理模型 | 连续样本流 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | 平台内置 |

## 何时使用

1. **向量数据记录**  
   将 FFT、滤波器组或自定义算法输出保存为文本

2. **测量结果导出**  
   输出便于外部工具读取的 CSV 风格数据

3. **运行信息标注**  
   在文件中记录频率、采样率、备注和运行时间

4. **周期快照**  
   按更新间隔保存向量，而不是保存所有原始样本

5. **实验报告数据**  
   生成便于人工检查和绘图的文本数据

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `float` × 向量长度 | 连续样本流端口 |

> 文件格式通常不携带完整流程元数据。读写两端应记录并复用数据类型、采样率、通道数和字节序配置。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **File** | 文件 | 输出文本文件路径 | - |
| **Vector Size** | 整数 | 输入 float 向量长度 | 1024 |
| **Frequency** | 浮点数 | 写入文件的频率标注 | freq |
| **Sample Rate** | 浮点数 | 写入文件的采样率标注 | 32000 |
| **Notes** | 字符串 | 写入文件的备注信息 | - |
| **Update Rate (sec)** | 浮点数 | 写入更新间隔 | 30.0 |
| **Output Precision** | 整数 | 小数输出精度 | 2 |
| **Append To File** | 枚举 | 是否追加到已有文件 | - |
| **Include Runtime** | 枚举 | 是否包含运行时间头 | - |

## 参数说明

**1. File（输出文件）**
- 指定文本文件路径
- 若 Append To File 为 No，通常会覆盖或重新写入
- 若为 Yes，则在已有文件后追加记录

**2. Vector Size（向量长度）**
- 输入端口要求 float 类型，vlen 等于 Vector Size
- 必须与上游模块输出向量长度一致
- 例如 FFT size 为 1024 时，Vector Size 通常设为 1024

**3. Frequency / Sample Rate**
- 写入文件的元数据标注
- 不改变输入数据，只用于记录实验条件

**4. Notes（备注）**
- 可写入实验说明、设备状态、配置名称等
- 便于之后识别数据来源

**5. Update Rate (sec)**
- 控制写入更新间隔
- 适合周期性快照，避免每个向量都写入造成文件过大

**6. Output Precision**
- 控制浮点数文本小数位数
- 精度越高文件越大

**7. Include Runtime**
- 在追加模式下可记录运行时间信息
- 便于分析每条记录对应的流程运行时刻

## 工作原理

```
float 向量输入 → 按精度格式化 → 添加元数据/备注 → 写入文本文件
```

每个输入向量通常对应文件中的一条记录，具体写入频率受 Update Rate 参数控制。

## 快速示例

**示例 1：保存频谱幅度**

```
[Stream to Vector] → [FFT] → [Complex to Mag] → [Vector To Text File]
```

配置参数：
- Vector Size: FFT size
- Sample Rate: 输入采样率
- Frequency: 中心频率或感兴趣频点

**示例 2：保存特征向量**

```
[Feature Extractor] → [Vector To Text File]
```

适合把机器学习或检测算法输入导出为文本。

**示例 3：周期性测量记录**

```
[Measurement Vector] → [Vector To Text File]
                       Update Rate=30
```

每隔约 30 秒写入一条测量记录。

## 文件内容建议

为了便于后续分析，建议：

1. Notes 中写明实验名称或配置
2. Frequency 和 Sample Rate 使用真实工程参数
3. Output Precision 按分析需求设置
4. 长时间运行时使用 Append 并包含 Runtime

## 性能与部署

1. **文本写入开销较大**  
   不适合高速保存每一个样本或每一帧。

2. **文件体积增长快**  
   Vector Size 大、精度高、更新频繁都会快速增大文件。

3. **高速原始数据应用 File Sink**  
   若目标是完整保存 IQ 或 float 原始流，应使用 File Sink 或 Advanced File Sink。

## 故障排查

**Q1: 输入必须是 float 向量吗？**  
A: 是。块定义要求输入类型为 float，向量长度由 Vector Size 指定。

**Q2: 可以保存 complex 向量吗？**  
A: 本块输入是 float。complex 数据应先转换为幅度、实部/虚部或其他 float 表示。

**Q3: 适合高速连续写入吗？**  
A: 不适合。文本写入开销较大，更适合周期性快照或低速记录。

**Q4: Frequency 会影响数据吗？**  
A: 不会。它只是写入文件的元数据。

## 相关 Block

- [Advanced File Sink](Advanced_File_Sink.md)：高级文件保存
- [File Sink](File_Sink.md)：原始数据保存
- [FFT](FFT.md)：向量频域分析
- [Complex to Mag](Complex_to_Mag.md)：复数转幅度

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
