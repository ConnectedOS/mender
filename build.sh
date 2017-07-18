#!/bin/sh

MENDER_VERSION=1.0.1
TARGET=$1
BASE_DIR="$(dirname $(readlink -f $0))"
SRC=$BASE_DIR/src/mender-$MENDER_VERSION

case "$TARGET" in
    rpi_2)
        TOOLCHAIN=arm-linux-gnueabi-gcc
        GOARCH=arm
        ;;
    rpi_3)
        TOOLCHAIN=aarch64-linux-gnu-gcc
        GOARCH=arm64
        ;;
    *)
        echo "Target not found"
        exit 1
esac
                                 
mkdir -p src

if ! curl -sSL https://github.com/mendersoftware/mender/archive/1.0.1.tar.gz | tar xz -C $BASE_DIR/src; then
    echo "Failed to download mender source code"
    exit 1
fi

[ ! -d "$SRC" ] && echo "$SRC not found!" && exit 1

# Add build tag to arm64
sed -i $SRC/ioctl_64_bit.go -e 's,amd64,amd64 arm64,g'

docker build -t connectedos/mender-builder . || exit 1

docker run \
       -t -i \
       --rm \
       -v $SRC:/go/src/github.com/mendersoftware/mender \
       -w /go/src/github.com/mendersoftware/mender \
       -e CC=$TOOLCHAIN \
       -e GOARCH=$GOARCH \
       connectedos/mender-builder \
       /bin/sh -x -c \
       "/usr/local/go/bin/go build -a -i -ldflags '-X main.Version=$MENDER_VERSION'"

cp $SRC/mender mender-$TARGET
