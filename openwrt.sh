#!/bin/bash

#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

# 修改config_generate

echo '修改默认IP'
sed -i 's/192.168.1.1/10.0.0.11/g' package/base-files/files/bin/config_generate

echo '默认时区'
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

echo 'NTP服务器'
sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time.ustc.edu.cn/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/cn.pool.ntp.org/g' package/base-files/files/bin/config_generate

# echo '修改机器名称'
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate

echo '设置默认语言'
sed -i "1a \nuci set luci.main.lang=zh_cn\nuci commit luci" package/base-files/files/bin/config_generate 

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash

# Add theme
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon

# Add netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata

popd

# 替换默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
