# mit6.828
## 课程地址
https://pdos.csail.mit.edu/6.828/2018/
## 环境
vmware 
ubuntu 
qemu 
python3 

## lab1
引导 
BIOS - bootloader - kernel 
### BIOS
基本输入输出系统 硬件相关 
？-gcc调试时 boot.s前的汇编代码 
### bootloader
boot/boot.s  -  boot/main.c  -  
boot.s 关中断 清寄存器 打开A20地址线 切换到保护模式 跳到main.c bootmain() 
main.c 加载内核到内存 
