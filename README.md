# 参数
型号： Ego1: Artex-7
器件: xc7a35tcsg324-1
Flash型号： N25Q32-3.3V
# 轻量级仿真方法
https://www.cnblogs.com/whik/p/11980103.html
+ iverilog -o wave led_demo_tb.v led_demo.v
+ vvp -n wave -lxt2
+ gtkwave wave.vcd
# 改进方案
  使用SRAM存储
# 编译失败解决方案
  + 尝试命令： ```vivado -stack 2000```
  https://fpga.eetrend.com/content/2019/100042946.html
# 参考资料
https://e-elements.readthedocs.io/zh/ego1_v2.2/EGo1.html#vga

https://eelab.njupt.edu.cn/_upload/article/files/66/b6/7a3337224205ab8c584a9062eb89/f7af8018-fba9-474a-82f8-01042c768ce0.pdf