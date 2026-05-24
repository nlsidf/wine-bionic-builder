# Wine Bionic Builder for Termux + Box64

使用 GitHub Actions 编译针对 Bionic (Android/Termux) 的 Wine x86_64 二进制文件，用于在 Termux 上通过 Box64 运行 Windows 程序。

## 项目目标

- 在 Ubuntu 环境中使用 Android NDK 交叉编译 Wine
- 生成与 Bionic libc 兼容的 x86_64 Wine 二进制文件
- 针对 Termux 环境优化（禁用 X11、OpenGL 等桌面依赖）
- 方便在 Termux 上配合 Box64 使用

## 系统要求

**构建环境**：
- Ubuntu latest (GitHub Actions 提供)
- Android NDK r27c (自动下载)

**运行环境**：
- Termux on Android
- Box64 translator installed

## 使用步骤

### 1. 触发构建

在 GitHub 上打开 Actions 页面，选择 **"Build Wine for Bionic (x86_64) - Termux compatible"**，点击 **"Run workflow"**

可选参数：
- **wine_version**: 指定 Wine 版本（如 `11.0`），留空则自动检测最新稳定版
- **ndk_version**: Android NDK 版本（默认 `r27c`）

### 2. 等待构建完成

构建过程通常需要 30-60 分钟，取决于网络和构建机器性能。

### 3. 下载构建产物

构建完成后，从 Actions 的 Artifacts 中下载：
- `wine-bionic-X.Y-x86_64-termux.tar.xz` - Wine 二进制文件
- `wine-bionic-X.Y-x86_64-termux.tar.xz.sha256` - 完整性校验文件
- `BUILD_INFO.txt` - 构建信息

### 4. 在 Termux 中安装

```bash
# 使用 sftp/scp 或其他方式将 tar.xz 文件上传到 Termux

# 进入 Termux 终端
pkg install box64 wget  # 如果还没装 box64

# 解压到 $PREFIX
cd $PREFIX
tar -xJf wine-bionic-*.tar.xz

# 验证安装
file $PREFIX/opt/wine/bin/wine
```

## 特性说明

此构建包含完整的 Wine 功能：

### 显卡/3D 加速
- **OpenGL**: 全面支持，可用于 3D 游戏和应用
- **Vulkan**: 现代图形 API 支持
- **Mesa**: 软件渲染支持 (OpenGL)

### 多媒体
- **音频**: ALSA + PulseAudio 双重支持
- **视频**: GStreamer 支持，支持多种视频解码
- **摄像头**: V4L2 视频捕获，GPhoto2 数码相机支持

### 网络和外设
- **打印**: CUPS 网络打印支持
- **扫描**: SANE 扫描设备支持
- **USB**: USB 设备访问支持
- **DBus**: 系统服务集成

### 文本和内容
- **字体**: FreeType 字体渲染
- **文档**: XML/XSLT 支持
- **国际化**: gettext 多语言支持

**注意**: 在 Termux/Box64 上，部分功能（如 X11 GUI）可能无法完全工作，但基础功能（游戏、图形应用）应该能够正常运行。

## 构建特性

### 启用的功能
- Windows x86_64 支持 (`--enable-win64`)
- FreeType / 字体支持 (`--with-freetype`)
- XML 支持 (`--with-xml`)
- OpenGL 3D 加速 (`--with-opengl --with-osmesa`)
- Vulkan 支持 (`--with-vulkan`)
- 音频支持 (`--with-alsa --with-pulse`)
- 多媒体支持 (`--with-gstreamer`)
- 网络打印 (`--with-cups`)
- 扫描 (`--with-sane`)
- USB 支持 (`--with-usb`)
- DBus 支持 (`--with-dbus`)
- V4L2 视频 (`--with-v4l2`)
- XSLT 转换 (`--with-xslt`)
- 摄像头支持 (`--with-gphoto`)
- 基础 NTDLL 和运行时库

### 禁用的项目
- 生产环境测试 (`--disable-tests`)

## 项目结构

```
.github/
  workflows/
    build-wine.yml          # 主工作流文件
    build-wine-bionic.yml   # 旧版本（参考）
  docker/
    Dockerfile              # 旧版本 Docker 镜像

scripts/
  build-wine.sh            # 构建脚本

README.md                   # 本文件
```

## 问题排查

### 构建失败：configure 错误
- 检查 Wine 源代码下载是否成功
- 查看日志中的具体错误信息

### Wine 在 Termux 中无法运行
```bash
# 检查依赖
ldd $PREFIX/opt/wine/bin/wine

# 检查架构是否正确
file $PREFIX/opt/wine/bin/wine
# 应该显示: x86-64

# 检查 Box64 是否正确
which box64
box64 --version
```

### 运行 Windows 程序报错
1. 确保程序是 x86_64 (PE) 格式，不是 ARM 格式
2. 尝试增加 Box64 调试日志：`BOX64_DYNAREC=0 BOX64_LOG=1`
3. 检查程序所需的 DLL 是否在 Wine 中有实现

## 参考资源

- [Wine 官方文档](https://www.winehq.org/)
- [Box64 GitHub](https://github.com/ptitSeb/box64)
- [Termux 官方文档](https://termux.dev/)
- [Android NDK 下载](https://developer.android.com/ndk/downloads)

## 许可证

此项目遵循 Wine 的原始许可证（LGPL）。
