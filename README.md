# OpenWrt

[![lede](https://img.shields.io/badge/github-lede-blue.svg?style=flat&logo=github)](https://github.com/coolsnowwolf/lede)
![GitHub](https://img.shields.io/github/license/ZenQy/Openwrt)

## 如何使用

1. fork项目
2. 在secrets中创建`RELEASES_TOKEN`，一般一次编译要2~4小时，所以要创建一个github发布用的token
3. 在secrets中创建`TELEGRAM_TO`和`TELEGRAM_TOKEN`，用户通知
4. 点击Actions -> Workflows -> Run workflow -> Run workflow 
5. Build Flippy OpenWrt Package 编译n1等盒子可用包

------

## 用户名和密码

 * User: root
 * Password: password
 * Default IP: 10.0.0.11

------

## 全新刷入emmc方法

  1. 固件刷入U盘。
  2. openwrt-install-amlogic
  3. 拔掉U盘，断电重启

------

## 在线升级方法

  1. 上传 img 到/mnt/mmcblk2p4
  2. cd /mnt/mmcblk2p4
  3. gzip -d  *.img.gz
  4. openwrt-update-amlogic openwrt_*.img

------

## 感激 

 - [暴躁老哥](https://github.com/breakings/OpenWrt)
 - [mingxiaoyu](https://github.com/mingxiaoyu/N1Openwrt)

## License

[MIT](https://github.com/ZenQy/Openwrt/blob/main/LICENSE)