#!/usr/bin/env bash
# ============================================================
# 算算星球 · 安装脚本（macOS / Linux）
#
# 用「应用商店」的身份安装 APK，让系统不再把它当成侧载应用，
# 从而避开 Android 13+ 的「受限设置」：
#   - 无障碍开关可以直接打开
#   - 每次覆盖安装后不会被系统自动关掉
#
# 用法：
#   bash tools/install-apk.sh                     # 自动用项目根目录的 apk
#   bash tools/install-apk.sh ~/Downloads/app.apk
# ============================================================
set -e

PKG="cn.zsonit.suansuan"
APK="${1:-}"

if [ -z "$APK" ]; then
  APK=$(ls -t "$(dirname "$0")"/../*.apk 2>/dev/null | head -1 || true)
fi

if [ -z "$APK" ] || [ ! -f "$APK" ]; then
  echo "[错误] 没找到 APK。把 apk 放到项目根目录，或传路径："
  echo "       bash tools/install-apk.sh ~/Downloads/app-debug.apk"
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "[错误] 没找到 adb。请安装 Android Platform Tools 并加入 PATH。"
  echo "       macOS: brew install --cask android-platform-tools"
  exit 1
fi

echo "已连接设备："
adb devices
echo
echo "按「应用商店」身份安装：$APK"
adb install -r -i com.android.vending "$APK" || {
  echo
  echo "[失败] 常见原因："
  echo "  1. 已装版本签名不同 → adb uninstall $PKG 后再试"
  echo "  2. 版本号更低     → 加 -d 参数：adb install -r -d -i com.android.vending \"$APK\""
  exit 1
}

# 兜底：部分机型/系统版本还需要显式放行受限设置
adb shell cmd appops set "$PKG" ACCESS_RESTRICTED_SETTINGS allow >/dev/null 2>&1 || true

echo
echo "============================================================"
echo " 安装完成"
echo " 手机上：算算星球 → 设置 → 专注锁定 → 去开启"
echo " 无障碍开关现在应可直接打开；以后更新都用本脚本安装。"
echo "============================================================"
