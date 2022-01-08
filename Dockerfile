FROM alpine:3.14 as download

ARG MC_RELEASE

WORKDIR /work
RUN TARGETARCH=$(case $(arch) in \
        x86_64) echo "amd64" ;; \
        aarch64) echo "arm64" ;; \
        esac) \
    \
    && wget -qO mc \
        https://dl.minio.io/client/mc/release/linux-${TARGETARCH}/archive/mc.${MC_RELEASE} \
    && chmod 755 mc

# UPX is not available for aarch64
FROM --platform=linux/amd64 alpine:3.14 as compress
WORKDIR /work
COPY --from=download /work/mc .
RUN apk add --no-cache upx && upx mc

FROM alpine:3.14
COPY --from=compress /work/mc /usr/local/bin/

ENTRYPOINT ["mc"]
