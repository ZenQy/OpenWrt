#!/usr/bin/env bash

# 修改机器名称
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate
# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate
# 修改时区
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 替换默认主题,并移除其他主题依赖
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-light/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' package/feeds/luci/luci-ssl-nginx/Makefile

# 添加第三方仓库
mkdir -p package/community
cd package/community
git clone --depth=1 https://github.com/kiddin9/kwrt-packages

# 保留需要的软件
if [ $ADD_PLUGIN ]; then

   echo aria2
   echo "CONFIG_PACKAGE_luci-app-aria2=y" >> ../../.config
   # 最新版aria2无法运行，改用旧版
   # rm -rf ../../feeds/packages/net/aria2
   # mv kwrt-packages/aria2 ./

   # echo homeproxy
   # echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ../../.config
   # mv kwrt-packages/luci-app-homeproxy ./
   # mv kwrt-packages/sing-box ./

   # echo openclash
   # echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ../../.config
   # mv kwrt-packages/luci-app-openclash ./

   # echo mihomo
   echo "CONFIG_PACKAGE_luci-app-mihomo=y" >> ../../.config
   mv kwrt-packages/mihomo ./
   mv kwrt-packages/luci-app-mihomo ./

   echo netdata
   echo "CONFIG_PACKAGE_luci-app-netdata=y" >> ../../.config
   mv kwrt-packages/luci-app-netdata ./

   echo adguardhome
   echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> ../../.config
   echo "# CONFIG_PACKAGE_luci-app-adguardhome_INCLUDE_binary is not set" >> ../../.config
   mv kwrt-packages/luci-app-adguardhome ./
   sed -i 's/port: 1745/port: 53/g' luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml
   wget https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_arm64.tar.gz
   tar -xzvf AdGuardHome_linux_arm64.tar.gz
   mkdir -p ../base-files/files/usr/bin
   mv AdGuardHome/AdGuardHome ../base-files/files/usr/bin
   rm -rf AdGuardHome*

   echo alist
   echo "CONFIG_PACKAGE_luci-app-alist=y" >> ../../.config
   mv kwrt-packages/alist ./
   mv kwrt-packages/luci-app-alist ./

   echo filebrowser
   echo "CONFIG_PACKAGE_luci-app-filebrowser-go=y" >> ../../.config
   mv kwrt-packages/filebrowser ./
   mv kwrt-packages/luci-app-filebrowser-go ./

   # echo transmission
   # echo "CONFIG_PACKAGE_luci-app-transmission=y" >> ../../.config
   # echo "CONFIG_PACKAGE_transmission-web-control=y" >> ../../.config

   echo nezha
   echo "CONFIG_PACKAGE_luci-app-nezha-agent=y" >> ../../.config
   echo "CONFIG_PACKAGE_nezha-agent=y" >> ../../.config 
   mv kwrt-packages/luci-app-nezha ./
   mv kwrt-packages/openwrt-nezha ./

   echo turboacc
   echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE=y" >> ../../.config
   echo "# CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_SHORTCUT_FE_CM is not set" >> ../../.config
   echo "CONFIG_PACKAGE_luci-app-turboacc_INCLUDE_BBR_CCA=y" >> ../../.config
   mv kwrt-packages/luci-app-turboacc ./
   mv kwrt-packages/shortcut-fe ./
   mv kwrt-packages/dnsforwarder ./
   mv kwrt-packages/pdnsd-alt ./

fi

mv kwrt-packages/luci-theme-argon ./
rm -rf ../../feeds/luci/themes
rm -rf kwrt-packages

cd ../base-files/files

# authorized_keys
mkdir -p etc/dropbear
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCm/fzBKSSrwR8taYQURb/0p21tBpk6QCL9JviqUOvj' > etc/dropbear/authorized_keys
