# Termux音频推送工具

这是一个一体化脚本，用于在Termux中设置音频录制并推流到Icecast服务器。

## 功能特性

- 一键安装所有必需组件 (termux-api, ffmpeg, icecast)
- 自动配置Icecast服务器
- 集成启动服务器、推流、停止服务等功能
- 显示手机IP地址以便访问音频流

## 使用方法

### 1. 下载脚本

将 [termux_audio_push.sh](./termux_audio_push.sh) 文件传输到您的Termux设备中。

### 2. 添加执行权限

```bash
chmod +x termux_audio_push.sh
```

### 3. 安装组件

```bash
./termux_audio_push.sh install
```

### 4. 完成手动设置

根据提示完成以下手动操作：
1. 从F-Droid或Google Play安装Termux:API应用
2. 在Android设置中为Termux和Termux:API关闭电池优化
3. 手动授予Termux录音权限

### 5. 启动服务器

在第一个Termux会话中运行：
```bash
./termux_audio_push.sh server
```

### 6. 开始推流

在第二个Termux会话中运行：
```bash
./termux_audio_push.sh stream
```

### 7. 访问音频流

在电脑或其他设备的浏览器或音频播放器中访问：
```
http://[手机IP地址]:8000/live
```

您可以通过以下命令获取手机IP地址：
```bash
./termux_audio_push.sh ip
```

## 命令参考

- `./termux_audio_push.sh install` - 安装所需组件并配置
- `./termux_audio_push.sh server` - 启动Icecast服务器
- `./termux_audio_push.sh stream` - 开始音频推流
- `./termux_audio_push.sh ip` - 显示手机IP地址
- `./termux_audio_push.sh stop` - 停止所有服务
- `./termux_audio_push.sh help` - 显示帮助信息

## 注意事项

1. 需要在不同的Termux会话中分别运行server和stream命令
2. 确保已在Android设置中正确配置权限和电池优化
<<<<<<< HEAD
3. 如果遇到问题，请使用stop命令停止所有服务后重新开始
=======
3. 如果遇到问题，请使用stop命令停止所有服务后重新开始

## 许可证

MIT License

## 作者

[coolangcn](https://github.com/coolangcn)
>>>>>>> 3ca187f02c0263f15b2edaf1eb6b1af224dc82cd
