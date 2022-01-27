FROM ghcr.io/fredclausen/docker-baseimage:rtlsdr

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    VERBOSE_LOGGING="false"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Essentials
    TEMP_PACKAGES+=(automake) && \
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(ca-certificates) && \
    TEMP_PACKAGES+=(cmake) && \
    TEMP_PACKAGES+=(curl) && \
    TEMP_PACKAGES+=(git) && \
    # s6-overlay dependencies
    TEMP_PACKAGES+=(gnupg2) && \
    TEMP_PACKAGES+=(file) && \
    # logging
    KEPT_PACKAGES+=(gawk) && \
    # libusb for a number of things
    KEPT_PACKAGES+=(libusb-1.0-0) && \
    # dump978 dependencies
    TEMP_PACKAGES+=(libboost-dev) && \
    TEMP_PACKAGES+=(libboost-system1.74-dev) && \
    KEPT_PACKAGES+=(libboost-system1.74.0) && \
    TEMP_PACKAGES+=(libboost-program-options1.74-dev) && \
    KEPT_PACKAGES+=(libboost-program-options1.74.0) && \
    TEMP_PACKAGES+=(libboost-regex1.74-dev) && \
    KEPT_PACKAGES+=(libboost-regex1.74.0) && \
    TEMP_PACKAGES+=(libboost-filesystem1.74-dev) && \
    KEPT_PACKAGES+=(libboost-filesystem1.74.0) && \
    # dump1090 dependencies
    KEPT_PACKAGES+=(libatomic1) && \
    KEPT_PACKAGES+=(libncurses6) && \
    TEMP_PACKAGES+=(libncurses-dev) && \
    # tcllauncher dependencies
    KEPT_PACKAGES+=(tcl) && \
    TEMP_PACKAGES+=(tcl-dev) && \
    KEPT_PACKAGES+=(tcl-tls) && \
    KEPT_PACKAGES+=(tclx) && \
    # piaware-web dependencies
    KEPT_PACKAGES+=(lighttpd) && \
    KEPT_PACKAGES+=(lighttpd-mod-deflate) && \
    # hackrf dependencies
    KEPT_PACKAGES+=(libfftw3-3) && \
    TEMP_PACKAGES+=(libfftw3-dev) && \
    # mlat-client dependencies
    KEPT_PACKAGES+=(python3-minimal) && \
    KEPT_PACKAGES+=(python3-distutils) && \
    TEMP_PACKAGES+=(python3-dev) && \
    # piaware dependencies
    KEPT_PACKAGES+=(itcl3) && \
    KEPT_PACKAGES+=(tcllib) && \
    KEPT_PACKAGES+=(net-tools) && \
    KEPT_PACKAGES+=(procps) && \
    KEPT_PACKAGES+=(socat) && \
    # Install packages.
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} \
        && \
    git config --global advice.detachedHead false && \
    # Build & install HackRF
    BRANCH_HACKRF=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/mossmann/hackrf.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_HACKRF" "https://github.com/mossmann/hackrf.git" "/src/hackrf" && \
    mkdir -p /src/hackrf/host/build && \
    pushd /src/hackrf/host/build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make -j "$(nproc)"&& \
    make install && \
    ldconfig && \
    popd && \
    # Build & install LimeSuite
    git clone --depth 1 --branch stable "https://github.com/myriadrf/LimeSuite.git" "/src/LimeSuite" && \
    mkdir "/src/LimeSuite/builddir" && \
    pushd "/src/LimeSuite/builddir" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make -j "$(nproc)"&& \
    make install && \
    ldconfig && \
    popd && \
    # Build & install SoapySDR
    BRANCH_SOAPYSDR=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/pothosware/SoapySDR.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^soapy-sdr-.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_SOAPYSDR" "https://github.com/pothosware/SoapySDR.git" "/src/SoapySDR" && \
    mkdir -p "/src/SoapySDR/build" && \
    pushd "/src/SoapySDR/build" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make -j "$(nproc)"&& \
    make test && \
    make install && \
    ldconfig && \
    echo "SoapySDR $(SoapySDRUtil --info | grep -i 'lib version:' | cut -d ':' -f 2 | tr -d ' ')" >> /VERSIONS && \
    popd && \
    # Build & install SoapyRTLSDR
    BRANCH_SOAPYRTLSDR=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/pothosware/SoapyRTLSDR.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^soapy-rtl.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_SOAPYRTLSDR" "https://github.com/pothosware/SoapyRTLSDR.git" "/src/SoapyRTLSDR" && \
    echo "SoapyRTLSDR ${BRANCH_SOAPYRTLSDR}" >> /VERSIONS && \
    mkdir -p "/src/SoapyRTLSDR/build" && \
    pushd "/src/SoapyRTLSDR/build" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make -j "$(nproc)"&& \
    make install && \
    popd && \
    # Build & install dump978
    BRANCH_DUMP978=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/dump978.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_DUMP978" "https://github.com/flightaware/dump978.git" "/src/dump978" && \
    pushd "/src/dump978" && \
    make -j "$(nproc)" all faup978 && \
    mkdir -p "/usr/lib/piaware/helpers" && \
    cp -v dump978-fa skyaware978 "/usr/local/bin/" && \
    cp -v faup978 "/usr/lib/piaware/helpers/" && \
    mkdir -p "/usr/share/skyaware978/html" && \
    cp -a "/src/dump978/skyaware/"* "/usr/share/skyaware978/html/" && \
    mkdir -p "/run/skyaware978" && \
    popd && \
    # bladeRF: get latest release tag without cloning repo
    BRANCH_BLADERF=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/Nuand/bladeRF.git' | grep -v '\^' | grep 'refs/tags/libbladeRF_' | cut -d '/' -f 3 | tail -1) && \
    # bladeRF: clone repo
    git clone \
      --branch "$BRANCH_BLADERF" \
      --depth 1 \
      --single-branch \
      'https://github.com/Nuand/bladeRF.git' \
      /src/bladeRF \
      && \
    # bladeRF: prepare to build
    mkdir /src/bladeRF/build && \
    pushd /src/bladeRF/build && \
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DINSTALL_UDEV_RULES=ON \
      ../ \
      && \
    # bladeRF: build & install
    make -j "$(nproc)" && \
    make install && \
    ldconfig && \
    popd && \
    # bladeRF: simple test
    bladeRF-cli --version && \
    # Build & install tcllauncher
    BRANCH_TCLLAUNCHER=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/tcllauncher.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_TCLLAUNCHER" "https://github.com/flightaware/tcllauncher.git" "/src/tcllauncher" && \
    pushd "/src/tcllauncher" && \
    echo "tcllauncher ${BRANCH_TCLLAUNCHER}" >> /VERSIONS && \
    autoconf && \
    ./configure --prefix=/opt/tcl && \
    make -j "$(nproc)" && \
    make install && \
    ldconfig && \
    popd && \
    # Build & install piaware
    BRANCH_PIAWARE=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/piaware.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_PIAWARE" "https://github.com/flightaware/piaware.git" "/src/piaware" && \
    pushd "/src/piaware" && \
    echo "piaware ${BRANCH_PIAWARE}" >> /VERSIONS && \
    make -j "$(nproc)" install && \
    cp -v /src/piaware/package/ca/*.pem /etc/ssl/ && \
    touch /etc/piaware.conf && \
    mkdir -p /run/piaware && \
    ldconfig && \
    popd && \
    # Build & install piaware-web
    git clone "https://github.com/flightaware/piaware-web.git" "/src/piaware-web" && \
    cp -Rv /src/piaware-web/web/. /var/www/html/ && \
    # get dump1090 sources
    BRANCH_DUMP1090=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/dump1090.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_DUMP1090" "https://github.com/flightaware/dump1090.git" "/src/dump1090" && \
    pushd "/src/dump1090" && \
    echo "dump1090 ${BRANCH_DUMP1090}" >> /VERSIONS && \
    make -j "$(nproc)" showconfig BLADERF=yes RTLSDR=yes HACKRF=yes LIMESDR=yes && \
    make -j "$(nproc)" all BLADERF=yes RTLSDR=yes HACKRF=yes LIMESDR=yes -j && \
    make -j "$(nproc)" faup1090 BLADERF=yes RTLSDR=yes HACKRF=yes LIMESDR=yes -j && \
    cp -v view1090 dump1090 /usr/local/bin/ && \
    cp -v faup1090 /usr/lib/piaware/helpers/ && \
    mkdir -p /usr/share/dump1090-fa/html && \
    cp -a /opt/dump1090/public_html/* /usr/share/dump1090-fa/html/ && \
    mkdir -p /usr/share/skyaware/html && \
    cp -a /opt/dump1090/public_html_merged/* /usr/share/skyaware/html && \
    ldconfig && \
    popd && \
    dump1090 --version && \
    # Build & install mlat-client
    BRANCH_MLATCLIENT=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/mutability/mlat-client.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_MLATCLIENT" "https://github.com/mutability/mlat-client.git" "/src/mlat-client" && \
    pushd /src/mlat-client && \
    BRANCH_MLATCLIENT="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_MLATCLIENT}" && \
    echo "mlat-client ${BRANCH_MLATCLIENT}" >> /VERSIONS && \
    ./setup.py install && \
    ln -s /usr/local/bin/fa-mlat-client /usr/lib/piaware/helpers/ && \
    ldconfig && \
    popd && \
    # Build & install beast-splitter
    BRANCH_BEASTSPLITTER=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/beast-splitter.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
    git clone --depth 1 --branch "$BRANCH_BEASTSPLITTER" "https://github.com/flightaware/beast-splitter.git" "/src/beast-splitter" && \
    pushd "/src/beast-splitter" && \
    echo "beast-splitter ${BRANCH_BEASTSPLITTER}" >> /VERSIONS && \
    make -j "$(nproc)" && \
    cp -v ./beast-splitter /usr/local/bin/ && \
    popd && \
    cp /scripts/fa_services.tcl /usr/lib/piaware_packages/ && \
    # bladeRF: download bladeRF FPGA images
    BLADERF_RBF_PATH="/usr/share/Nuand/bladeRF" && \
    export BLADERF_RBF_PATH && \
    mkdir -p "$BLADERF_RBF_PATH" && \
    curl -L -o "$BLADERF_RBF_PATH/hostedxA4.rbf" https://www.nuand.com/fpga/hostedxA4-latest.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/hostedxA9.rbf" https://www.nuand.com/fpga/hostedxA9-latest.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/hostedx40.rbf" https://www.nuand.com/fpga/hostedx40-latest.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/hostedx115.rbf" https://www.nuand.com/fpga/hostedx115-latest.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/adsbxA4.rbf" https://www.nuand.com/fpga/adsbxA4.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/adsbxA9.rbf" https://www.nuand.com/fpga/adsbxA9.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/adsbx40.rbf" https://www.nuand.com/fpga/adsbx40.rbf && \
    curl -L -o "$BLADERF_RBF_PATH/adsbx115.rbf" https://www.nuand.com/fpga/adsbx115.rbf && \
    # Clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    # Store container version
    grep piaware /VERSIONS | cut -d " " -f 2 > /CONTAINER_VERSION

EXPOSE 80/tcp 30003/tcp 30005/tcp 30105/tcp 30978/tcp 30979/tcp

ENTRYPOINT [ "/init" ]

HEALTHCHECK --start-period=7200s --interval=600s CMD /scripts/healthcheck.sh
