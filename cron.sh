#!/bin/bash

function update_main_repo() {
  if [[ -d "openwrt" ]]; then
    cd openwrt
    git checkout .
    git pull -f
    cd ..
  else
    git clone -b openwrt-22.03 --depth=1 https://github.com/openwrt/openwrt openwrt
  fi
  echo '======更新主仓库结束======'
}

function update_3rd_repo() {
  if [[ -d "package/community/openwrt-packages" ]]; then
    cd package/community/openwrt-packages
    git checkout .
    git pull -f
    cd ../../..
  else
    mkdir -p package/community
    cd package/community
    git clone --depth=1 https://github.com/kiddin9/openwrt-packages
    cd ../..
  fi
  echo '======更新第三方仓库结束======'
}

function update_feeds() {
  if [[ -d "feeds" ]]; then
    cd feeds
    for dir in 'luci' 'packages' 'routing' 'telephony'
    do
      if [[ -d $dir ]]; then
        cd $dir
        git checkout .
        git pull -f
        cd ..
      fi
    done
    cd ..
  fi
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  echo '======更新feeds仓库结束======'
}

while :
do
  update_main_repo
  cd openwrt
  update_3rd_repo
  update_feeds
  cd ..
  sleep 1d
done

