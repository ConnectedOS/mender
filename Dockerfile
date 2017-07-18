FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get install -y curl gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu

ENV GOLANG_VERSION 1.7.4
RUN curl -sSL https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz | tar xz -C /usr/local

ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV GOOS linux
ENV CGO_ENABLED 1
