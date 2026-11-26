# H3C NX30 Pro 云编译仓库

P大 `immortalwrt-mt798x-6.6`（`openwrt-24.10-6.6`）+ PassWall，单设备 profile 精确锁定
`DEVICE_h3c_magic-nx30-pro`（OpenWrt U-Boot layout，**非 nmbm**）。

> 适用机器：H3C Magic NX30 Pro / V100R010（原厂底层 OpenWrt 21.02，MT7981B）。
> 编译结果含四类产物，与刷机清单第 4、5 节配套：
> `preloader.bin`、`bl31-uboot.fip`、`initramfs-recovery.itb`、`squashfs-sysupgrade.itb`

---

## 一、建仓库（一次性）

1. 登录 GitHub，点右上角 `+` → **New repository**
2. 仓库名随便，例如 `nx30pro-build`
3. 选 **Public**（GitHub Actions 对公开仓库免费；私有仓库有分钟额度限制）
4. 勾选 **Add a README file**，点 Create repository

## 二、上传文件

把这个文件夹里的 4 个文件按下面路径传上去（网页上传时目录名直接写带点的即可）：

| 本地文件 | 仓库路径 |
|---|---|
| `.github/workflows/build.yml` | `.github/workflows/build.yml` |
| `.config` | `.config` |
| `diy-part1.sh` | `diy-part1.sh` |
| `diy-part2.sh` | `diy-part2.sh` |

> 网页传 `.github` 开头的文件：点 Add file → Create new file，文件名栏直接输入
> `.github/workflows/build.yml`（斜杠会自动建成目录）。

也可以命令行一把推上去（在本文件夹里执行）：

```bash
git init
git add . && git commit -m "nx30pro cloud build"
git remote add origin https://github.com/<你的用户名>/nx30pro-build.git
git branch -M main
git push -u origin main
```

## 三、开始编译

1. 进仓库 → **Actions** 标签 → 左侧选 **Build NX30Pro (P大 24.10-6.6 + PassWall)**
2. 点右侧 **Run workflow** → 保持默认 → 再点绿色 **Run workflow**
3. 首次编译约 **1.5~2.5 小时**（GitHub 免费 runner 比本地 M1 Pro 慢）
4. 编译卡住超过 30 分钟没动静：重新 Run，这次把 SSH 调试选 `true`，进去看日志

## 四、下载固件

编译成功后两个地方都能拿：

- **Releases**（推荐）：仓库首页右侧 Releases → 下 `nx30pro-1` .tag 里的 4 个文件
- **Actions  Artifacts**：那次运行页面底部 Artifacts → `NX30Pro-firmware`

下载后核对文件名里含 `h3c_magic-nx30-pro`，四类文件齐全：

```
openwrt-mediatek-filogic-h3c_magic-nx30-pro-preloader.bin
openwrt-mediatek-filogic-h3c_magic-nx30-pro-bl31-uboot.fip
...-initramfs-recovery.itb
...-squashfs-sysupgrade.itb
```

然后回到 `H3C_NX30Pro_刷机清单.md` 从第 2 节开始操作。

---

## 五、常见问题

**Q：编译失败，`make download` 阶段报某个包 404？**
A：源码分支上游删包了。重新 Run 一次；连续失败就在 Actions 里开 SSH，
   进去 `make defconfig V=s` 看具体缺哪个包。

**Q：编译出来的文件名是 `h3c_magic-nx30-pro-nmbm`？**
A：设备选错了。确认 `.config` 里是
   `CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_h3c_magic-nx30-pro=y`，不含 `-nmbm`。
   `diy-part2.sh` 和 workflow 的 `make defconfig` 后都有硬校验，正常不会出这个错。

**Q：能不能加别的插件？**
A：编辑 `.config`，加 `CONFIG_PACKAGE_<包名>=y`，push 后重新 Run。
   注意别开硬件卸载相关的 flow offloading（清单第 6 节有说明）。

**Q：编译要钱吗？**
A：公开仓库的 Actions 免费。私有仓库每月 2000 分钟额度，一次编译就快用完了，
   所以建仓库时选 Public。

**Q：我在 Mac 上操作会不会有问题？**
A：不会。编译全程在 GitHub 的 Linux 服务器上，Mac 只用来上传文件和下载固件。
