# Vector Source 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Vector Source

## 概览

Vector Source 模块将参数中配置的向量数据作为流输出。它可以只输出一次，也可以循环重复输出，因此常用于构造固定测试序列、前导码、短报文、已知训练序列以及可重复的离线测试输入。

与 Signal Source、Noise Source 这类连续生成器不同，Vector Source 的输出完全由 Vector 参数决定。只要参数不变，每次运行产生的数据序列都相同，这一点对调试数字通信链路和复现实验非常有用。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Waveform Generators（波形发生器） |
| Block ID | `blocks_vector_source_x` |
| 处理模型 | 连续样本流 |
| 典型位置 | Source（数据源） |
| 执行支持 | Python / C++ |

## 何时使用

1. **固定测试数据源**  
   输出已知样本序列，用于验证下游模块是否按预期处理数据

2. **数字通信输入**  
   生成 bit 序列、符号索引、同步字或短包数据

3. **训练序列和前导码**  
   为同步、相关检测或协议测试提供固定模式

4. **离线复现**  
   不依赖外部文件或随机源，便于复现同一段输入

5. **消息/标签实验**  
   通过 Tags 参数在指定偏移位置附加流标签，验证标签传播行为

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 先核对输出类型与数据含义；离线处理可尽快运行，需要近似实时显示时再配置速率控制。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Output Type** | 枚举 | 输出类型：complex、float、int、short、byte | byte |
| **Vector** | raw | 要输出的数据向量 | ASCII 文本示例 |
| **Tags** | raw | 附加到输出流上的标签列表 | [] |
| **Repeat** | 枚举 | 是否循环重复输出 | Yes |
| **Vector Length** | 整数 | 输出流项目的向量长度 | 1 |

## 参数说明

**1. Output Type（输出类型）**
- 决定输出端口的数据类型
- 可选 complex、float、int、short、byte
- Vector 中的元素需要能转换为所选类型
- byte 常用于 bit/字节流，complex 常用于 IQ 测试样本

**2. Vector（输出向量）**
- 使用 Python 风格列表或元组描述数据
- 例如 `(1, 0, 1, 1)`、`[0.1, 0.2, 0.3]`、`[1+0j, 0+1j]`
- 当 Output Type 为 byte 且 Vector 中包含大于 1 的整数时，通常表示字节数据；当下游期望 bit 流时，应确保值为 0 或 1

**3. Tags（流标签）**
- 用于在输出流指定位置添加 SeekMind Engine 样本流 tags
- 默认 `[]` 表示不添加标签
- 标签可用于标记包起点、长度、频率、时间戳等元数据
- 下游模块是否保留或解释标签，取决于下游模块自身行为

**4. Repeat（是否重复）**
- Yes：Vector 输出结束后从头开始，形成周期性数据流
- No：Vector 输出一次后结束，适合有限长度测试
- 在纯软件仿真中，如果 Repeat 为 Yes，通常需要配合 Throttle 或硬件 Sink 控制速率

**5. Vector Length（向量长度）**
- 默认为 1，表示输出标量流
- 大于 1 时，每个输出项目是一个向量
- Vector 元素总数应能按 Vector Length 正确分组，否则最后一组数据可能不符合预期

## 工作原理

**Repeat = Yes：**

```
Vector = (1, 2, 3)
输出流: 1 2 3 1 2 3 1 2 3 ...
```

**Repeat = No：**

```
Vector = (1, 2, 3)
输出流: 1 2 3 → 结束
```

**Vector Length = 2：**

```
Vector = (1, 2, 3, 4)
输出向量流: [1,2] [3,4] ...
```

模块本身不对数据做调制、滤波或重采样，只负责把配置的向量变成 SeekMind Engine 样本流。

## 快速示例

**示例 1：生成 bit 测试序列**

```
[Vector Source] → [Pack K Bits] → [File Sink]
  byte, (1,0,1,1,0,0,1,0)
```

配置参数：
- Output Type: byte
- Vector: `(1, 0, 1, 1, 0, 0, 1, 0)`
- Repeat: No
- Vector Length: 1

**示例 2：驱动 PSK 调制器**

