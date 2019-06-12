FROM golang:latest as builder

MAINTAINER admin@v2ray.com

RUN go get -u v2ray.com/core/...
RUN mkdir -p /usr/bin/v2ray/
RUN go build -o /usr/bin/v2ray/v2ray v2ray.com/core/main
RUN go build -o /usr/bin/v2ray/v2ctl v2ray.com/core/infra/control/main
RUN cp -r ${GOPATH}/src/v2ray.com/core/release/config/* /usr/bin/v2ray/

FROM alpine

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
# Change TimeZone
RUN apk add --update tzdata
ENV TZ=Asia/Shanghai
# Clean APK cache
RUN rm -rf /var/cache/apk/*

RUN mkdir /usr/bin/v2ray/
RUN mkdir /etc/v2ray/
RUN mkdir /var/log/v2ray/

COPY --from=builder /usr/bin/v2ray  /usr/bin/v2ray

ENV PATH /usr/bin/v2ray/:$PATH

EXPOSE 8000
COPY config.json /etc/v2ray/config.json

# ssh
ENV SSH_PORT=7777

# ss
ENV SS_PORT=8888
ENV SS_PASSWORD=wnxd
ENV SS_METHOD=aes-128-gcm

# vmess
ENV VMESS_PORT=9999
ENV VMESS_ID=dee47bb1-513f-473f-9617-cfc953d7af08
ENV VMESS_LEVEL=1
ENV VMESS_ALTERID=64

# kcp
ENV KCP_PORT_VMESS=9999
ENV KCP_MTU=1350
ENV KCP_TTI=50
ENV KCP_UPLINK=5
ENV KCP_DOWNLINK=20
ENV KCP_READBUFF=2
ENV KCP_WRITEBUFF=2

EXPOSE ${SSH_PORT}/tcp
EXPOSE ${SS_PORT}/tcp
EXPOSE ${SS_PORT}/udp
EXPOSE ${VMESS_PORT}/tcp
EXPOSE ${KCP_PORT_VMESS}/udp

CMD ["/usr/bin/v2ray/v2ray", "-config=/etc/v2ray/config.json"]
