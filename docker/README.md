# rtpengine Docker Image

This directory contains Docker packaging for rtpengine - a high-performance RTP proxy.

## Quick Start

### Build the image

```bash
# From project root
./docker/build.sh rtpengine:latest

# Or with custom tag
./docker/build.sh myregistry/rtpengine:v1.0
```

### Run the container

**Recommended: Host network mode** (required for full RTP functionality)

```bash
docker run -d \
  --name rtpengine \
  --network host \
  rtpengine:latest
```

**Alternative: Bridge network** (limited to control interface only)

```bash
docker run -d \
  --name rtpengine \
  -p 22222:22222/udp \
  -p 22223:22223/tcp \
  -p 22225:22225/tcp \
  rtpengine:latest
```

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 22222 | UDP | ng control protocol (bencode) |
| 22223 | TCP | CLI management interface |
| 22225 | TCP | HTTP/REST API and Prometheus metrics |
| 30000-40000 | UDP | RTP media port range |

**Note:** The RTP port range (30000-40000) requires host network mode for proper operation. Using bridge network mode will only allow control plane functionality.

## Configuration

### Using a custom config file

```bash
docker run -d \
  --name rtpengine \
  --network host \
  -v /path/to/rtpengine.conf:/etc/rtpengine/rtpengine.conf:ro \
  rtpengine:latest
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `RTPENGINE_TABLE` | iptables table (-1 for userspace) | -1 |
| `RTPENGINE_INTERFACE` | Network interface | any |
| `RTPENGINE_LISTEN_NG` | ng protocol listener | 0.0.0.0:22222 |
| `RTPENGINE_LISTEN_CLI` | CLI listener | 0.0.0.0:22223 |
| `RTPENGINE_LISTEN_HTTP` | HTTP listener | 0.0.0.0:22225 |
| `RTPENGINE_PORT_MIN` | RTP port range min | 30000 |
| `RTPENGINE_PORT_MAX` | RTP port range max | 40000 |
| `RTPENGINE_LOG_LEVEL` | Log level (1-7) | 6 |
| `RTPENGINE_REDIS` | Redis connection | - |
| `RTPENGINE_HOMER` | Homer SIPCAPTURE | - |
| `RTPENGINE_GRAPHITE` | Graphite metrics | - |
| `RTPENGINE_EXTRA_OPTS` | Additional CLI options | - |

Example with environment variables:

```bash
docker run -d \
  --name rtpengine \
  --network host \
  -e RTPENGINE_LOG_LEVEL=7 \
  -e RTPENGINE_PORT_MIN=20000 \
  -e RTPENGINE_PORT_MAX=30000 \
  rtpengine:latest
```

## Docker Compose

```yaml
version: '3.8'

services:
  rtpengine:
    image: rtpengine:latest
    build:
      context: ..
      dockerfile: docker/Dockerfile
    network_mode: host
    environment:
      - RTPENGINE_LOG_LEVEL=6
    volumes:
      - ./rtpengine.conf:/etc/rtpengine/rtpengine.conf:ro
      - rtpengine-recordings:/var/spool/rtpengine
    restart: unless-stopped

volumes:
  rtpengine-recordings:
```

## Recording Daemon

To run the recording daemon:

```bash
docker run -d \
  --name rtpengine-recording \
  --network host \
  -v /var/spool/rtpengine:/var/spool/rtpengine \
  rtpengine:latest rtpengine-recording
```

## Testing

Run the test suite to verify the image:

```bash
./docker/tests/test-image.sh rtpengine:latest
```

## Security

- The container runs as non-root user `rtpengine`
- No kernel module required (userspace forwarding mode)
- Minimal runtime dependencies

## Transcoding Support

This image includes full transcoding support:

- FFmpeg libraries (libavcodec, libavfilter, libavformat, libswresample)
- Opus codec (libopus)
- G.729 codec (bcg729)
- T.38 fax support (spandsp)

## Troubleshooting

### Check logs

```bash
docker logs rtpengine
```

### Interactive shell

```bash
docker exec -it rtpengine /bin/bash
```

### Test ng protocol

```bash
echo 'd3:cmd5:pingi1ee' | nc -u localhost 22222
```

### Check CLI

```bash
docker exec rtpengine rtpengine-ctl list sessions
```
