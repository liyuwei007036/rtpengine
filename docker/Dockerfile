# rtpengine 多阶段 Dockerfile
# 阶段 1: 构建器 - 编译 rtpengine 及所有依赖
# 阶段 2: 运行时 - 仅包含运行时依赖的最小镜像

#############################################
# 阶段 1: 构建器
#############################################
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 配置中国镜像源 (阿里云)
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    debhelper-compat \
    default-libmysqlclient-dev \
    gperf \
    git \
    libavcodec-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libbcg729-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libhiredis-dev \
    libiptc-dev \
    libjson-glib-dev \
    libjwt-dev \
    libmnl-dev \
    libmosquitto-dev \
    libnftnl-dev \
    libopus-dev \
    libpcap0.8-dev \
    libpcre2-dev \
    libspandsp-dev \
    libssl-dev \
    libswresample-dev \
    libsystemd-dev \
    libwebsockets-dev \
    libxtables-dev \
    markdown \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制源代码
WORKDIR /usr/src/rtpengine
COPY . .

# 编译 rtpengine 守护进程和录音守护进程
RUN make clean && make with_transcoding=yes

#############################################
# 阶段 2: 运行时
#############################################
FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# 配置中国镜像源 (阿里云)
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libavcodec59 \
    libavfilter8 \
    libavformat59 \
    libavutil57 \
    libbcg729-0 \
    libcurl4 \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    libglib2.0-0 \
    libhiredis0.14 \
    libip4tc2 \
    libip6tc2 \
    libjson-glib-1.0-0 \
    libjwt0 \
    libmnl0 \
    libmosquitto1 \
    libmysqlclient21 \
    libnftnl11 \
    libopus0 \
    libpcap0.8 \
    libpcre2-8-0 \
    libspandsp2 \
    libssl3 \
    libswresample4 \
    libsystemd0 \
    libwebsockets19 \
    libxtables12 \
    zlib1g \
    perl \
    libconfig-tiny-perl \
    libbencode-perl \
    libio-socket-inet6-perl \
    libsocket6-perl \
    libjson-perl \
    libwww-perl \
    && rm -rf /var/lib/apt/lists/*

# 创建 rtpengine 用户和组
RUN groupadd -r rtpengine && useradd -r -g rtpengine rtpengine

# 创建必要的目录
RUN mkdir -p /etc/rtpengine /var/spool/rtpengine /var/log/rtpengine \
    && chown -R rtpengine:rtpengine /var/spool/rtpengine /var/log/rtpengine

# 从构建器复制二进制文件
COPY --from=builder /usr/src/rtpengine/daemon/rtpengine /usr/bin/rtpengine
COPY --from=builder /usr/src/rtpengine/recording-daemon/rtpengine-recording /usr/bin/rtpengine-recording
COPY --from=builder /usr/src/rtpengine/utils/rtpengine-ctl /usr/bin/rtpengine-ctl
COPY --from=builder /usr/src/rtpengine/utils/rtpengine-ng-client /usr/bin/rtpengine-ng-client

# 复制 Perl 模块 (rtpengine-ctl 和 rtpengine-ng-client 依赖)
COPY --from=builder /usr/src/rtpengine/perl/NGCP /usr/share/perl5/NGCP

# 复制配置文件和入口脚本
COPY docker/rtpengine.conf /etc/rtpengine/rtpengine.conf
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 设置配置文件所有权
RUN chown -R rtpengine:rtpengine /etc/rtpengine

# 暴露端口
# 控制协议 (ng)
EXPOSE 22222/udp
# CLI 管理接口
EXPOSE 22223/tcp
# HTTP 接口
EXPOSE 22225/tcp
# RTP 端口范围通常为 30000-40000，但需要使用 host 网络模式

# 切换到非 root 用户
USER rtpengine

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["rtpengine"]
