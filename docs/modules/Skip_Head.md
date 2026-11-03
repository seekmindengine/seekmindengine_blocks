# Skip Head 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Skip Head

## 概览

Skip Head 模块丢弃输入流最开始的指定数量项目，之后的数据原样输出。它常用于跳过文件开头的无效数据、丢弃滤波器或同步器启动瞬态，以及从某个偏移位置开始处理数据。

Num Items 统计的是 stream item 数，不是字节数。Vector Length 大于 1 时，一个 item 是一个向量。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Stream Operators（流操作） |
| Block ID | `blocks_skiphead` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

1. **跳过启动瞬态**  
   丢弃滤波器、同步器或硬件开始阶段的不稳定样本

2. **文件偏移读取**  
   忽略文件开头的一段样本

3. **中段截取**  
   与 Head 组合截取固定区间

4. **丢弃训练段**  
   跳过前导、训练序列或预热数据

5. **调试对齐**  
   改变后续处理看到的数据起点

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |
| 输出 | `默认` | 样本流 | 由数据类型和向量长度参数决定 | 连续样本流端口 |

> 数据类型、向量长度和标签传播规则属于连接契约。即使流程可以启动，配置不一致仍可能造成错位或语义错误。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 |
|---------|------|------|--------|
| **Type** | 枚举 | 数据类型：complex、float、int、short、byte | byte |
| **Num Items** | 整数 | 要跳过的流项目数量 | 4 |
| **Vector Length** | 整数 | 每个项目向量长度 | 1 |

## 参数说明

**1. Type（数据类型）**
- 输入和输出类型相同
- 用于确定每个 item 的字节大小
- 模块不改变样本值

**2. Num Items（跳过数量）**
- 表示丢弃开头多少个 stream items
- 对标量流就是样本数
- 对向量流就是向量个数

**3. Vector Length（向量长度）**
- 必须与上游输出 vlen 一致
- 默认为 1

## 工作原理

```
输入:  0 1 2 3 4 5 ...
跳过 4 个
输出: 4 5 ...
```

达到跳过数量后，后续数据不再被丢弃。

## 快速示例

**示例 1：跳过文件开头**

```
[File Source] → [Skip Head] → [Processing]
                Num Items=1024
```

**示例 2：截取中间数据**

```
[File Source] → [Skip Head] → [Head] → [File Sink]
                skip=10000     keep=50000
```

**示例 3：丢弃滤波器过渡**

```
[Source] → [Low Pass Filter] → [Skip Head] → [Analysis]
```

## 配置注意

1. **文件头需要自行换算**  
   如果文件前面有字节级文件头，Num Items 需要按 Type 和 Vector Length 换算成 item 数。

2. **不改变标签语义**  
   如果流中有标签，跳过开头数据后标签位置如何表现应通过 Tag Debug 验证。

3. **与 Head 顺序不能反**  
   截取中间片段应先 Skip Head 再 Head。

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: Num Items 是样本还是字节？**  
A: 是流项目数，不是字节数。Vector Length 大于 1 时，一个项目包含多个元素。

**Q2: 与 Head 有什么关系？**  
A: Skip Head 丢弃开头；Head 保留开头。二者组合可截取中间片段。

**Q3: 可以用于实时流吗？**  
A: 可以，常用于丢弃接收机刚启动时的样本。

## 相关 Block

- [Head](Head.md)：只保留前 N 个项目
- [File Source](File_Source.md)：文件读取
- [DC Blocker](DC_Blocker.md)：去除直流分量
- [Tag Debug](Tag_Debug.md)：观察标签变化

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
