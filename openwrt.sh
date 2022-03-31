#!/bin/bash

git config --global pull.ff only
git config --global core.sparsecheckout true
git config --global init.defaultBranch main

echo '#################################################'
echo '##                 开始更新主仓库                 ##'
echo '#################################################'
if [[ -d "openwrt" ]]; then
  cd openwrt
  git checkout .
  git pull
else
  git clone --depth=1 https://github.com/openwrt/openwrt
  cd openwrt
fi

echo '#################################################'
echo '##               开始更新第三方仓库               ##'
echo '#################################################'

# rm -rf feeds
sed -i '/packages.git/d' feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

if [[ -d "package/community" ]]; then
  cd package/community
  dirs=$(ls -l | awk '/^d/ {print $NF}')
  for dir in $dirs; do
    cd $dir
    git checkout .
    git pull
    cd ../
  done
else
  mkdir package/community
  cd package/community
  # Add repos
  git clone --depth=1 https://github.com/kiddin9/openwrt-packages
fi
cd ../../

echo '#################################################'
echo '##                 开始自定义修改                 ##'
echo '#################################################'
# echo '修改机器名称'
# sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.11/g' package/base-files/files/bin/config_generate

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# echo '增加部分翻译'
# echo -e '\nmsgid "NAS"\nmsgstr "存储"' >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo '替换默认主题'
rm -rf feeds/luci/themes/luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

echo '拷贝配置文件'
cp ../openwrt.config .config

echo '##################################################'
echo '##                  开始下载dl库                  ##'
echo '##################################################'

make -j8 download V=s

echo '##################################################'
echo '##                  开始编译固件                  ##'
echo '##################################################'

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
mv ../openwrt/.config $DIR/openwrt.config

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