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

## 使用 Wine with Box64

```bash
# 直接运行 Windows 程序
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine program.exe

# 或设置别名方便使用
alias wine='BOX64_PATH=$PREFIX/opt/wine/bin box64 wine'
wine program.exe

# 进阶：设置环境变量
export BOX64_PATH=$PREFIX/opt/wine/bin
export WINE=$PREFIX/opt/wine/bin/wine
box64 $WINE program.exe
```

## 构建特性

### 启用的功能
- Windows x86_64 支持 (`--enable-win64`)
- 基础 NTDLL 和运行时库

### 禁用的功能（为了减少依赖）
- X11 / GUI (`--without-x`)
- FreeType / 字体 (`--without-freetype`)
- OpenGL (`--without-opengl`)
- ALSA/Pulse 音频 (`--without-alsa --without-pulse`)
- 网络打印/扫描 (`--without-cups --without-sane`)

### 编译配置
- **Compiler**: Clang (from Android NDK)
- **Target**: `x86_64-linux-android`
- **API Level**: 24
- **Optimization**: -O2 -march=x86-64

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
