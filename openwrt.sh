#!/bin/bash

function modify_repo() {
  echo '======开始自定义修改======'

  # echo '修改机器名称'
  # sed -i 's/OpenWrt/Phicomm-N1/g' package/base-files/files/bin/config_generate

  # echo '修改默认IP'
  sed -i 's/192.168.1.1/10.0.0.5/g' package/base-files/files/bin/config_generate

  # echo '修改时区'
  sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

  # echo '替换默认主题'
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
  # rm -rf feeds/luci/themes

  # 删除原仓库软件
  rm -rf  feeds/packages/net/adguardhome
  # 删除feeds仓库软件

  # 删除第三方仓库软件
  cd package/community/openwrt-packages
  ls | grep -v adguardhome \
     | grep -v luci-app-openclash \
     | grep -v alist \
     | grep -v luci-theme-argon \
     | xargs  rm -rf
  cd ../../..
}

function update_packit() {
  echo '======开始搭建固件制作环境======'
  if [[ -d "openwrt_packit" ]]; then
    cd openwrt_packit
    git checkout .
    git pull
  else
    git clone --depth=1 https://github.com/unifreq/openwrt_packit
    cd openwrt_packit
  fi

  mv ../openwrt/bin/targets/armvirt/64/openwrt-armvirt-64-default-rootfs.tar.gz ./
}

function modify_packit() {
  # modify dtb
  sed -i 's|FDT=/dtb/amlogic/meson-sm1-x96-max-plus-100m.dtb|#FDT=/dtb/amlogic/meson-sm1-x96-max-plus-100m.dtb|g' mk_s905x3_multi.sh
  sed -i 's|#FDT=/dtb/amlogic/meson-sm1-tx3-qz.dtb|FDT=/dtb/amlogic/meson-sm1-tx3-qz.dtb|g' mk_s905x3_multi.sh
  # remove clash adjust
  sed -i '/openclash/d' mk_s905*.sh
  # remove ss
  sed -i '/extract_glibc_programs/d' mk_s905*.sh
  # remove AdguardHome init
  sed -i '/AdGuardHome\/data/d' files/first_run.sh
  sed -i '/bin\/AdGuardHome/d' files/first_run.sh
  sed -i '/AdGuardHome/,+1d' files/openwrt-update-amlogic
  sed -i '/bin\/AdGuardHome/d' files/openwrt-install-amlogic
  # add alist、rclone buckup
  sed -i 's/usr\/share\/openclash\/core/etc\/alist\/ \\\
  .\/root\/.config\/rclone/g' files/openwrt-backup
}

function update_kernel() {
  source make.env
  KERNEL_VERSION_SHORT=$(echo $KERNEL_VERSION | awk -F- '{print $1}')
  cd ../

  echo "WHOAMI=Zenith" > openwrt_packit/whoami
  echo "KERNEL_PKG_HOME=$PWD/kernel" >> openwrt_packit/whoami

  [[ -d "kernel" ]] || mkdir kernel
  cd kernel
  [[ -e "boot-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/ophub/kernel/raw/main/pub/stable/${KERNEL_VERSION_SHORT}/boot-${KERNEL_VERSION}.tar.gz"
  [[ -e "modules-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/ophub/kernel/raw/main/pub/stable/${KERNEL_VERSION_SHORT}/modules-${KERNEL_VERSION}.tar.gz"
  [[ -e "dtb-amlogic-${KERNEL_VERSION}.tar.gz" ]] || wget "https://github.com/ophub/kernel/raw/main/pub/stable/${KERNEL_VERSION_SHORT}/dtb-amlogic-${KERNEL_VERSION}.tar.gz"
}

function do_packit() {
  echo '======开始制作固件======'
  cd ../openwrt_packit
  sudo ./mk_s905d_n1.sh
  sudo ./mk_s905x3_multi.sh
  sudo chown -R zenqy:zenqy output
  rm openwrt-armvirt-64-default-rootfs.tar.gz
  cd output
  gzip -9 *.img
  cd ../../
}

function move_to_repo() {
  echo '======开始将固件存放仓库======'
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
}


# echo '======开始======'

# 设置环境变量
export GOPROXY=https://goproxy.cn

cd openwrt
# echo '拷贝配置文件'
# cp -f ../openwrt.config .config

modify_repo

# echo '======开始下载dl库======'
make -j$(nproc) download V=s

# echo '======开始编译固件======'
make -j$(nproc) V=s
cd ../

update_packit

modify_packit

update_kernel

do_packit

move_to_repo

echo '======结束======'

