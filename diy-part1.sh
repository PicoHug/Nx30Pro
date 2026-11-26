#!/bin/bash
# 阶段1：在 feeds update 之前运行 —— 注入 PassWall 源
# 该脚本由 workflow 在 openwrt 目录下调用

sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '2i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default

echo ">>> diy-part1 完成：PassWall 源已加入 feeds.conf.default"
cat feeds.conf.default
