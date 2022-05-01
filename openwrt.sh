#!/bin/bash

echo '#################################################'
echo '##                 开始更新主仓库                 ##'
echo '#################################################'
if [[ -d "openwrt" ]]; then
  cd openwrt
  git checkout .
  git pull
else
  git clone --depth=1 https://github.com/coolsnowwolf/lede openwrt
  cd openwrt
fi

echo '#################################################'
echo '##               开始更新第三方仓库               ##'
echo '#################################################'

if [[ -d "package/community" ]]; then
  rm -rf package/community
fi

mkdir package/community
cd package/community
# Add repos
# git clone --depth=1 https://github.com/kenzok8/openwrt-packages
git clone --depth=1 https://github.com/thinktip/luci-theme-neobird
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash
if [[ ! -f "../base-files/files/etc/openclash/core/clash" ]]; then
  mkdir -p ../base-files/files/etc/openclash/core
  wget https://raw.githubusercontent.com/vernesong/OpenClash/master/core-lateset/dev/clash-linux-armv8.tar.gz
  tar -zxvf clash-linux-armv8.tar.gz -C ../base-files/files/etc/openclash/core
  rm clash-linux-armv8.tar.gz
fi
git clone --depth=1 https://github.com/immortalwrt-collections/openwrt-gowebdav
cd ../../

./scripts/feeds update -a
./scripts/feeds install -a

echo '#################################################'
echo '##                 开始自定义修改                 ##'
echo '#################################################'

# echo '修改机器名称'
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate

echo '修改默认IP'
sed -i 's/192.168.1.1/10.0.0.11/g' package/base-files/files/bin/config_generate

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

echo '增加部分翻译'
echo -e '\nmsgid "NAS"\nmsgstr "存储"' >> feeds/luci/modules/luci-base/po/zh-cn/base.po

echo '替换默认主题'
sed -i 's/luci-theme-bootstrap/luci-theme-neobird/g' feeds/luci/collections/luci/Makefile

echo '删除部分DEFAULT_PACKAGES'
sed -i 's/luci-app-ssr-plus //g' include/target.mk
sed -i 's/luci-app-unblockmusic //g' include/target.mk
sed -i 's/luci-app-ddns //g' include/target.mk
sed -i 's/ddns-scripts_aliyun //g' include/target.mk
sed -i 's/ddns-scripts_dnspod //g' include/target.mk
sed -i 's/ppp-mod-pppoe //g' include/target.mk
sed -i 's/ppp //g' include/target.mk
sed -i '/rclone-ng/d' feeds/luci/applications/luci-app-rclone/Makefile
sed -i "s/default y\nendef/endef/g" feeds/luci/applications/luci-app-rclone/Makefile

echo '修改打包版本信息'
version=$(grep "DISTRIB_REVISION=" package/lean/default-settings/files/zzz-default-settings  | awk -F "'" '{print $2}')
sed -i '/DISTRIB_REVISION/d' package/lean/default-settings/files/zzz-default-settings
echo "echo \"DISTRIB_REVISION='${version} $(TZ=UTC-8 date "+%Y.%m.%d") Compilde by Zenith'\" >> /etc/openwrt_release" >> package/lean/default-settings/files/zzz-default-settings
sed -i '/exit 0/d' package/lean/default-settings/files/zzz-default-settings
echo "exit 0" >> package/lean/default-settings/files/zzz-default-settings

echo '拷贝配置文件'
cp ../openwrt.config .config

echo '##################################################'
echo '##                  开始下载dl库                  ##'
echo '##################################################'

make -j8 download V=s

echo '##################################################'
echo '##                  开始编译固件                  ##'
echo '##################################################'

make defconfig
make -j$(($(nproc) + 1)) V=s
cd ../

echo '#################################################'
echo '##              开始搭建固件制作环境              ##'
echo '#################################################'
if [[ -d "openwrt_packit" ]]; then
  cd openwrt_packit
  git checkout .
  git pull
else
  git clone --depth=1 https://github.com/unifreq/openwrt_packit
  cd openwrt_packit
fi
mv ../openwrt/bin/targets/armvirt/64/openwrt-armvirt-64-default-rootfs.tar.gz ./
echo "WHOAMI=Zenith" > whoami
echo "KERNEL_PKG_HOME=$HOME/kernel" >> whoami
sed -i 's/ENABLE_WIFI_K504=1/ENABLE_WIFI_K504=0/g' make.env
sed -i 's/ENABLE_WIFI_K510=1/ENABLE_WIFI_K510=0/g' make.env
source make.env
KERNEL_VERSION_SHORT=$(echo $KERNEL_VERSION | awk -F- '{print $1}')
cd ../

[[ -d "kernel" ]] || mkdir kernel
cd kernel
[[ -e "boot-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/breakings/OpenWrt/raw/main/opt/kernel/${KERNEL_VERSION_SHORT}/boot-${KERNEL_VERSION}.tar.gz"
[[ -e "modules-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/breakings/OpenWrt/raw/main/opt/kernel/${KERNEL_VERSION_SHORT}/modules-${KERNEL_VERSION}.tar.gz"
[[ -e "dtb-amlogic-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/breakings/OpenWrt/raw/main/opt/kernel/${KERNEL_VERSION_SHORT}/dtb-amlogic-${KERNEL_VERSION}.tar.gz"

echo '#################################################'
echo '##                  开始制作固件                 ##'
echo '#################################################'
cd ../openwrt_packit
sudo ./mk_s905d_n1.sh
sudo ./mk_s905x3_multi.sh
sudo chown -R zenqy:zenqy output
rm openwrt-armvirt-64-default-rootfs.tar.gz
cd output
gzip -9 *.img
cd ../../

echo '#################################################'
echo '##               开始将固件存放仓库               ##'
echo '#################################################'
[[ -d "repo" ]] || mkdir repo
cd repo
DIR=$(date +%F)
[[ -d "$DIR" ]] || mkdir $DIR
mv ../openwrt_packit/output/*.gz $DIR/
cp ../openwrt/.config $DIR/openwrt.config

DIRS=$(ls)
COUNT=$(ls | wc -l)
for dir in $DIRS
do  
  [[ $COUNT > 5 ]] && rm -rf $dir
  COUNT=$(($COUNT-1))
done

echo '#################################################'
echo '##                   工作结束                   ##'
echo '#################################################'
