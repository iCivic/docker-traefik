FROM alpine:3.8
MAINTAINER Raul Sanchez <rawmind@gmail.com>

# Set environment
ENV SERVICE_NAME=traefik \
    SERVICE_HOME=/opt/traefik \
    SERVICE_VERSION=1.7.15 \
    SERVICE_USER=traefik \
    SERVICE_UID=10001 \
    SERVICE_GROUP=traefik \
    SERVICE_GID=10001 \
    SERVICE_URL=https://github.com/containous/traefik/releases/download
ENV SERVICE_RELEASE=${SERVICE_URL}/v${SERVICE_VERSION}/traefik_linux-amd64 \
    PATH=${PATH}:${SERVICE_HOME}/bin

COPY ./traefik_linux-amd64 /traefik_linux-amd64
COPY ./conf/repositories /etc/apk/repositories

RUN apk add -U tzdata && \
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone && \
	apk del tzdata && \
	# Download and install traefik
	mkdir -p ${SERVICE_HOME}/bin ${SERVICE_HOME}/etc ${SERVICE_HOME}/log ${SERVICE_HOME}/certs ${SERVICE_HOME}/acme && \
	apk add --no-cache libcap curl && \
    cd ${SERVICE_HOME}/bin && \
    #curl -jksSL "${SERVICE_RELEASE}" -O
    mv /traefik_linux-amd64 traefik && \
    touch ${SERVICE_HOME}/etc/rules.toml && \
    chmod +x ${SERVICE_HOME}/bin/traefik && \
    addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
    adduser -g "${SERVICE_NAME} user" -D -h ${SERVICE_HOME} -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER}
	
ADD root /
RUN chmod +x ${SERVICE_HOME}/bin/*.sh && \
	chmod 666 /var/run/docker.sock && \
	chown -R ${SERVICE_USER} ${SERVICE_HOME} && \
    setcap 'cap_net_bind_service=+ep' ${SERVICE_HOME}/bin/traefik

EXPOSE 80 443 8080
VOLUME ${SERVICE_HOME}/log
VOLUME  ${SERVICE_HOME}/certs

USER $SERVICE_USER
WORKDIR $SERVICE_HOME
ENTRYPOINT ["./bin/traefik"]

## ****************************** 参考资料 *****************************************
## 制作Docker Image: docker build -t idu/traefik:1.7.15 .
## 
## NGINX、HAProxy和Traefik负载均衡能力对比
## https://zhuanlan.zhihu.com/p/41354937

