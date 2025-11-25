# Requirements Document

## Introduction

本文档定义了将 rtpengine 项目打包为 Docker 镜像的需求。rtpengine 是一个高性能的 RTP/媒体代理服务器，用于 VoIP 通信中的媒体流转发和转码。Docker 镜像将简化部署流程，提供一致的运行环境。

## Glossary

- **rtpengine**: RTP 媒体代理守护进程，处理 VoIP 媒体流的转发和转码
- **Docker Image**: 包含应用程序及其所有依赖的可移植容器镜像
- **Dockerfile**: 定义 Docker 镜像构建步骤的配置文件
- **Multi-stage Build**: Docker 多阶段构建，用于减小最终镜像体积
- **Transcoding**: 音视频编解码转换功能
- **Build System**: rtpengine 的 Makefile 构建系统

## Requirements

### Requirement 1

**User Story:** As a DevOps engineer, I want to build rtpengine as a Docker image, so that I can deploy it consistently across different environments.

#### Acceptance Criteria

1. WHEN a user executes the Docker build command THEN the Build System SHALL compile rtpengine daemon with all required dependencies
2. WHEN the build completes THEN the Docker Image SHALL contain a functional rtpengine binary at `/usr/bin/rtpengine`
3. WHEN building the image THEN the Build System SHALL use multi-stage build to minimize final image size
4. WHEN the build process encounters missing dependencies THEN the Build System SHALL fail with a clear error message

### Requirement 2

**User Story:** As a system administrator, I want the Docker image to include full transcoding support, so that I can perform all codec conversion operations.

#### Acceptance Criteria

1. WHEN the image is built THEN the rtpengine daemon SHALL include ffmpeg transcoding libraries (libavcodec, libavfilter, libavformat, libavutil, libswresample)
2. WHEN transcoding is enabled THEN the Docker Image SHALL include spandsp library for T.38 fax support
3. WHEN transcoding is enabled THEN the Docker Image SHALL include libopus for Opus codec support
4. WHEN transcoding is enabled THEN the Docker Image SHALL include bcg729 library for G.729 codec support
5. WHEN the image is built THEN the Docker Image SHALL include the recording-daemon for call recording with transcoding capabilities

### Requirement 3

**User Story:** As a container operator, I want to configure rtpengine via environment variables and config files, so that I can customize its behavior at runtime.

#### Acceptance Criteria

1. WHEN the container starts THEN the rtpengine daemon SHALL read configuration from `/etc/rtpengine/rtpengine.conf`
2. WHEN a user mounts a custom config file THEN the rtpengine daemon SHALL use the mounted configuration
3. WHEN environment variables are provided THEN the entrypoint script SHALL pass them as command-line arguments to rtpengine

### Requirement 4

**User Story:** As a network engineer, I want the container to expose necessary ports, so that I can route RTP traffic correctly.

#### Acceptance Criteria

1. WHEN the container runs THEN the Docker Image SHALL expose the control port (default 22222/udp for ng protocol)
2. WHEN the container runs THEN the Docker Image SHALL document the RTP port range requirement (default 30000-40000/udp)
3. WHEN running in host network mode THEN the rtpengine daemon SHALL bind to the host's network interfaces directly

### Requirement 5

**User Story:** As a developer, I want a simple build script, so that I can build the Docker image with a single command.

#### Acceptance Criteria

1. WHEN a user runs the build script THEN the Build System SHALL build the Docker image with a configurable tag
2. WHEN the build script is executed THEN the Build System SHALL display build progress and final image size
3. WHEN build arguments are provided THEN the Build System SHALL pass them to the Docker build process

### Requirement 6

**User Story:** As a production operator, I want the container to run as a non-root user, so that I can follow security best practices.

#### Acceptance Criteria

1. WHEN the container starts THEN the rtpengine daemon SHALL run as a dedicated `rtpengine` user
2. WHEN the container runs THEN the rtpengine process SHALL have minimal required capabilities (NET_ADMIN for network operations)
3. WHEN log files are written THEN the rtpengine user SHALL have write permissions to the log directory