```
[Vector Source] → [Repack Bits] → [PSK Mod] → [QT GUI Constellation Sink]
```

配置参数：
- Output Type: byte
- Vector: `(0, 1, 1, 0, 1, 0, 0, 1)`
- Repeat: Yes

**示例 3：复数 IQ 样本源**

```
[Vector Source] → [QT GUI Time Sink]
  complex, (1+0j, 0+1j, -1+0j, 0-1j)
```

此配置可生成一个循环的 QPSK 星座点序列，适合调试显示和后续复数处理模块。

**示例 4：有限长度测试流**

```
[Vector Source] → [Head] → [Message/Debug Chain]
  Repeat=No
```

当需要让流程图自然结束时，将 Repeat 设为 No；如果下游仍需要固定数量样本，可再配合 Head。

## 标签使用说明

Tags 参数适合在测试链路中模拟真实数据流标签。例如：

```
Tags = [gr.tag_utils.python_to_tag((0, pmt.intern("packet_len"), pmt.from_long(16), pmt.PMT_NIL))]
```

常见用途：
- 标记第一个样本为包起点
- 配合 Stream to Tagged Stream / Repack Bits 测试包长标签
- 验证下游模块是否保留、移动或丢弃标签

如果不熟悉 流标签结构，建议先保持默认 `[]`，等数据流跑通后再加入标签测试。

## 数据类型建议

| 场景 | 推荐 Output Type | 说明 |
|------|------------------|------|
| bit 流测试 | byte | 每个 byte 表示一个 0/1 bit |
| 文件字节测试 | byte | Vector 可写 ASCII 或十六进制对应整数 |
| 音频/实数样本 | float | 便于连接滤波器和 GUI |
| IQ 样本 | complex | 用于复数基带链路 |
| 整数算法验证 | int / short | 与下游整数模块保持一致 |

## 性能与部署

1. **Repeat=True 时可能跑满 CPU**  
   Vector Source 本身没有硬件时钟。如果后面没有 Audio、UHD、Throttle 等限速模块，纯软件流图可能尽可能快地运行。

2. **短向量重复会形成强周期性**  
   很短的重复序列在频域中会产生明显离散谱线。做随机性或误码测试时，应使用足够长的序列或 Random Source。

3. **大向量会占用内存**  
   Vector 参数直接保存在流程图中，特别大的测试数据更适合 File Source。

## 故障排查

**Q1: Vector 参数应该写列表还是元组？**  
A: 两者通常都可以，例如 `(1, 0, 1)` 或 `[1, 0, 1]`。保持 Python 表达式合法即可。

**Q2: Repeat=No 时流程图一定会停止吗？**  
A: 源会结束输出，但整个流程图是否退出还取决于调度器和其他源模块。如果流图中还有其他持续运行的源，流程图仍会继续。

**Q3: 输出 byte 是否等同于 bit？**  
A: 不等同。byte 是端口类型；当数值只使用 0 和 1 时，它可以表示 bit 流。

**Q4: Vector Length 和 Vector 的长度不匹配怎么办？**  
A: 应保证 Vector 元素数量能按 Vector Length 分组。否则下游看到的数据组织方式可能与预期不一致。

**Q5: 可以运行时更新 Vector 吗？**  
A: Block 定义包含 `set_data(vector, tags)` 回调，因此支持更新数据和标签；常规流程通常在启动前完成配置。

## 典型应用场景

**前导码测试：**

```
[Vector Source] → [Correlate Access Code - Tag] → [Tag Debug]
```

**调制链路固定输入：**

```
[Vector Source] → [Repack Bits] → [PSK Mod] → [QT GUI Sink]
```

**向量算法输入：**

```
[Vector Source] → [Stream to Vector] → [FFT] → [Vector To Text File]
```

## 相关 Block

- [Random Source](Random_Source.md)：随机数据源
- [Constant Source](Constant_Source.md)：常数源
- [File Source](File_Source.md)：文件数据源
- [Stream to Tagged Stream](Stream_to_Tagged_Stream.md)：生成带标签流
- [Repack Bits](Repack_Bits.md)：bit 宽转换

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
