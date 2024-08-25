
# 添加swap
##################################################
# 创建 swap 文件
sudo fallocate -l 1G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1G count=1

# 设置文件权限
sudo chmod 600 /swapfile

# 格式化为 swap 空间
sudo mkswap /swapfile

# 启用 swap 文件
sudo swapon /swapfile

# 验证 swap 是否启用
swapon --show
free -h

# 使 swap 文件在系统重启后自动挂载
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab



# 启用zram
##################################################
# 安装 zram-tools
sudo apt update
sudo apt install -y zram-tools

# 配置 zRAM
echo -e "ALGO=lz4\nPERCENT=50" | sudo tee /etc/default/zramswap

# 启用 zRAM
sudo systemctl enable zramswap
sudo systemctl start zramswap

# 验证 zRAM 是否启用
sudo zramctl
free -h
