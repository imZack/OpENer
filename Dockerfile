FROM ubuntu:18.04 AS builder
RUN apt-get update && apt-get install -y \
    cmake \
    gcc \
    make \
    binutils \
    libcap-dev
WORKDIR /app
ADD . .
RUN cd bin/posix && \
    ./setup_posix.sh && \
    make
RUN ldd /app/bin/posix/src/ports/POSIX/OpENer | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
# Ref: https://gist.github.com/bcardiff/85ae47e66ff0df35a78697508fcb49af#gistcomment-3039503

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/deps /
COPY --from=builder /app/bin/posix/src/ports/POSIX/OpENer .
