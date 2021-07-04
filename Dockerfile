FROM debian:stable-slim
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    BRANCH_RTLSDR="d794155ba65796a76cd0a436f9709f4601509320" \
    VERBOSE_LOGGING="false" \
    BLADERF_RBF_PATH="/usr/share/Nuand/bladeRF" \
    URL_REPO_BEASTSPLITTER="https://github.com/flightaware/beast-splitter.git" \
    URL_REPO_BLADERF="https://github.com/Nuand/bladeRF.git" \
    URL_REPO_DUMP978="https://github.com/flightaware/dump978.git" \
    URL_REPO_DUMP1090="https://github.com/flightaware/dump1090.git" \
    URL_REPO_FFTW="https://github.com/FFTW/fftw3.git" \
    URL_REPO_HACKRF="https://github.com/mossmann/hackrf.git" \
    URL_REPO_LIMESUITE="https://github.com/myriadrf/LimeSuite.git" \
    URL_REPO_MLATCLIENT="https://github.com/mutability/mlat-client.git" \
    URL_REPO_PIAWARE="https://github.com/flightaware/piaware.git" \
    URL_REPO_PIAWARE_WEB="https://github.com/flightaware/piaware-web.git" \
    URL_REPO_RTLSDR="git://git.osmocom.org/rtl-sdr" \
    URL_REPO_SOAPYRTLSDR="https://github.com/pothosware/SoapyRTLSDR.git" \
    URL_REPO_SOAPYSDR="https://github.com/pothosware/SoapySDR.git" \
    URL_REPO_TCLLAUNCHER="https://github.com/flightaware/tcllauncher.git" \
    URL_REPO_UAT2ESNT="https://github.com/adsbxchange/uat2esnt.git"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

