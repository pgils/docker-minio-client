FROM alpine:3.14 as dl

ARG MC_RELEASE

WORKDIR /work
RUN TARGETARCH=$(case $(arch) in \
        x86_64) echo "amd64" ;; \
        aarch64) echo "arm64" ;; \
        esac) \
    \
    && wget -qO mc \
        https://dl.minio.io/client/mc/release/linux-${TARGETARCH}/archive/mc.${MC_RELEASE} \
    && chmod 755 mc \
    \
    && apk add --no-cache upx \
    && upx mc

FROM alpine:3.14
COPY --from=dl /work/mc /usr/local/bin/

ENTRYPOINT ["mc"]
