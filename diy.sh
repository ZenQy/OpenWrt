#!/usr/bin/env bash

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

# 修改.config
echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> .config
echo "CONFIG_PACKAGE_luci-app-adguardhome_INCLUDE_binary=y" >> .config
echo "CONFIG_PACKAGE_luci-app-alist=y" >> .config
echo "CONFIG_PACKAGE_luci-app-filebrowser=y" >> .config
echo "CONFIG_PACKAGE_luci-app-xray=y" >> .config
echo "CONFIG_PACKAGE_luci-app-singbox=y" >> .config

# 添加第三方仓库
mkdir -p package/community
cd package/community
git clone --depth=1 https://github.com/kiddin9/openwrt-packages
git clone --depth=1 https://github.com/ttimasdf/luci-app-xray
git clone --depth=1 https://github.com/ZenQy/xxxx

# 删除第三方仓库不用的软件
cd openwrt-packages
ls | grep -v luci-theme-argon \
   | grep -v luci-app-netdata \
   | grep -v adguardhome \
   | grep -v alist \
   | grep -v filebrowser \
   | grep -v sing-box \
   | xargs  rm -rf

cd ../../base-files/files
# 下载clash文件
# mkdir -p etc/openclash/core
# CLASH_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/dev/premium?ref=core | grep download_url | grep arm64 | awk -F '"' '{print $4}')
# GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
# # GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
# wget -qO- $CLASH_URL | gunzip -c > etc/openclash/core/clash_tun
# wget -qO- $GEOIP_URL > etc/openclash/GeoIP.dat
# # wget -qO- $GEOSITE_URL > etc/openclash/GeoSite.dat
# chmod +x etc/openclash/core/clash*

# authorized_keys
mkdir -p etc/dropbear
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDby5ETsMVosxG6x7y7siSU8UtTlROYzR183QEEp+lGrDEnfJ6Ozk2aIEEcLbo/MbiG+efdD03h8gwdbfTDytYY+3yPlhVC7XsmzqsAoKD9CYXtU0GyHkaIn8/1l0KK42VYgoi02dA5GDNf0N0b1ly013lmaWjkrwF/3ww6PkjXfzyD7k/TqyitYeJctPJZjLjhZc/OB3nPdZT95XDZ4ArnIDBoJajd2zlf0EwpJJ9ALwYX7gM1cHteV0kzT7WhkK9iLGEQcnQq0IVpVBzG47+t7mwAi/OnN9NAb8bg0PCxX3oesHGQ96mbS0RXvfAqCb4UQqAN2fEVOCSWwQjfGwhb zenqy@linux' > etc/dropbear/authorized_keys
