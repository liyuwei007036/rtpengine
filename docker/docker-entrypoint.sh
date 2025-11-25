#!/bin/bash
# rtpengine Docker 入口脚本

set -e

# 默认配置文件
CONFIG_FILE="${RTPENGINE_CONFIG_FILE:-/etc/rtpengine/rtpengine.conf}"

# 构建额外的命令行参数 (基于环境变量)
# 环境变量会覆盖配置文件中的对应设置
build_extra_args() {
    local args=""

    # RTPENGINE_TABLE: iptables 表编号，-1 表示用户空间转发模式 (容器推荐)
    [ -n "$RTPENGINE_TABLE" ] && args="$args --table=$RTPENGINE_TABLE"

    # RTPENGINE_INTERFACE: 网络接口配置，格式: [NAME/]IP[!IP]
    [ -n "$RTPENGINE_INTERFACE" ] && args="$args --interface=$RTPENGINE_INTERFACE"

    # RTPENGINE_LISTEN_NG: ng 控制协议监听地址，格式: [IP:]PORT
    [ -n "$RTPENGINE_LISTEN_NG" ] && args="$args --listen-ng=$RTPENGINE_LISTEN_NG"

    # RTPENGINE_LISTEN_CLI: CLI 管理接口监听地址，格式: [IP:]PORT
    [ -n "$RTPENGINE_LISTEN_CLI" ] && args="$args --listen-cli=$RTPENGINE_LISTEN_CLI"

    # RTPENGINE_LISTEN_HTTP: HTTP/REST API 监听地址，格式: [IP:]PORT
    [ -n "$RTPENGINE_LISTEN_HTTP" ] && args="$args --listen-http=$RTPENGINE_LISTEN_HTTP"

    # RTPENGINE_PORT_MIN: RTP 端口范围最小值 (默认: 30000)
    [ -n "$RTPENGINE_PORT_MIN" ] && args="$args --port-min=$RTPENGINE_PORT_MIN"

    # RTPENGINE_PORT_MAX: RTP 端口范围最大值 (默认: 40000)
    [ -n "$RTPENGINE_PORT_MAX" ] && args="$args --port-max=$RTPENGINE_PORT_MAX"

    # RTPENGINE_LOG_LEVEL: 日志级别 1-7，数值越高越详细 (6=INFO, 7=DEBUG)
    [ -n "$RTPENGINE_LOG_LEVEL" ] && args="$args --log-level=$RTPENGINE_LOG_LEVEL"

    # RTPENGINE_REDIS: Redis 连接地址，格式: [password@]host:port/db
    [ -n "$RTPENGINE_REDIS" ] && args="$args --redis=$RTPENGINE_REDIS"

    # RTPENGINE_HOMER: Homer SIPCAPTURE 地址，格式: host:port
    [ -n "$RTPENGINE_HOMER" ] && args="$args --homer=$RTPENGINE_HOMER"

    # RTPENGINE_GRAPHITE: Graphite 指标服务器地址，格式: host:port
    [ -n "$RTPENGINE_GRAPHITE" ] && args="$args --graphite=$RTPENGINE_GRAPHITE"

    # RTPENGINE_EXTRA_OPTS: 额外的命令行参数，直接追加到命令行
    [ -n "$RTPENGINE_EXTRA_OPTS" ] && args="$args $RTPENGINE_EXTRA_OPTS"

    echo "$args"
}

# 主入口逻辑
case "$1" in
    rtpengine)
        shift
        echo "启动 rtpengine..."
        echo "配置文件: $CONFIG_FILE"
        
        EXTRA_ARGS=$(build_extra_args)
        [ -n "$EXTRA_ARGS" ] && echo "额外参数: $EXTRA_ARGS"
        
        if [ -f "$CONFIG_FILE" ]; then
            exec /usr/bin/rtpengine --config-file="$CONFIG_FILE" $EXTRA_ARGS "$@"
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
