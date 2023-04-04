#!/usr/bin/env bash

# 修改.config
#

# 修改机器名称
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate
# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate
# 修改时区
# sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 替换默认主题,并移除其他主题依赖
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/+luci-theme-openwrt//g' package/feeds/luci/luci-light/Makefile
sed -i 's/+luci-theme-bootstrap//g' package/feeds/luci/luci-nginx/Makefile
sed -i 's/+luci-theme-bootstrap//g' package/feeds/luci/luci-ssl-nginx/Makefile
# 删除原仓库软件
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/luci/themes

# 添加第三方仓库
mkdir -p package/community
cd package/community
git clone --depth=1 https://github.com/kiddin9/openwrt-packages
# 删除第三方仓库不用的软件
cd openwrt-packages
ls | grep -v adguardhome \
   | grep -v luci-theme-argon \
   | grep -v luci-app-netdata \
   | grep -v alist \
   | grep -v filebrowser \
   | grep -v luci-app-v2raya \
   | xargs  rm -rf

# authorized_keys
mkdir -p etc/dropbear
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDby5ETsMVosxG6x7y7siSU8UtTlROYzR183QEEp+lGrDEnfJ6Ozk2aIEEcLbo/MbiG+efdD03h8gwdbfTDytYY+3yPlhVC7XsmzqsAoKD9CYXtU0GyHkaIn8/1l0KK42VYgoi02dA5GDNf0N0b1ly013lmaWjkrwF/3ww6PkjXfzyD7k/TqyitYeJctPJZjLjhZc/OB3nPdZT95XDZ4ArnIDBoJajd2zlf0EwpJJ9ALwYX7gM1cHteV0kzT7WhkK9iLGEQcnQq0IVpVBzG47+t7mwAi/OnN9NAb8bg0PCxX3oesHGQ96mbS0RXvfAqCb4UQqAN2fEVOCSWwQjfGwhb zenqy@linux' > etc/dropbear/authorized_keys
