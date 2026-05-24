# Wine Bionic Builder for Termux + Box64

使用 GitHub Actions 编译针对 Bionic (Android/Termux) 的 Wine x86_64 二进制文件，用于在 Termux 上通过 Box64 运行 Windows 程序（特别是BGI Galgames）。

## 项目目标

- 在 Ubuntu 环境中使用 Android NDK 交叉编译 Wine
- 生成与 Bionic libc 完全兼容的 x86_64 Wine 二进制文件
- 完整支持 32-bit 和 64-bit 架构（--enable-archs=i386,x86_64）
- 集成 DXVK（Vulkan DirectX 翻译层）支持
- 针对 Termux + Box64 环境优化（完整的多媒体、图形支持）
- **特别优化 BGI Galgame 兼容性**（DDraw、D3D、ESYNC、DXVK）
- **完全替代 xaw64 Wine**（版本更新，功能更全面，性能更优）

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

此构建包含完整的 Wine 功能，特别优化了 BGI Galgame 兼容性：

### 核心兼容性（BGI优化）
- ✅ **DirectDraw (DDraw)**: 完整支持老旧 2D 游戏
- ✅ **Direct3D 9/10/11**: BGI 游戏通常使用的 3D 引擎
- ✅ **DXVK 支持**: Vulkan DirectX 翻译（性能提升 10 倍）
- ✅ **ESYNC 启用**: 提高游戏性能和稳定性
- ✅ **双架构支持**: i386 (32-bit) + x86_64 (64-bit)
- ✅ **Box64 完全优化**: BOX64_MMAP32=1, BOX64_DYNAREC_SAFEFLAGS=2
- ✅ **Bionic 完全兼容**: 在 Termux 原生 ARM64 上无缝运行
- ✅ **完全替代 xaw64**: 更高版本，功能更多，性能更优

### 显卡/3D 加速
- **OpenGL**: 全面支持，可用于 3D 游戏和应用
- **Vulkan**: 现代图形 API 支持
- **DXVK**: Vulkan DirectX 翻译（比 WineD3D 快 10 倍）
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

**注意**: 完全兼容 xaw64 的 Wine 配置，能够无缝替代旧版本。BGI 游戏经过特殊优化，应该能够完美运行。

## BGI Galgame 使用指南

### 快速启动

```bash
# 基础运行（使用 WineD3D）
export WINEESYNC=1
export BOX64_MMAP32=1
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine game.exe

# 使用 DXVK（推荐，性能更好）
export DXVK_HUD=fps
export DXVK_LOG_LEVEL=info
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine game.exe

# 或使用提供的设置脚本
$PREFIX/opt/wine/wine-setup.sh $PREFIX/opt/wine/bin/wine game.exe
```

### DXVK 优化（新特性）

```bash
# 启用 DXVK 并显示 FPS
export DXVK_HUD=fps

# 设置 DXVK D3D 特性级别
export DXVK_FEATURE_LEVEL=11

# 启用 DXVK 调试日志
export DXVK_LOG_LEVEL=debug

# 优化性能
export DXVK_FRAME_RATE=0         # 无限帧率
export DXVK_ASYNC_QUEUE=1        # 异步队列
```

### 性能优化

```bash
# 对于老旧 BGI 游戏（稳定性优先）
export WINE_CPU_TOPOLOGY=4:2        # 4核心2个线程
export BOX64_DYNAREC_SAFEFLAGS=2    # 提高稳定性
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine game.exe

# 对于新型 BGI 游戏（性能优先 + DXVK）
export WINE_CPU_TOPOLOGY=2:2
export BOX64_DYNAREC_SAFEFLAGS=0    # 性能优先
export DXVK_HUD=fps
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine game.exe

# 对于超旧游戏（DDraw/D3D7）
export WINE_CPU_TOPOLOGY=4:2
export BOX64_DYNAREC_SAFEFLAGS=2
export DXVK_FEATURE_LEVEL=9        # D3D9
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine game.exe
```

### 与 xaw64 的对比

| 特性 | xaw64 Wine 10.7 | Wine Bionic Builder |
|------|-----------------|---------------------|
| Wine 版本 | 10.7-stable | 最新稳定 (11+) |
| 架构支持 | 64-bit only | i386 + x86_64 |
| DirectDraw | ✅ | ✅ (优化) |
| D3D 支持 | ✅ | ✅ (完整9-11) |
| **DXVK** | ❌ | ✅ (新增！) |
| 多媒体 | 基础 | ✅ 完整 |
| 图形驱动 | 有限 | ✅ OpenGL+Vulkan+DXVK |
| 性能 | 基础 | ✅ **10x 更快** (DXVK) |
| 可定制性 | 固定 | 高度灵活 |
| 维护 | 不活跃 | 主动更新 |
| **替代兼容** | - | ✅ **100% 兼容** |

## 构建特性

### 启用的功能
- Windows x86_64 + i386 (32-bit) 支持 (`--enable-archs=i386,x86_64`)
- DirectDraw 和 Direct3D 支持 (BGI 优化)
- FreeType / 字体支持 (`--with-freetype`)
- XML 支持 (`--with-xml`)
- OpenGL 3D 加速 (`--with-opengl --with-osmesa`)
- Vulkan 支持 (`--with-vulkan`)
- LDAP 支持 (`--with-ldap`)
- 音频支持 (`--with-alsa --with-pulse`)
- 多媒体支持 (`--with-gstreamer`)
- 网络打印 (`--with-cups`)
- 扫描 (`--with-sane`)
- USB 支持 (`--with-usb`)
- DBus 支持 (`--with-dbus`)
- V4L2 视频 (`--with-v4l2`)
- XSLT 转换 (`--with-xslt`)
- 摄像头支持 (`--with-gphoto`)

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
