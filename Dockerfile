FROM alpine

RUN apk --no-cache update && \
  apk add --no-cache bash curl python3 py3-pip jq git file tar docker

# buildx
COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# kubectl
ENV kubectl v1.27.0
RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.tcom/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl

# helm
ENV helm v3.11.3
RUN curl -sL https://get.helm.sh/helm-${helm}-linux-amd64.tar.gz | tar xz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm

VOLUME /root/.aws
VOLUME /root/.kube
VOLUME /root/.helm

ENTRYPOINT ["bash"]
