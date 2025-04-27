#!/bin/bash

SYSTEM=$(go env GOOS)
PROTOC=../poker_server/lib/contrib/protoc/protoc-30.1-linux-x86_64/bin/protoc
PROTOC_GO_INJECT_TAG=protoc-go-inject-tag
if [ "${SYSTEM}" = "darwin" ]; then
    PROTOC=../poker_server/lib/contrib/protoc/protoc-30.1-osx-aarch_64/bin/protoc
elif [ "${SYSTEM}" = "windows" ]; then
    PROTOC_GO_INJECT_TAG=protoc-go-inject-tag.exe
    PROTOC=../poker_server/lib/contrib/protoc/protoc-30.1-win64/bin/protoc.exe
fi

rm -rf ./protocol && ${PROTOC} --go_out=. *.proto && mv g1_protocol protocol && cp -rf index.gen.go ./protocol/index.gen.go


# 定义要检查和更新的包名
PACKAGE="github.com/favadi/protoc-go-inject-tag"

# 获取当前安装的版本
CURRENT_VERSION=$(go list -m $PACKAGE | cut -d' ' -f2)

# 获取最新版本信息
LATEST_INFO=$(go list -u -m -json $PACKAGE)
LATEST_VERSION=$(echo "$LATEST_INFO" | jq -r '.Update.Version')

# 检查是否有可用的更新
if [ "$LATEST_VERSION" != "null" ] && [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    echo "发现新版本 $LATEST_VERSION，开始更新..."
    go install $PACKAGE@$LATEST_VERSION
    if [ $? -eq 0 ]; then
        echo "更新成功，当前版本为 $LATEST_VERSION"
    else
        echo "更新失败，请检查网络或手动更新。"
    fi
else
    echo "protoc-go-inject-tag 已经是最新版本 ($CURRENT_VERSION)。"
fi

if [ -f "./protocol/database.pb.go" ]; then
${PROTOC_GO_INJECT_TAG} -input=./protocol/database.pb.go
# 使用 sed 批量添加忽略标签
sed -i -E 's/(^\s*(state|sizeCache|unknownFields)\s+protoimpl\.[A-Za-z]+)/\1 `xorm:"-"`/' ./protocol/database.pb.go
fi
