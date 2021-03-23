# build stage
ARG REGISTRY_PREFIX
ARG GOLANG_VERSION=latest
ARG CENTOS_VERSION=7
FROM ${REGISTRY_PREFIX}golang:${GOLANG_VERSION} as builder

ADD src/* /repo-scanner/

WORKDIR /repo-scanner

RUN go build -o repoScanner

# application image
FROM ${REGISTRY_PREFIX}centos:${CENTOS_VERSION}
LABEL maintainer="Laurent Stacul<laurent.stacul@gmail.com>"

RUN yum -y install epel-release && \
    yum -y update && \
    yum -y install supervisor createrepo yum-utils nginx && \
    yum clean all && \
    mkdir -p /repo /logs

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY --from=builder /repo-scanner/repoScanner /root/

RUN chmod 700 /root/repoScanner

EXPOSE 80
VOLUME /repo /logs

ENV DEBUG false
ENV LINUX_HOST true
ENV SERVE_FILES true

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 700 /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]




