#! /bin/bash

VERSION='2018.05.00'
BASE="$(readlink -f "$(dirname "$BASH_SOURCE")/..")"
DST="$BASE/dist"
TCHAINS='omst-cortex-a8 omst-cortex-a53 omst-geode omst-goldmont'

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
        echo 'CT_ALLOW_BUILD_AS_ROOT_SURE=y' >> .config || die "override config"
        echo "CT_LOCAL_TARBALLS_DIR=$DST" >> .config || die "override config"
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
