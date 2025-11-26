#!/bin/bash
# rtpengine Docker 镜像构建脚本
# 用法: ./build.sh [镜像标签] [构建参数...]

set -e

# 默认值
DEFAULT_IMAGE_NAME="rtpengine"
DEFAULT_TAG="latest"

# 解析参数
IMAGE_TAG="${1:-$DEFAULT_IMAGE_NAME:$DEFAULT_TAG}"
shift 2>/dev/null || true

# 获取脚本目录 (Dockerfile 所在位置)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
docker stop rtpengine && docker rm rtpengine && docker rmi rtpengine:latest

echo "=============================================="
echo "构建 rtpengine Docker 镜像"
echo "=============================================="
echo "镜像标签: $IMAGE_TAG"
echo "构建上下文: $PROJECT_ROOT"
echo "Dockerfile: $SCRIPT_DIR/Dockerfile"
echo ""

# 构建镜像
echo "开始构建..."
START_TIME=$(date +%s)

docker build \
    --no-cache \
    -t "$IMAGE_TAG" \
    -f "$SCRIPT_DIR/Dockerfile" \
    "$@" \
    "$PROJECT_ROOT"

END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))

echo ""
echo "=============================================="
echo "构建成功完成！"
echo "=============================================="
echo "构建耗时: ${BUILD_TIME}秒"
echo ""

# 显示镜像信息
echo "镜像详情:"
docker images "$IMAGE_TAG" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo "运行容器:"
echo "  docker run -d --name rtpengine --network host $IMAGE_TAG"
echo ""
echo "或使用端口映射 (功能受限):"
echo "  docker run -d --name rtpengine -p 22222:22222/udp -p 22223:22223/tcp $IMAGE_TAG"
echo ""
echo "运行测试:"
echo "  ./docker/tests/test-image.sh $IMAGE_TAG"
