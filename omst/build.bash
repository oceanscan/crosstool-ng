#! /bin/bash

VERSION='2023.03.00'
BASE="$(readlink -f "$(dirname "$BASH_SOURCE")/..")"
GIT_REV=`git -C $BASE rev-parse --short HEAD`
FULL_VERSION="$VERSION-$GIT_REV"
DST="$BASE/dist"
TCHAINS='omst-p6 omst-amd64 omst-cortexa53 omst-cortexa8 omst-geode omst-goldmont omst-cortexa72 omst-cortexa72-x64'

export PATH="$BASE/local/bin:$PATH"

die()
{
    echo "ERROR: failed to $1"
    exit 1
}

container_create()
{
    docker build -t crosstool-ng "$BASE/omst"
}

menuconfig()
{
    ct-ng "$1" || die "configuration"
    ct-ng upgradeconfig || die "upgrading configuration"
    ct-ng menuconfig || die "menuconfig"
    ct-ng savedefconfig || die "savedefconfig"
    cp -v defconfig samples/"$1"/crosstool.config || die "saving defconfig"
}

# Install crosstool-ng tools.
xtool_bootstrap()
{
    if ! [ -d "$BASE/local" ]; then
        ./bootstrap || die "bootstrap crosstool-ng"
        ./configure --prefix="$BASE/local" || die "configure crosstool-ng"
        make install || die "install crosstool-ng"
    fi
}

build()
{
    mkdir -p "$BASE/src" "$BASE/dist" || die "create folders"

    # Build toolchains.
    for t in $TCHAINS; do
        ct-ng "$t" || die "configure $t"
        echo "CT_SHOW_CT_VERSION=n" >> .config || die "override config"
        echo "CT_TOOLCHAIN_PKGVERSION=$FULL_VERSION" >> .config || die "override config"
        echo 'CT_ALLOW_BUILD_AS_ROOT_SURE=y' >> .config || die "override config"
        echo "CT_LOCAL_TARBALLS_DIR=$BASE/src" >> .config || die "override config"
        echo "CT_PREFIX_DIR=$DST/"'${CT_TARGET}'"-${VERSION}" >> .config || die "override config"
        ct-ng build.8 || die "build toolchain $t"
    done

    # Package toolchains.
    cd $DST || die "change to dist folder"
    for d in *omst*; do
        if [ -d "$d" ]; then
            name="$(basename "$d")"
            tar -cvJf "$name".tar.xz "$d" || die "pack $d"
        fi
    done
}

# Change to crosstool-ng folder.
cd "$BASE" || die "changed to base folder"

case "$1" in
    build)
        xtool_bootstrap
        build
        ;;
    menuconfig)
	menuconfig "$2"
	;;
    update)
        docker run \
               --read-only \
               --tmpfs /run \
               --tmpfs /tmp \
               -v "$BASE:/xtool" \
               -i \
               -a stdin \
               -a stdout \
               -t "crosstool-ng" \
               /bin/bash /xtool/omst/build.bash menuconfig "$2"
	;;
    *)
        container_create || die "create container"

        docker run \
               --read-only \
               --tmpfs /run \
               --tmpfs /tmp \
               -v "$BASE:/xtool" \
               -i \
               -a stdin \
               -a stdout \
               -t "crosstool-ng" \
               /bin/bash /xtool/omst/build.bash build
        ;;
esac
