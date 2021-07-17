#!/bin/sh

version=$1

docker build --rm -t registry.cn-hangzhou.aliyuncs.com/xhj-image-common/xhj-log-manager:${version} .
docker push registry.cn-hangzhou.aliyuncs.com/xhj-image-common/xhj-log-manager:${version}
docker tag registry.cn-hangzhou.aliyuncs.com/xhj-image-common/xhj-log-manager:${version} registry.cn-hangzhou.aliyuncs.com/xhj-image-common/xhj-log-manager:latest
docker push registry.cn-hangzhou.aliyuncs.com/xhj-image-common/xhj-log-manager:latest
