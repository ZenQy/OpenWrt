#!/usr/bin/env bash

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