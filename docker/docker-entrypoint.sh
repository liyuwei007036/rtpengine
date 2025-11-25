#!/bin/bash
# rtpengine Docker 入口脚本

set -e

# 默认配置文件
CONFIG_FILE="${RTPENGINE_CONFIG_FILE:-/etc/rtpengine/rtpengine.conf}"

# 主入口逻辑
case "$1" in
    rtpengine)
        shift
        echo "启动 rtpengine..."
        echo "配置文件: $CONFIG_FILE"
        
        if [ -f "$CONFIG_FILE" ]; then
            exec /usr/bin/rtpengine --config-file="$CONFIG_FILE" "$@"
        else
            echo "错误: 配置文件 $CONFIG_FILE 不存在"
            echo "请挂载配置文件或设置 RTPENGINE_CONFIG_FILE 环境变量"
            exit 1
        fi
        ;;
    
    rtpengine-recording)
        shift
        RECORDING_CONFIG="${RTPENGINE_RECORDING_CONFIG_FILE:-/etc/rtpengine/rtpengine-recording.conf}"
        echo "启动 rtpengine-recording..."
        
        if [ -f "$RECORDING_CONFIG" ]; then
            exec /usr/bin/rtpengine-recording --config-file="$RECORDING_CONFIG" "$@"
        else
            exec /usr/bin/rtpengine-recording "$@"
        fi
        ;;
    
    *)
        # 允许运行任意命令
        exec "$@"
        ;;
esac
