#!/bin/bash
# 阶段2：feeds install 之后、编译之前运行
# 1) 清掉 feeds 自带的过时代理核心（含阶段1注入源产生的软链）
# 2) 用 PassWall 官方组织的最新版本直接 clone 到 package/
# 3) 校验 profile 确实锁定了 NX30 Pro（非 nmbm）

cd "$(dirname "$0")/openwrt" || exit 1

# 移除 feeds 里自带的旧代理核心 / 插件（不同源软链一并清掉）
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls,smartdns}
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/passwall_packages feeds/passwall_luci
rm -rf package/passwall-packages package/passwall-luci

# 用官方维护组织的最新版本替换（直接 clone，避免 feeds 软链冲突）
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# 诊断：打印当前目录和 .config 里的设备行，便于定位
echo ">>> diy-part2 pwd = $(pwd)"
echo ">>> .config 里的 PROFILE 行："
grep -E 'CONFIG_TARGET_PROFILE|CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_h3c' .config || echo "    (无)"

# 兜底：若 PROFILE 行不在，直接补写（个别 checkout 场景下会丢），不终止编译
if ! grep -q '^CONFIG_TARGET_PROFILE=' .config; then
  echo 'CONFIG_TARGET_PROFILE="DEVICE_h3c_magic-nx30-pro"' >> .config
  echo ">>> 已补写 CONFIG_TARGET_PROFILE"
fi

# 校验：DEVICE=y 必须存在；PROFILE 补写后必须指向正确设备
if ! grep -q '^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_h3c_magic-nx30-pro=y' .config; then
  echo "!!! 错误：.config 未锁定 h3c_magic-nx30-pro，终止编译"
  exit 1
fi
if ! grep -q '^CONFIG_TARGET_PROFILE="DEVICE_h3c_magic-nx30-pro"' .config; then
  echo "!!! 错误：PROFILE 未指向 h3c_magic-nx30-pro，终止编译"
  exit 1
fi
if grep -q '^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_h3c_magic-nx30-pro-nmbm=y' .config; then
  echo "!!! 错误：误选了 nmbm 版，终止编译"
  exit 1
fi

echo ">>> diy-part2 完成：PassWall 核心已替换，NX30 Pro 设备(PROFILE+DEVICE)校验通过"
