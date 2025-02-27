#!/bin/sh

platform=$1
version=$2
# 判断platform，如果不是linux-x86,linux-arm, mac, win-x86, win-arm, local，则退出，并提示错误信息和可选参数
if [ "$platform" != "linux-x86" -a "$platform" != "linux-arm" -a "$platform" != "mac" -a "$platform" != "win-x86" -a "$platform" != "win-arm" -a "$platform" != "local" ]; then
    echo "platform must be linux-x86, linux-arm, mac, win-x86, win-arm, local, but got $platform"
    exit
fi
# 判断version，如果是null，则退出，并提示错误信息和可选参数
if [ -z "$version" ]; then
    echo "package version cannot be null, eg: sh scripts/build-release.sh linux-arm 0.1.1"
    exit
fi


cross_build(){
    arch=$1
    platform_package_name=$2
    version=$3
    #软件包的目录
    build="./build"
    #程序名字
    target="ragcli"
    #程序包名字
    package_name=${target}-${platform_package_name}-${version}
    echo "build release package: ${package_name}"
    echo "${arch} Architecture, start compiling"
    mkdir -p ${build}

    # 执行编译
	cargo build --release --target ${arch}

    # 创建软件包目录结构
	mkdir -p ${build}/${package_name}
	mkdir -p ${build}/${package_name}/bin
	mkdir -p ${build}/${package_name}/libs
	mkdir -p ${build}/${package_name}/config

    # 拷贝编译好的可执行文件到软件包目录
	cp -rf target/${arch}/release/ragcli ${build}/${package_name}/bin


    # 拷贝管理脚本和配置文件到软件包目录
	cp -rf bin/* ${build}/${package_name}/bin
	cp -rf config/* ${build}/${package_name}/config

    # 设置文件权限
	chmod -R 777 ${build}/${package_name}/bin/*

    # 打包
	cd ${build} && tar zcvf ${package_name}.tar.gz ${package_name} && rm -rf ${package_name}
    cd ..
	echo "build release package success. ${package_name}.tar.gz "

}

#编译发布linux-x86
build_linux_x86_release(){
    version=$1

    # 设置编译目标平台为64 位的 x86 架构的 Linux 系统, 使用glibc
    platform_name="x86_64-unknown-linux-gnu"
    # 在Rust中添加该目标平台
    rustup target add ${platform_name}
    # 设置程序包名
    package_name="linux-gnu-intel64"
    cross_build $platform_name $package_name $version
    # 设置编译目标平台为64 位的 x86 架构的 Linux 系统，使用musl libc
    platform_name="x86_64-unknown-linux-musl"
    rustup target add ${platform_name}
    package_name="linux-musl-intel64"
    cross_build $platform_name $package_name $version
}
#编译发布linux-arm
build_linux_arm_release(){
    version=$1

    platform_name="aarch64-unknown-linux-gnu"
    rustup target add ${platform_name}
    package_name="linux-gnu-arm64"
    cross_build $platform_name $package_name $version

    platform_name="aarch64-unknown-linux-musl"
    rustup target add ${platform_name}
    package_name="linux-musl-arm64"
    cross_build $platform_name $package_name $version
}
# 编译发布mac
build_mac_release(){
    version=$1

    # Intel 64
    #platform_name="x86_64-apple-darwin"
    #rustup target add ${platform_name}
    #package_name="apple-mac-intel64"
    #cross_build $platform_name $package_name $version

    # Arm 64
    platform_name="aarch64-apple-darwin"
    rustup target add ${platform_name}
    package_name="apple-mac-arm64"
    cross_build $platform_name $package_name $version
}
# 编译发布win
build_win_x86_release(){
    version=$1

    # Intel 64
    platform_name="x86_64-pc-windows-gnu"
    rustup target add ${platform_name}
    package_name="windows-gnu-intel64"
    cross_build $platform_name $package_name $version

    # Intel 32
    platform_name="i686-pc-windows-gnu"
    rustup target add ${platform_name}
    package_name="windows-gnu-intel32"
    cross_build $platform_name $package_name $version
}
# 编译发布win-arm
build_win_arm_release(){
    version=$1
    # Arm 64
    platform_name="aarch64-pc-windows-gnullvm"
    rustup target add ${platform_name}
    package_name="windows-gnu-arm32"
    cross_build $platform_name $package_name $version
}
# 编译发布本地
build_local(){
    version=$1
    build="./build"
    target="ragcli"

    package_name=${target}-$version


    echo "package name: ${package_name}"
    mkdir -p ${build}

    # build
	cargo build

    # create package dir
	mkdir -p ${build}/${package_name}
	mkdir -p ${build}/${package_name}/bin
	mkdir -p ${build}/${package_name}/libs
	mkdir -p ${build}/${package_name}/config

    # copy bin&config
	cp -rf target/debug/ragcli ${build}/${package_name}/bin


    # copy bin&config
	cp -rf bin/* ${build}/${package_name}/bin
	cp -rf config/* ${build}/${package_name}/config

    # chmod file
	chmod -R 777 ${build}/${package_name}/bin/*

    # bundle file
	cd ${build} && tar zcvf ${package_name}.tar.gz ${package_name} && rm -rf ${package_name}
    cd ..
	echo "build release package success. ${package_name}.tar.gz "
}
#编译发布linux-x86软件包
if [ "$platform" = "linux-x86" ]; then
   build_linux_x86_release $version
fi
#编译发布linux-arm软件包
if [ "$platform" = "linux-arm" ]; then
   build_linux_arm_release $version
fi
#编译发布mac软件包
if [ "$platform" = "mac" ]; then
   build_mac_release $version
fi
#编译发布win-x86软件包
if [ "$platform" = "win-x86" ]; then
    build_win_x86_release $version
fi
#编译发布win-arm软件包
if [ "$platform" = "win-arm" ]; then
    build_win_arm_release $version
fi
#编译发布本地软件包
if [ "$platform" = "local" ]; then
    echo "build local"
    rm -rf ../build/
    build_local $version
fi
