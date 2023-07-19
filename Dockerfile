FROM alpine

RUN apk --no-cache update && \
  apk add --no-cache less bash wget curl python3 py3-pip py-cryptography jq git file tar docker

RUN apk --no-cache add --virtual builds-deps build-base python3

# Install AWSCLI
RUN pip install --upgrade pip \
  setuptools_rust \
  awscli

# kubectl
ENV kubectl v1.23.4
RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl

# helm
ENV helm v3.8.1
RUN curl -sL https://get.helm.sh/helm-${helm}-linux-amd64.tar.gz | tar xz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm

VOLUME /root/.aws
VOLUME /root/.kube
VOLUME /root/.helm

ENTRYPOINT ["bash"]
