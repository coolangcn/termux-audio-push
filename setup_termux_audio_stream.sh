#!/bin/bash

# Termux音频推送一键安装脚本
# 作者: coolangcn
# 功能: 在Termux中设置音频录制并推流到Icecast服务器

echo "==========================================="
echo "Termux音频推送一键安装脚本"
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

# 创建Icecast配置备份
echo "正在配置Icecast服务器..."
ICECAST_CONFIG="/data/data/com.termux/files/usr/etc/icecast.xml"

if [ ! -f "${ICECAST_CONFIG}.backup" ]; then
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

    <mount>
        <mount-name>/live</mount-name>
        <mount-type>aac</mount-type>
    </mount>
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

# 创建启动Icecast服务器的脚本
cat > "/data/data/com.termux/files/home/start_icecast.sh" << 'EOF'
#!/bin/bash
# 启动Icecast服务器

echo "正在启动Icecast服务器..."
icecast -c /data/data/com.termux/files/usr/etc/icecast.xml

echo "Icecast服务器已在后台启动，监听端口8000"
echo "您可以通过 http://[手机IP]:8000 访问服务器状态页面"
EOF

chmod +x "/data/data/com.termux/files/home/start_icecast.sh"

# 创建音频推流脚本
cat > "/data/data/com.termux/files/home/audio_stream.sh" << 'EOF'
#!/bin/bash
# 音频推流脚本

echo "开始音频推流..."
echo "请确保已在系统设置中授予Termux录音权限，并关闭电池优化"

# 检查是否已授予录音权限
termux-microphone-record -r &>/dev/null
if [ $? -ne 0 ]; then
    echo "警告: 可能未正确授予权限，请检查Termux和Termux:API的录音权限设置"
fi

# 开始推流
termux-microphone-record -r 16000 -c 1 | ffmpeg -f s16le -ar 16000 -ac 1 -i - -codec:a aac -b:a 96k -content_type audio/aac -f adts icecast://source:hackme@localhost:8000/live

echo "音频推流已停止"
EOF

chmod +x "/data/data/com.termux/files/home/audio_stream.sh"

# 创建使用说明
cat > "/data/data/com.termux/files/home/README.txt" << 'EOF'
Termux音频推送使用说明
========================

重要提醒:
--------
1. 必须从F-Droid或Google Play安装Termux:API应用
2. 在Android设置中为Termux和Termux:API应用关闭电池优化
3. 手动授予Termux录音权限

安装步骤:
--------
1. 运行此一键安装脚本后，所需软件包会自动安装
2. 配置文件已自动生成

使用方法:
--------
1. 启动Icecast服务器:
   ./start_icecast.sh

2. 在新Termux会话中开始音频推流:
   ./audio_stream.sh

3. 在电脑或其他设备上访问:
   http://[手机IP地址]:8000/live

停止服务:
--------
要停止服务，请按Ctrl+C终止相应脚本进程

故障排除:
--------
如果遇到问题，请检查:
1. 是否已正确安装Termux:API应用
2. 是否已授予录音权限
3. 是否已关闭电池优化
4. 确保端口8000未被其他程序占用
EOF

echo ""
echo "安装完成！"
echo "==========================================="
echo "接下来需要手动操作:"
echo "1. 从F-Droid或Google Play安装Termux:API应用"
echo "2. 在Android设置中为Termux和Termux:API关闭电池优化"
echo "3. 授予Termux录音权限"
echo ""
echo "然后可以使用以下命令:"
echo "- 启动服务器: ~/start_icecast.sh"
echo "- 开始推流: ~/audio_stream.sh"
echo ""
echo "详细说明请查看: ~/README.txt"
echo "==========================================="