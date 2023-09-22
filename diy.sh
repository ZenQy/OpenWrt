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
rm -rf feeds/luci/themes

# 添加第三方仓库
mkdir -p package/community
cd package/community
git clone --depth=1 https://github.com/kiddin9/openwrt-packages

# 保留需要的软件
if [ $ADD_PLUGIN ]; then

   echo aria2
   echo "CONFIG_PACKAGE_luci-app-aria2=y" >> ../../.config

   echo homeproxy
   echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ../../.config
   mv openwrt-packages/luci-app-homeproxy ./
   mv openwrt-packages/chinadns-ng ./

   echo netdata
   echo "CONFIG_PACKAGE_luci-app-netdata=y" >> ../../.config
   mv openwrt-packages/luci-app-netdata ./

   echo adguardhome
   echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-adguardhome_INCLUDE_binary=y" >> ../../.config
   mv openwrt-packages/luci-app-adguardhome ./

   # echo mosdns
   # echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> ../../.config
   # echo "CONFIG_PACKAGE_mosdns=y" >> ../../.config
   # mv openwrt-packages/luci-app-mosdns ./
   # mv openwrt-packages/mosdns ./
   # mv openwrt-packages/v2dat ./

   echo alist
   echo "CONFIG_PACKAGE_luci-app-alist=y" >> ../../.config
   mv openwrt-packages/alist ./
   mv openwrt-packages/luci-app-alist ./

   echo filebrowser
   echo "CONFIG_PACKAGE_luci-app-filebrowser=y" >> ../../.config
   mv openwrt-packages/filebrowser ./
   mv openwrt-packages/luci-app-filebrowser ./

   echo transmission
   echo "CONFIG_PACKAGE_luci-app-transmission=y" >> ../../.config
   echo "CONFIG_PACKAGE_transmission-web-control=y" >> ../../.config

   echo turboacc
   echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE=y" >> ../../.config
   # echo "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE_CM=y" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_BBR_CCA=y" >> ../../.config
   mv openwrt-packages/luci-app-turboacc ./
   mv openwrt-packages/dnsforwarder ./
   mv openwrt-packages/shortcut-fe ./
   git clone --depth=1 https://github.com/op4packages/pdnsd-alt
fi
mv openwrt-packages/luci-theme-argon ./
rm -rf openwrt-packages

cd ../base-files/files

# authorized_keys
mkdir -p etc/dropbear
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCm/fzBKSSrwR8taYQURb/0p21tBpk6QCL9JviqUOvj' > etc/dropbear/authorized_keys
