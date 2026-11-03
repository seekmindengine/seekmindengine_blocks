# Python Block 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Python Block

## 概览

Python Block 允许用户在 SeekMind Engine 流程编辑器中编写 Python 处理逻辑，用于快速验证算法、封装专用处理步骤和补足尚未组件化的能力。可使用 NumPy 批量运算实现算法；持续高负载链路需要在目标数据类型、批量大小和样本率下测量性能。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Misc（其他） |
| Block ID | `epy_block` |
| 处理模型 | 连续样本流 |
| 典型位置 | Transform（处理与变换） |
| 执行支持 | Python |

## 何时使用

1. **快速原型**  
   快速实现和测试新算法

2. **自定义处理**  
   实现特定的信号处理功能

3. **算法封装**  
   将自定义声学或振动处理算法封装为可复用模块

4. **临时解决方案**  
   在没有现成模块时快速实现功能

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `默认` | 样本流 | `any` | 连续样本流端口 |
| 输出 | `默认` | 样本流 | `any` | 连续样本流端口 |

> 连接前核对数据类型、向量长度、采样率语义和端口数量；首次运行使用可观察的 Sink 验证结果。

## 参数

Python Block 在流程编辑器中以嵌入式代码块形式出现，主要包含：
- 导入语句
- 类定义
- work 函数

## 模块类型

**1. sync_block**
- 输入输出 1:1 关系
- 最简单的模块类型

**2. sync_decimator**
- 输出少于输入（降采样）

**3. sync_interpolator**
- 输出多于输入（升采样）

**4. basic_block**
- 自行实现 general_work，并明确输入消耗与输出数量

## 工作原理

运行时按输入端口提供一批样本，并把可写的输出缓冲区交给 `work` 方法。处理逻辑必须返回实际生成的样本数，并保持声明的数据类型、端口数量和速率关系。需要跨批次保存的状态应作为实例字段维护，不能依赖单次输入缓冲区持续存在。

## 快速示例

**示例：复数共轭**

在编辑器生成的 Python Block 模板中保留接口声明，只替换 `work` 方法的处理主体：

```python
def work(self, input_items, output_items):
    n = min(len(input_items[0]), len(output_items[0]))
    np.conjugate(input_items[0][:n], out=output_items[0][:n])
    return n
```

输入与输出均选择 Complex。连接 Signal Source 与 QT GUI Constellation Sink 后，输出星座应沿实轴保持不变、沿虚轴镜像。该观察结果可用于确认算法和类型配置同时生效。

## 数据类型

| NumPy 类型 | SeekMind Engine 数据类型 | 说明 |
|-----------|---------------|------|
| np.complex64 | Complex | 复数 |
| np.float32 | Float | 浮点数 |
| np.int32 | Int | 整数 |
| np.int16 | Short | 短整数 |
| np.uint8 | Byte | 字节 |

## 性能与部署

1. **Python 性能**  
   性能取决于算法、批量处理方式和所调用的数值库，应以目标流程实测为准

2. **NumPy 优化**  
   使用 NumPy 向量化操作提高性能

3. **避免循环**  
   尽量使用 NumPy 数组操作而非 Python 循环

## 故障排查

**Q1: Python Block 性能如何？**  
A: 逐元素 Python 循环可能成为瓶颈；优先批量处理，再测量吞吐、CPU 与延迟。

**Q2: 如何添加参数？**  
A: 在编辑器提供的 Block 模板中声明构造参数；保存后，参数会显示在该 Block 的配置面板中。

**Q3: 可以有多个输入输出吗？**  
A: 可以，使用列表：`in_sig=[np.float32, np.float32]`

**Q4: 如何调试？**  
A: 使用 `print()` 语句或 Python 调试器。

**Q5: 可以保存状态吗？**  
A: 可以，在 `__init__` 中初始化成员变量。

## 最佳实践

1. **使用 NumPy**  
   充分利用 NumPy 的向量化操作

2. **避免状态**  
   尽量设计无状态模块，更容易调试

3. **测试**  
   先用小数据集测试，确保正确性

4. **文档**  
   添加注释说明算法和参数

## 相关 Block

- [Signal Source](Signal_Source.md)：提供可控的测试输入
- [QT GUI Time Sink](QT_GUI_Time_Sink.md)：观察时域输出
- [Message Debug](Message_Debug.md)：检查自定义消息处理结果

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
