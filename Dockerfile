ARG ALPINE_VERSION=3.17
FROM python:3.10-alpine${ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION=2.11.11
RUN apk add --no-cache git unzip groff build-base libffi-dev cmake
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git

WORKDIR aws-cli
RUN ./configure --with-install-type=portable-exe --with-download-deps
RUN make
RUN make install

# reduce image size: remove autocomplete and examples
RUN rm -rf \
  /usr/local/lib/aws-cli/aws_completer \
  /usr/local/lib/aws-cli/awscli/data/ac.index \
  /usr/local/lib/aws-cli/awscli/examples
RUN find /usr/local/lib/aws-cli/awscli/data -name completions-1*.json -delete
RUN find /usr/local/lib/aws-cli/awscli/botocore/data -name examples-1.json -delete
RUN (cd /usr/local/lib/aws-cli; for a in *.so*; do test -f /lib/$a && rm $a; done)

# build the final image
FROM alpine:${ALPINE_VERSION}

RUN apk --no-cache update && \
  apk add --no-cache bash curl python3 py3-pip jq git file tar docker

COPY --from=builder /usr/local/lib/aws-cli/ /usr/local/lib/aws-cli/
RUN ln -s /usr/local/lib/aws-cli/aws /usr/local/bin/aws

# buildx
COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx

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
