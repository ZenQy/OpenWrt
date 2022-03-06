#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

# echo '修改机器名称'
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add OpenClash
# git clone --depth=1 https://github.com/vernesong/OpenClash

# Add v2raya
git clone --depth=1 https://github.com/zxlhhyccc/luci-app-v2raya
git clone --depth=1 https://github.com/fw876/helloworld

# 主题
git clone -b 18.06 --depth=1 https://github.com/jerrykuku/luci-theme-argon

popd

# 替换默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
rm -rf feeds/luci/themes

# 删除部分DEFAULT_PACKAGES
sed -i 's/luci-app-ssr-plus //g' include/target.mk
sed -i 's/luci-app-unblockmusic //g' include/target.mk

# Openwrt version
version=$(grep "DISTRIB_REVISION=" package/lean/default-settings/files/zzz-default-settings  | awk -F "'" '{print $2}')
sed -i '/DISTRIB_REVISION/d' package/lean/default-settings/files/zzz-default-settings
echo "echo \"DISTRIB_REVISION='${version} $(TZ=UTC-8 date "+%Y.%m.%d") Compilde by ZenQy'\" >> /etc/openwrt_release" >> package/lean/default-settings/files/zzz-default-settings
sed -i '/exit 0/d' package/lean/default-settings/files/zzz-default-settings
echo "exit 0" >> package/lean/default-settings/files/zzz-default-settings
