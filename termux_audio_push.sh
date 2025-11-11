#!/bin/bash

# Termux音频推送一体化工具包
# 作者: coolangcn
# 功能: 一体化解决Termux音频录制并推流到Icecast服务器的所有操作

# 脚本功能选项
case "$1" in
    install)
        # 安装模式
        echo "==========================================="
        echo "Termux音频推送 - 一键安装"
        echo "==========================================="
        
        # 检查是否在Termux环境中运行
        if [[ -z "$TERMUX_VERSION" ]]; then
            echo "错误: 此脚本必须在Termux环境中运行!"
            echo "请先安装Termux应用，然后在此环境中运行此脚本。"
            exit 1
        fi

        echo "检测到Termux环境，开始安装..."

        # 更新包列表
        echo "正在更新包列表..."
        pkg update -y

        # 安装必要的软件包
        echo "正在安装必要的软件包..."
        pkg install -y termux-api ffmpeg icecast

        # 创建Icecast配置文件
        echo "正在配置Icecast服务器..."
        ICECAST_CONFIG="/data/data/com.termux/files/usr/etc/icecast.xml"

        # 备份原始配置
        if [ ! -f "${ICECAST_CONFIG}.backup" ] && [ -f "$ICECAST_CONFIG" ]; then
            cp "$ICECAST_CONFIG" "${ICECAST_CONFIG}.backup"
            echo "已备份原始Icecast配置文件"
        fi

        # 生成新的Icecast配置文件
        cat > "$ICECAST_CONFIG" << 'EOF'
<icecast>
    <location>Earth</location>
    <admin>admin@localhost</admin>

    <limits>
        <clients>100</clients>
        <sources>2</sources>
        <queue-size>524288</queue-size>
        <client-timeout>30</client-timeout>
        <header-timeout>15</header-timeout>
        <source-timeout>10</source-timeout>
        <burst-on-connect>1</burst-on-connect>
        <burst-size>65535</burst-size>
    </limits>

    <authentication>
        <source-password>hackme</source-password>
        <relay-password>hackme</relay-password>
        <admin-user>admin</admin-user>
        <admin-password>hackme</admin-password>
    </authentication>

    <hostname>localhost</hostname>

    <listen-socket>
        <port>8000</port>
        <bind-address>0.0.0.0</bind-address>
    </listen-socket>

    <http-headers>
        <header name="Access-Control-Allow-Origin" value="*" />
    </http-headers>

    <paths>
        <basedir>/data/data/com.termux/files/usr/share/icecast</basedir>
        <logdir>/data/data/com.termux/files/usr/var/log/icecast</logdir>
        <webroot>/data/data/com.termux/files/usr/share/icecast/web</webroot>
        <adminroot>/data/data/com.termux/files/usr/share/icecast/admin</adminroot>
        <alias source="/" destination="/index.html"/>
    </paths>

    <logging>
        <accesslog>access.log</accesslog>
        <errorlog>error.log</errorlog>
        <loglevel>3</loglevel>
        <logsize>10000</logsize>
    </logging>

    <security>
        <chroot>0</chroot>
        <changeowner>
            <user>nobody</user>
            <group>nogroup</group>
        </changeowner>
    </security>
</icecast>
EOF

        echo "Icecast配置已完成!"
        echo "安装完成！"
        echo ""
        echo "重要提醒:"
        echo "1. 必须从F-Droid或Google Play安装Termux:API应用"
        echo "2. 在Android设置中为Termux和Termux:API关闭电池优化"
        echo "3. 手动授予Termux录音权限"
        echo ""
        echo "使用方法:"
        echo "- 启动服务器: ./termux_audio_push.sh server"
        echo "- 开始推流: ./termux_audio_push.sh stream"
        echo "- 停止所有服务: ./termux_audio_push.sh stop"
        echo ""
        ;;
        
    server)
        # 启动服务器模式
        echo "正在启动Icecast服务器..."
        icecast -c /data/data/com.termux/files/usr/etc/icecast.xml -b
        echo "Icecast服务器已在后台启动，监听端口8000"
        echo "您可以通过 http://[手机IP]:8000 访问服务器状态页面"
        echo "获取手机IP地址: ./termux_audio_push.sh ip"
        ;;
        
    stream)
        # 音频推流模式
        echo "开始音频推流..."
        echo "请确保已在系统设置中授予Termux录音权限，并关闭电池优化"
        
        # 检查是否已授予录音权限
        termux-microphone-record -r &>/dev/null
        if [ $? -ne 0 ]; then
            echo "警告: 可能未正确授予权限，请检查Termux和Termux:API的录音权限设置"
        fi
        
        # 显示手机IP地址
        IP=$(ip route get 1.1.1.1 2>&1 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1); exit}')
        echo "手机IP地址: $IP"
        echo "在电脑上访问 http://$IP:8000/live 来收听音频流"
        
        # 开始推流
        echo "正在启动音频推流..."
        termux-microphone-record -r 16000 -c 1 | ffmpeg -f s16le -ar 16000 -ac 1 -i - -codec:a libmp3lame -q:a 4 -f mp3 icecast://source:hackme@localhost:8000/live
        ;;
        
    ip)
        # 显示IP地址
        IP=$(ip route get 1.1.1.1 2>&1 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1); exit}')
        echo "手机IP地址: $IP"
        echo "访问地址: http://$IP:8000/live"
        ;;
        
    stop)
        # 停止所有相关进程
        echo "正在停止所有相关服务..."
        pkill -f "icecast"
        pkill -f "ffmpeg"
        pkill -f "termux-microphone-record"
        echo "所有服务已停止"
        ;;
        
    help|*)
        # 帮助信息
        echo "Termux音频推送一体化工具包"
        echo "使用方法:"
        echo "  ./termux_audio_push.sh install    - 安装所需组件并配置"
        echo "  ./termux_audio_push.sh server     - 启动Icecast服务器"
        echo "  ./termux_audio_push.sh stream     - 开始音频推流"
        echo "  ./termux_audio_push.sh ip         - 显示手机IP地址"
        echo "  ./termux_audio_push.sh stop       - 停止所有服务"
        echo "  ./termux_audio_push.sh help       - 显示此帮助信息"
        echo ""
        echo "首次使用请按顺序执行:"
        echo "  1. ./termux_audio_push.sh install"
        echo "  2. 完成手动设置(安装Termux:API应用、授权、关闭电池优化)"
        echo "  3. ./termux_audio_push.sh server"
        echo "  4. ./termux_audio_push.sh stream"
        echo ""
        echo "注意事项:"
        echo "- 需要在不同的Termux会话中分别运行server和stream命令"
        echo "- 推流时会在当前终端显示手机IP地址，用于访问音频流"
        ;;
esac