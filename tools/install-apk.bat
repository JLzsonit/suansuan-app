@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================
REM 算算星球 · 安装脚本（Windows）
REM 作用：用「应用商店」的身份安装 APK，让系统不把它当成侧载应用，
REM       从而彻底避开 Android 13+ 的「受限设置」——无障碍开关可以直接打开，
REM       以后每次覆盖安装也不会再被关掉。
REM 用法：把 apk 放在项目根目录，双击本脚本；或命令行传路径：
REM       install-apk.bat D:\path\app-debug.apk
REM ============================================================

set "PKG=cn.zsonit.suansuan"
set "APK=%~1"

if "%APK%"=="" (
  for %%f in ("%~dp0..\*.apk") do set "APK=%%~ff"
)

if "%APK%"=="" (
  echo [错误] 没找到 APK。
  echo        把 apk 放到项目根目录，或这样调用：
  echo        install-apk.bat 你的路径\app-debug.apk
  pause
  exit /b 1
)
if not exist "%APK%" (
  echo [错误] 文件不存在：%APK%
  pause
  exit /b 1
)

where adb >nul 2>nul
if errorlevel 1 (
  echo [错误] 没找到 adb。
  echo        1. 下载 Android Platform Tools（platform-tools 压缩包）
  echo        2. 解压后把里面的 adb.exe 所在目录加入系统 PATH
  echo        3. 手机打开「开发者选项 - USB 调试」，用数据线连电脑，允许调试
  echo        4. 重新双击本脚本
  pause
  exit /b 1
)

echo.
echo 检查设备连接...
adb devices
echo.
echo 正在按「应用商店」身份安装：
echo   %APK%
echo.
adb install -r -i com.android.vending "%APK%"

if errorlevel 1 (
  echo.
  echo [失败] 常见原因：
  echo   1. 手机上是旧版本且签名不同 -^> 先卸载再装：adb uninstall %PKG%
  echo   2. 手机没允许 USB 调试 / 没点「允许」弹窗
  echo   3. 版本号低于已装版本 -^> 加 -d 参数降级安装
  pause
  exit /b 1
)

echo.
echo 兜底：直接把「受限设置」放行（部分机型/系统版本需要）
adb shell cmd appops set %PKG% ACCESS_RESTRICTED_SETTINGS allow >nul 2>nul

echo.
echo ============================================================
echo  安装完成
echo.
echo  手机上打开「算算星球」- 设置 - 专注锁定
echo  点「去开启」，无障碍开关现在应该可以直接打开了。
echo.
echo  以后每次更新都请用本脚本安装，开关不会再被系统关掉。
echo ============================================================
pause