# Note, the specific commit of rtlsdr is to address issue #15
# See: https://github.com/mikenye/docker-piaware/issues/15
# This should be revisited in future when rtlsdr 0.6.1 or newer is released

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
    # libusb (for rtl-sdr, SoapySDR)
    TEMP_PACKAGES+=(libusb-1.0-0-dev) && \
    KEPT_PACKAGES+=(libusb-1.0-0) && \
    # rtl-sdr dependencies
    TEMP_PACKAGES+=(pkg-config) && \
    # dump978 dependencies
    TEMP_PACKAGES+=(libboost-dev) && \
    TEMP_PACKAGES+=(libboost-system1.67-dev) && \
    KEPT_PACKAGES+=(libboost-system1.67.0) && \
    TEMP_PACKAGES+=(libboost-program-options1.67-dev) && \
    KEPT_PACKAGES+=(libboost-program-options1.67.0) && \
    TEMP_PACKAGES+=(libboost-regex1.67-dev) && \
    KEPT_PACKAGES+=(libboost-regex1.67.0) && \
    TEMP_PACKAGES+=(libboost-filesystem1.67-dev) && \
    KEPT_PACKAGES+=(libboost-filesystem1.67.0) && \
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
    # Build & install rtl-sdr
    git clone "${URL_REPO_RTLSDR}" "/src/rtl-sdr" && \
    pushd "/src/rtl-sdr" && \
    #BRANCH_RTLSDR=$(git tag --sort="-creatordate" | head -1) && \
    #git checkout "tags/${BRANCH_RTLSDR}" && \
    git checkout "${BRANCH_RTLSDR}" && \
    echo "rtl-sdr ${BRANCH_RTLSDR}" >> /VERSIONS && \
    mkdir -p "/src/rtl-sdr/build" && \
    pushd "/src/rtl-sdr/build" && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -Wno-dev -DCMAKE_BUILD_TYPE=Release && \
    make -Wstringop-truncation && \
    make -Wstringop-truncation install && \
    cp -v "/src/rtl-sdr/rtl-sdr.rules" "/etc/udev/rules.d/" && \
    ldconfig && \
    popd && popd && \
    # Build & install HackRF
    git clone "${URL_REPO_HACKRF}" "/src/hackrf" && \
    pushd "/src/hackrf" && \
    BRANCH_HACKRF=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "${BRANCH_HACKRF}" && \
    mkdir -p /src/hackrf/host/build && \
    pushd /src/hackrf/host/build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    ldconfig && \
    popd && popd && \
    # Build & install LimeSuite
    git clone "${URL_REPO_LIMESUITE}" "/src/LimeSuite" && \
    pushd "/src/LimeSuite" && \
    git checkout stable && \
    mkdir "/src/LimeSuite/builddir" && \
    pushd "/src/LimeSuite/builddir" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    ldconfig && \
    popd && popd && \
    # Build & install SoapySDR
    git clone "${URL_REPO_SOAPYSDR}" "/src/SoapySDR" && \
    pushd "/src/SoapySDR" && \
    BRANCH_SOAPYSDR=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "${BRANCH_SOAPYSDR}" && \
    mkdir -p "/src/SoapySDR/build" && \
    pushd "/src/SoapySDR/build" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make test && \
    make install && \
    ldconfig && \
    echo "SoapySDR $(SoapySDRUtil --info | grep -i 'lib version:' | cut -d ':' -f 2 | tr -d ' ')" >> /VERSIONS && \
    popd && popd && \
    # Build & install SoapyRTLSDR
    git clone "${URL_REPO_SOAPYRTLSDR}" "/src/SoapyRTLSDR" && \
    pushd "/src/SoapyRTLSDR" && \
    BRANCH_SOAPYRTLSDR=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "${BRANCH_SOAPYRTLSDR}" && \
    echo "SoapyRTLSDR ${BRANCH_SOAPYRTLSDR}" >> /VERSIONS && \
    mkdir -p "/src/SoapyRTLSDR/build" && \
    pushd "/src/SoapyRTLSDR/build" && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    popd && popd && \
    # Build & install dump978
    git clone "${URL_REPO_DUMP978}" "/src/dump978" && \
    pushd "/src/dump978" && \
    BRANCH_DUMP978=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "${BRANCH_DUMP978}" && \
    make all faup978 && \
    mkdir -p "/usr/lib/piaware/helpers" && \
    cp -v dump978-fa skyaware978 "/usr/local/bin/" && \
    cp -v faup978 "/usr/lib/piaware/helpers/" && \
    mkdir -p "/usr/share/skyaware978/html" && \
    cp -a "/src/dump978/skyaware/"* "/usr/share/skyaware978/html/" && \
    mkdir -p "/run/skyaware978" && \
    popd && \
    # Build & install bladeRF
    git clone --recursive "${URL_REPO_BLADERF}" "/src/bladeRF" && \
    pushd "/src/bladeRF" && \
    BRANCH_BLADERF="$(git tag --sort='-creatordate' | grep -vE '\-rc[0-9]*$' | head -1)" && \
    git checkout "${BRANCH_BLADERF}" && \
    echo "bladeRF ${BRANCH_BLADERF}" >> /VERSIONS && \
    mkdir -p "/src/bladeRF/host/build" && \
    popd && \
    pushd "/src/bladeRF/host/build" && \
    cmake \
        -DTREAT_WARNINGS_AS_ERRORS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        ../ \
        && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    # Download bladeRF FPGA Images
    mkdir -p "$BLADERF_RBF_PATH" && \
    curl -o "$BLADERF_RBF_PATH/hostedxA4.rbf" https://www.nuand.com/fpga/hostedxA4-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedxA9.rbf" https://www.nuand.com/fpga/hostedxA9-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedx40.rbf" https://www.nuand.com/fpga/hostedx40-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/hostedx115.rbf" https://www.nuand.com/fpga/hostedx115-latest.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbxA4.rbf" https://www.nuand.com/fpga/adsbxA4.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbxA9.rbf" https://www.nuand.com/fpga/adsbxA9.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbx40.rbf" https://www.nuand.com/fpga/adsbx40.rbf && \
    curl -o "$BLADERF_RBF_PATH/adsbx115.rbf" https://www.nuand.com/fpga/adsbx115.rbf && \
    # Build & install tcllauncher
    git clone "${URL_REPO_TCLLAUNCHER}" "/src/tcllauncher" && \
    pushd "/src/tcllauncher" && \
    BRANCH_TCLLAUNCHER="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_TCLLAUNCHER}" && \
    echo "tcllauncher ${BRANCH_TCLLAUNCHER}" >> /VERSIONS && \
    autoconf && \
    ./configure --prefix=/opt/tcl && \
    make && \
    make install && \
    ldconfig && \
    popd && \
    # Build & install piaware
    git clone "${URL_REPO_PIAWARE}" "/src/piaware" && \
    pushd "/src/piaware" && \
    BRANCH_PIAWARE="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_PIAWARE}" && \
    echo "piaware ${BRANCH_PIAWARE}" >> /VERSIONS && \
    make install && \
    cp -v /src/piaware/package/ca/*.pem /etc/ssl/ && \
    touch /etc/piaware.conf && \
    mkdir -p /run/piaware && \
    ldconfig && \
    popd && \
    # Build & install piaware-web
    git clone "${URL_REPO_PIAWARE_WEB}" "/src/piaware-web" && \
    cp -Rv /src/piaware-web/web/. /var/www/html/ && \
    # Build & install dump1090
    git clone "${URL_REPO_DUMP1090}" "/src/dump1090" && \
    pushd "/src/dump1090" && \
    BRANCH_DUMP1090="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_DUMP1090}" && \
    echo "dump1090 ${BRANCH_DUMP1090}" >> /VERSIONS && \
    # Reduce aggressive compiler optimisations
    sed -i 's/ -O3 / -O2 /g' ./Makefile && \
    # Implement ARMv6 workaround
    bash -x /scripts/armv6_workaround.sh ./Makefile && \
    # Make dump1090
    make showconfig && \
    make all && \
    make faup1090 && \
    cp -v view1090 dump1090 /usr/local/bin/ && \
    cp -v faup1090 /usr/lib/piaware/helpers/ && \
    mkdir -p /run/dump1090-fa && \
    mkdir -p /usr/share/dump1090-fa/html && \
    cp -a /src/dump1090/public_html/* /usr/share/dump1090-fa/html/ && \
    mkdir -p /usr/share/skyaware/html && \
    cp -a /src/dump1090/public_html_merged/* /usr/share/skyaware/html && \
    ldconfig && \
    popd && \
    # Build & install mlat-client
    git clone "${URL_REPO_MLATCLIENT}" "/src/mlat-client" && \
    pushd /src/mlat-client && \
    BRANCH_MLATCLIENT="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_MLATCLIENT}" && \
    echo "mlat-client ${BRANCH_MLATCLIENT}" >> /VERSIONS && \
    ./setup.py install && \
    ln -s /usr/local/bin/fa-mlat-client /usr/lib/piaware/helpers/ && \
    ldconfig && \
    popd && \
    # Build & install beast-splitter
    git clone "${URL_REPO_BEASTSPLITTER}" "/src/beast-splitter" && \
    pushd "/src/beast-splitter" && \
    BRANCH_BEASTSPLITTER="$(git tag --sort='-creatordate' | head -1)" && \
    git checkout "${BRANCH_BEASTSPLITTER}" && \
    echo "beast-splitter ${BRANCH_BEASTSPLITTER}" >> /VERSIONS && \
    make && \
    cp -v ./beast-splitter /usr/local/bin/ && \
    popd && \
    # Deploy s6-overlay.
    curl -s -o /tmp/deploy-s6-overlay.sh https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh && \
    bash /tmp/deploy-s6-overlay.sh && \
    # Clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    # Store container version
    grep piaware /VERSIONS | cut -d " " -f 2 > /CONTAINER_VERSION && \
    uname -a

EXPOSE 80/tcp 30003/tcp 30005/tcp 30105/tcp 30978/tcp 30979/tcp

ENTRYPOINT [ "/init" ]

HEALTHCHECK --start-period=7200s --interval=600s CMD /scripts/healthcheck.sh
