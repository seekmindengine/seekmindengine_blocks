# Argmax 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Argmax

## 概览

Argmax 在同一时刻的全部输入向量中寻找最大数值，输出其向量内位置 `max_vec` 和输入端口编号 `max_inp`。两个结果都是从 0 开始的 short 索引；需要最大值本身时使用 Max。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Math Operators（数学运算） |
| Block ID | `blocks_argmax_xx` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python / C++ |

## 何时使用

- 在多路已经计算好的幅度、功率或评分向量中定位峰值。
- 同时确定峰值所在的通道和向量元素位置。

模块比较数值大小，不取绝对值，也不直接执行波束形成或方向估计。

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `0 .. Num Inputs-1` | 样本流 | float、int 或 short × Vector Length | 每次从每个输入取一个向量 |
| 输出 | `max_vec` | 样本流 | short | 最大值在向量内的索引 |
| 输出 | `max_inp` | 样本流 | short | 最大值所在输入的编号 |

两个输出都必须连接；只观察一路时，可将另一路接到 Short 类型的 Null Sink。索引范围需能用有符号 16 位整数表示。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---|---|---|---|---|
| **IO Type** | 枚举 | 输入类型；输出固定为 short | float | ✗ |
| **Num Inputs** | 整数 | 输入端口数量，至少为 1 | 2 | ✗ |
| **Vector Length** | 整数 | 每个输入 item 的元素数量，至少为 1 | 1 | ✗ |

## 工作原理

每轮比较 Num Inputs × Vector Length 个值，产生一对索引。相同最大值出现多次时，按“先向量位置、再输入编号”的遍历顺序保留第一次遇到的位置。

```text
输入0: [1, 9, 3]
输入1: [4, 5, 8]
max_vec: 1
max_inp: 0
```

Vector Length=1 时，max_vec 总为 0；max_inp 指出当前标量最大值来自哪一路。

当前 Short 选项的生成模板映射为 `argmax_dd`，与运行接口名称不一致；Short 流程需要修复该定义后再验证。本页示例使用 Float。

## 快速示例

用两个 Float Vector Source，Vector Length=3、Repeat=No，Vector 分别为 `[1,9,3]` 和 `[4,5,8]`。Argmax 设置 IO Type=Float、Num Inputs=2、Vector Length=3。两个输出分别连接 Short File Sink，结果应为 `max_vec=[1]`、`max_inp=[0]`。

## 性能与部署

每轮比较量随输入数量和向量长度增加。所有必需输入都要有数据才能继续；有限测试序列应具有相同的向量 item 数。

## 故障排查

| 现象 | 可能原因 | 处理方式 |
|---|---|---|
| 输出是小整数而不是峰值 | 输出含义理解错误 | 按索引解释，或改用 Max |
| 较大负幅度未被选中 | 比较的是数值而非绝对值 | 在上游先计算幅度或功率 |
| 无输出 | 输入供数不足或输出未连接 | 检查全部输入及两个 Short 输出 |

## 相关 Block

- [Max](Max.md)：仅输出最大值
- [Add](Add.md)：信号求和

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
