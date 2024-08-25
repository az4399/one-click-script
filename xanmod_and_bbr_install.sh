#!/bin/bash

# 先更新下
sudo apt update -y && sudo apt upgrade -y


# 检测 CPU 支持的指令集级别
cpu_level=$(awk '
BEGIN {
    while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
    if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
    if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
    if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
    if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
    if (level > 0) { print level; exit level }
    exit 1
}
')

# 判断获取到的level，安装相应版本的Xanmod内核
if [[ $cpu_level -eq 1 ]]; then
    kernel_version="linux-xanmod-x64v1"
elif [[ $cpu_level -eq 2 ]]; then
    kernel_version="linux-xanmod-rt-x64v2"
elif [[ $cpu_level -eq 3 ]]; then
    kernel_version="linux-xanmod-rt-x64v3"
elif [[ $cpu_level -eq 4 ]]; then
    kernel_version="linux-xanmod-rt-x64v4"
else
    echo "CPU does not support any known x86-64-v levels."
    exit 1
fi

echo "CPU supports x86-64-v$cpu_level, installing $kernel_version."

# 安装 gpg
sudo apt-get install -y gpg

# 添加 Xanmod 仓库的 GPG 密钥
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg

# 添加 Xanmod 仓库
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list

# 更新包列表
sudo apt update

# 安装相应版本的内核
sudo apt-get install -y $kernel_version

# 开启BBRv3
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Xanmod kernel and BBRv3 configuration complete."

# 提示用户按回车键以重启系统
read -p "Press Enter to reboot the system..."
sudo reboot
