# mit6.828
## 课程地址
https://pdos.csail.mit.edu/6.828/2018/
## 环境
vmware   
ubuntu    
qemu 虚拟机 跑kernel  
python3 跑测试评分脚本 实验代码默认使用python(.grade-lab文件中修改)   

## lab1 
引导   
BIOS - bootloader - kernel   

### BIOS
基本输入输出系统 硬件相关   
gcc调试时 boot.s前的汇编代码   
默认将boot代码加载到0x7c00  
查看编译生成的asm文件 可以看到boot.s代码开始的IP为X07C00
     
### bootloader
boot/boot.s  -  boot/main.c  -   kern/entry.s  

boot.s  
关中断 清寄存器 打开A20地址线  
切换到保护模式 跳到main.c bootmain()    

main.c  
加载ELF头到内存0x1000  
读取ELF头信息 加载kernel到内存  

kernel/entry.s  
加载页目录 打开分页

## lab2
内存管理
inc/memlayout.h  -  kern/pmap.c  

### inc/memlayout.h
内存布局

### kern/pmap.c
页映射接口-待实现

### 坑
check_page_free_list()中
先执行*tp[pagetype] = pp;   tp[pagetype] = &pp->pp_link;
将低地址(pdx < pdx_limit)的页放在链头 高地址页链在低地址链后
调换了页表顺序
再执行memset(page2kva(pp), 0x97, 128)中
低地址的page2kva(pp) 与 高地址pp值冲突
0xf0155078(冲突的地址 可能不固定)
低地址遍历时踩到高地址pp中存的链结构信息 导致链断 
不改check_page_free_list的情况下无法通过