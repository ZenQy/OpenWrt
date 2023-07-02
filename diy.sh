#!/usr/bin/env bash

# 修改机器名称
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate
# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate
# 修改时区
# sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 替换默认主题,并移除其他主题依赖
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-ssl-nginx/Makefile
# 删除原仓库软件
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/luci/themes

# 添加第三方仓库
mkdir -p package/community
cd package/community
git clone --depth=1 https://github.com/kiddin9/openwrt-packages

# 保留需要的软件
if [ $ADD_PLUGIN ]; then

   # aria2
   echo "CONFIG_PACKAGE_luci-app-aria2=y" >> ../../.config
   # singbox
   echo "CONFIG_PACKAGE_luci-app-singbox=y" >> ../../.config
   git clone --depth=1 https://github.com/ZenQy/xxxx luci-app-singbox
   # netdata
   echo "CONFIG_PACKAGE_luci-app-netdata=y" >> ../../.config
   mv openwrt-packages/luci-app-netdata ./
   # adguardhome
   echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-adguardhome_INCLUDE_binary=y" >> ../../.config
   mv openwrt-packages/adguardhome ./
   mv openwrt-packages/luci-app-adguardhome ./
   # mosdns
   echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> ../../.config
   echo "CONFIG_PACKAGE_mosdns=y" >> ../../.config
   mv openwrt-packages/luci-app-mosdns ./
   mv openwrt-packages/mosdns ./
   mv openwrt-packages/v2dat ./
   # alist
   echo "CONFIG_PACKAGE_luci-app-alist=y" >> ../../.config
   mv openwrt-packages/alist ./
   mv openwrt-packages/luci-app-alist ./
   # filebrowser
   echo "CONFIG_PACKAGE_luci-app-filebrowser=y" >> ../../.config
   mv openwrt-packages/filebrowser ./
   mv openwrt-packages/luci-app-filebrowser ./
   # chatgpt
   echo "CONFIG_PACKAGE_luci-app-chatgpt=y" >> ../../.config
   git clone --depth=1 https://github.com/sirpdboy/chatgpt-web luci-app-chatgpt
fi
mv openwrt-packages/luci-theme-argon ./
rm -rf openwrt-packages

cd ../base-files/files
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
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCm/fzBKSSrwR8taYQURb/0p21tBpk6QCL9JviqUOvj nixos@hp' > etc/dropbear/authorized_keys
