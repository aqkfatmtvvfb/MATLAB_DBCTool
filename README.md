DBC与EXCEL互转工具，可用于多个DBC的手动合并（每个DBC生成Excel，手动粘贴到一个Excel中并手动去重修改，再生成DBC）

局限性：
- 只能解析BO_、SG_、VAL_三个关键字
- DLC设置为8Byte
- 信号接收节点全部设置为Vector__XXX
- 不支持扩展帧
- 不支持复用

update 2024/4/4

- 在Excel中加入了一个标识唯一性的列用于辅助去重
- 增加了一个主控脚本，将目录下的所有dbc转为excel并合并为一个excel。
