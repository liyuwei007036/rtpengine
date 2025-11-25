# Implementation Plan

- [x] 1. Create Docker directory structure and Dockerfile
  - [x] 1.1 Create docker directory and multi-stage Dockerfile
    - Create `docker/` directory
    - Write Dockerfile with builder stage (debian:bookworm) and runtime stage (debian:bookworm-slim)
    - Install all build dependencies in builder stage
    - Compile rtpengine and rtpengine-recording
    - Copy binaries to runtime stage with minimal runtime dependencies
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 1.2 Verify binary existence in built image
    - **Property 1: Binary Existence Verification**
    - **Validates: Requirements 1.2**

  - [x] 1.3 Verify recording daemon existence
    - **Property 2: Recording Daemon Existence**
    - **Validates: Requirements 2.5**

- [x] 2. Create default configuration file
  - [x] 2.1 Create rtpengine.conf for container environment
    - Create `docker/rtpengine.conf` with userspace forwarding (table = -1)
    - Configure default interface, ports, and logging for container use
    - _Requirements: 3.1, 3.2_

- [x] 3. Create entrypoint script
  - [x] 3.1 Implement docker-entrypoint.sh
    - Create `docker/docker-entrypoint.sh`
    - Handle environment variable to command-line argument conversion
    - Support RTPENGINE_TABLE, RTPENGINE_INTERFACE, RTPENGINE_LISTEN_NG, etc.
    - Ensure proper signal handling for graceful shutdown
    - _Requirements: 3.3_

- [x] 4. Create non-root user setup
  - [x] 4.1 Add rtpengine user creation to Dockerfile
    - Create rtpengine user and group in runtime stage
    - Set proper ownership for config and log directories
    - Configure USER directive in Dockerfile
    - _Requirements: 6.1, 6.3_

  - [x] 4.2 Verify non-root user execution
    - **Property 3: Non-root User Execution**
    - **Validates: Requirements 6.1**

- [x] 5. Create build script
  - [x] 5.1 Implement build.sh script
    - Create `docker/build.sh` with configurable image tag
    - Support passing build arguments
    - Display build progress and final image size
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 6. Add port exposure and documentation
  - [x] 6.1 Configure EXPOSE directives and add README
    - Add EXPOSE directives for control port (22222/udp)
    - Create `docker/README.md` documenting port requirements and usage
    - Document RTP port range (30000-40000) and host network mode recommendation
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 7. Final Checkpoint
  - All property tests implemented in `docker/tests/test-image.sh`
  - Tests verify binary existence, recording daemon, and non-root execution
