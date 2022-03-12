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
sed -i 's/192.168.1.1/10.0.0.11/g' package/base-files/files/bin/config_generate

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash

# Add v2raya
# git clone --depth=1 https://github.com/zxlhhyccc/luci-app-v2raya
# git clone --depth=1 https://github.com/v2rayA/v2raya-openwrt

# 主题
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
popd
rm -rf feeds/luci/themes/luci-theme-argon

# 替换默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
