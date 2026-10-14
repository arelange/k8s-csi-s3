FROM golang:1.25.9-alpine as gobuild

WORKDIR /build
ADD go.mod go.sum /build/
RUN go mod download -x
ADD cmd /build/cmd
ADD pkg /build/pkg
ENV TARGETARCH=arm64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} \
  go build -a -ldflags '-extldflags "-static"' -o ./s3driver ./cmd/s3driver

FROM alpine:latest
LABEL description="csi-s3 slim image"
ENV TARGETARCH=arm64

RUN apk add --no-cache fuse mailcap

ADD https://github.com/yandex-cloud/geesefs/releases/latest/download/geesefs-linux-${TARGETARCH} /usr/bin/geesefs
RUN chmod 755 /usr/bin/geesefs

COPY --from=gobuild /build/s3driver /s3driver
ENTRYPOINT ["/s3driver"]
