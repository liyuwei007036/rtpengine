#!/bin/bash
# Docker 镜像正确性验证测试脚本
# 属性 1: 二进制文件存在性验证
# 属性 2: 录音守护进程存在性验证
# 属性 3: 非 root 用户执行验证

set -e

IMAGE_NAME="${1:-rtpengine:latest}"

echo "=== 测试 Docker 镜像: $IMAGE_NAME ==="

# 属性 1: 二进制文件存在性验证
# 验证: 需求 1.2
echo ""
echo "属性 1: 验证 rtpengine 二进制文件存在于 /usr/bin/rtpengine..."
if docker run --rm --entrypoint="" "$IMAGE_NAME" test -x /usr/bin/rtpengine; then
    echo "✓ 通过: rtpengine 二进制文件存在且可执行"
else
    echo "✗ 失败: rtpengine 二进制文件未找到或不可执行"
    exit 1
fi

# 验证 rtpengine 可以显示版本/帮助
echo "验证 rtpengine 可以执行..."
if docker run --rm --entrypoint="" "$IMAGE_NAME" /usr/bin/rtpengine --version 2>&1 | head -1; then
    echo "✓ 通过: rtpengine 执行成功"
else
    echo "✗ 失败: rtpengine 执行失败"
    exit 1
fi

# 属性 2: 录音守护进程存在性验证
# 验证: 需求 2.5
echo ""
echo "属性 2: 验证 rtpengine-recording 二进制文件存在..."
if docker run --rm --entrypoint="" "$IMAGE_NAME" test -x /usr/bin/rtpengine-recording; then
    echo "✓ 通过: rtpengine-recording 二进制文件存在且可执行"
else
    echo "✗ 失败: rtpengine-recording 二进制文件未找到或不可执行"
    exit 1
fi

# 属性 3: 非 root 用户执行验证
# 验证: 需求 6.1
echo ""
echo "属性 3: 验证容器以非 root 用户运行..."
CONTAINER_USER=$(docker run --rm --entrypoint="" "$IMAGE_NAME" whoami)
if [ "$CONTAINER_USER" = "rtpengine" ]; then
    echo "✓ 通过: 容器以 'rtpengine' 用户运行 (非 root)"
else
    echo "✗ 失败: 容器以 '$CONTAINER_USER' 运行，而非 'rtpengine'"
    exit 1
fi

# 额外验证: 检查用户 ID 不为 0
CONTAINER_UID=$(docker run --rm --entrypoint="" "$IMAGE_NAME" id -u)
if [ "$CONTAINER_UID" != "0" ]; then
    echo "✓ 通过: 用户 ID 为 $CONTAINER_UID (非 root)"
else
    echo "✗ 失败: 用户 ID 为 0 (root)"
    exit 1
fi

# 验证配置目录权限
echo ""
echo "验证目录权限..."
if docker run --rm --entrypoint="" "$IMAGE_NAME" test -r /etc/rtpengine/rtpengine.conf; then
    echo "✓ 通过: 配置文件可读"
else
    echo "✗ 失败: 配置文件不可读"
    exit 1
fi

if docker run --rm --entrypoint="" "$IMAGE_NAME" test -w /var/spool/rtpengine; then
    echo "✓ 通过: 录音目录可写"
else
    echo "✗ 失败: 录音目录不可写"
    exit 1
fi

echo ""
echo "=== 所有测试通过！ ==="
