# Message Debug 模块

[文档首页](../../README.md) / [Block 目录](../../README.md#block-目录) / Message Debug

## 概览

Message Debug 模块用于调试 SeekMind Engine 流程中的消息传递。它接收消息并将其内容打印到控制台，帮助开发者查看和调试消息流。

## 模块信息

| 项目 | 内容 |
|---|---|
| 分类 | Message Tools（消息工具） |
| Block ID | `blocks_message_debug` |
| 处理模型 | 消息 |
| 典型位置 | Sink（数据终点） |
| 执行支持 | Python / C++ |

## 何时使用

1. **消息调试**  
   查看消息端口传递的内容

2. **系统监控**  
   监控模块间的消息通信

3. **开发测试**  
   验证消息格式和内容

4. **故障排查**  
   定位消息传递问题

## 输入与输出

| 方向 | 端口 | 模型 | 数据类型 | 说明 |
|---|---|---|---|---|
| 输入 | `log` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输入 | `print` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输入 | `store` | 消息 | `按消息格式` | 离散消息端口；可选 |
| 输入 | `print_pdu` | 消息 | `按消息格式` | 离散消息端口；可选 |

> 消息端口按事件工作，不提供固定吞吐或到达间隔保证。调试时同时记录消息类型、键名和负载结构。

## 参数

| 参数名称 | 类型 | 说明 | 默认值 | 运行时可调 |
|---------|------|------|--------|-----------|
| **Print PDU contents** | 枚举 | 控制是否打印 PDU 载荷内容 | On | ✓ |
| **Log level** | 枚举 | 设置输出到日志的最低严重级别 | 🛈 Info (default) | ✓ |

## 工作原理

```
消息输入 → 解析 PMT → 格式化 → 打印到控制台
```

**输出格式：**
```
******* MESSAGE DEBUG PRINT ********
<消息内容>
************************************
```

## 快速示例

将 QT GUI Msg Push Button 的消息输出连接到 Message Debug 的 `print`，点击后应在控制台看到该按钮配置的 PMT pair。需要保存供程序读取时，另外连接 `store`；该端口保存到进程内存，不等于写文件。

PDU 可连接 `print` 或对应打印端口查看。流标签应由 Tag Debug 直接观察：Tag Debug 没有消息输出，不能再串接 Message Debug。

## 性能与部署

在目标采样率和数据规模下验证 CPU、内存与端到端延迟。动态参数、向量长度和并行通道增加时应重新测量。

## 故障排查

**Q1: 在哪里看到输出？**  
A: 在运行 SeekMind Engine 流程的终端/控制台中。

**Q2: 如何连接消息端口？**  
A: 在 SeekMind Engine 流程编辑器中，从上游 Block 的消息输出端口连接到 Message Debug 的输入端口。

**Q3: 可以保存消息到文件吗？**  
A: Message Debug 只打印到控制台。要保存需要重定向输出或使用其他模块。

**Q4: 消息太多怎么办？**  
A: 设置 Print to stdout=False 或移除 Message Debug 模块。

## 相关 Block

- [Tag Debug](Tag_Debug.md)：调试流标签
- **Message Strobe**：周期性发送消息
- **PDU to Tagged Stream**：PDU 转换

---

[返回 Block 目录](../../README.md#block-目录) | [核心概念](../CONCEPTS.md) | [故障排查](../TROUBLESHOOTING.md)
