#!/bin/bash

#INSTALL_WAZUH=true
#HTTP_PROXY="http://force.curiostack.com:3128"

set -ex

sudo sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirrors.cloud.tencent.com/g' /etc/apt/sources.list
sudo sed -i 's/http:\/\/cn.archive.ubuntu.com/http:\/\/mirrors.cloud.tencent.com/g' /etc/apt/sources.list
sudo sed -i 's/http:\/\/security.ubuntu.com/http:\/\/mirrors.cloud.tencent.com/g' /etc/apt/sources.list
# sudo sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

sudo apt-get update
sudo apt-get dist-upgrade -yqq
sudo apt-get install -y unzip curl htop iftop iotop ntp fail2ban jq nano man sysfsutils sudo tmux lvm2 gnupg2 sysfsutils

# increase ulimit
echo 'fs.file-max = 1000000' | sudo tee -a '/etc/sysctl.conf'
echo 'vm.max_map_count = 262144' | sudo tee -a '/etc/sysctl.conf'
sudo sysctl -p

echo 'root soft nofile 1048576' | sudo tee -a '/etc/security/limits.conf'
echo 'root hard nofile 1048576' | sudo tee -a '/etc/security/limits.conf'
echo '* soft nofile 1048576' | sudo tee -a '/etc/security/limits.conf'
echo '* hard nofile 1048576' | sudo tee -a '/etc/security/limits.conf'

echo 'DefaultLimitNOFILE=1048576' | sudo tee -a '/etc/systemd/user.conf'
echo 'DefaultLimitNOFILE=2097152' | sudo tee -a '/etc/systemd/system.conf'

# disable THP
echo 'kernel/mm/transparent_hugepage/enabled = never' | sudo tee -a '/etc/sysfs.conf'
echo 'kernel/mm/transparent_hugepage/defrag = never' | sudo tee -a '/etc/sysfs.conf'

systemctl enable fail2ban
systemctl start fail2ban

## 这个后面要改成新的 wazuh 集群，后面在考虑

# 检查是否执行安装 Wazuh 的步骤
if [ $INSTALL_WAZUH = true ]; then
	# 下载并安装 Wazuh Agent
	HTTPS_PROXY=$HTTP_PROXY curl -so wazuh-agent.deb https://packages.wazuh.com/3.x/apt/pool/main/w/wazuh-agent/wazuh-agent_3.12.2-1_amd64.deb
	sudo WAZUH_MANAGER='wazuh-manager.curiostack.com' dpkg -i ./wazuh-agent.deb
fi
