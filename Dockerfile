FROM alpine:3.15.0 as download

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

WORKDIR /work/licenses
ARG LICENSE_URL_BASE=https://raw.githubusercontent.com/minio/mc/${MC_RELEASE}/
RUN \
    wget -qO CREDITS ${LICENSE_URL_BASE}/CREDITS \
    && wget -qO LICENSE ${LICENSE_URL_BASE}/LICENSE

# UPX is not available for aarch64
FROM --platform=linux/amd64 alpine:3.15.0 as compress
WORKDIR /work
COPY --from=download /work/mc .
RUN apk add --no-cache upx && upx mc

FROM alpine:3.15.0
COPY --from=compress /work/mc /usr/local/bin/
COPY --from=download /work/licenses /licenses

ENTRYPOINT ["mc"]
