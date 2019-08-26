FROM alpine:3.9

ENV BRANCH_PIAWARE=v3.7.1 \
    BRANCH_TCLLAUNCHER=v1.8 \
    BRANCH_DUMP1090=v3.7.1 \
    BRANCH_MLATCLIENT=v0.2.10 \
    BRANCH_TCLLIB=tcllib-1-18-1 \
    VERSION_S6OVERLAY=v1.22.1.0 \
    ARCH_S6OVERLAY=amd64 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

ADD https://github.com/just-containers/s6-overlay/releases/download/${VERSION_S6OVERLAY}/s6-overlay-${ARCH_S6OVERLAY}.tar.gz /tmp/s6-overlay.tar.gz

RUN apk update && \
    apk add git \
            make \
            tcl \
            gcc \
            musl-dev \
            autoconf \
            tcl-dev \
            tclx \
            tcl-tls \
            cmake \
            libusb-dev \
            ncurses-dev \
            g++ \
            net-tools \
            python3 \
            python3-dev \
            lighttpd \
            tzdata && \
    mkdir -p /src && \
    mkdir -p /var/cache/lighttpd/compress && \
    chown lighttpd:lighttpd /var/cache/lighttpd/compress && \
    git clone git://git.osmocom.org/rtl-sdr.git /src/rtl-sdr && \
    mkdir -p /src/rtl-sdr/build && \
    cd /src/rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -Wno-dev && \
    make -j -Wstringop-truncation && \
    make -j -Wstringop-truncation install && \
    cp -v /src/rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/ && \
    echo "blacklist dvb_usb_rtl28xxu" >> /etc/modprobe.d/no-rtl.conf && \
    echo "blacklist rtl2832" >> /etc/modprobe.d/no-rtl.conf && \
    echo "blacklist rtl2830" >> /etc/modprobe.d/no-rtl.conf && \
    git clone --recursive https://github.com/Nuand/bladeRF.git /src/bladeRF && \
    cd /src/bladeRF && \
    git checkout 2017.12-rc1 && \
    mkdir /src/bladeRF/host/build && \
    cd /src/bladeRF/host/build && \
    cmake -DTREAT_WARNINGS_AS_ERRORS=OFF ../ && \
    make -j && \
    make -j install && \
    git clone -b ${BRANCH_TCLLAUNCHER} https://github.com/flightaware/tcllauncher.git /src/tcllauncher && \
    cd /src/tcllauncher && \
    autoconf && \
    ./configure --prefix=/opt/tcl && \
    make -j && \
    make -j install && \
    git clone -b ${BRANCH_TCLLIB} https://github.com/tcltk/tcllib.git /src/tcllib && \
    cd /src/tcllib && \
    autoconf && \
    ./configure && \
    make -j && \
    make -j install && \
    git clone -b ${BRANCH_PIAWARE} https://github.com/flightaware/piaware.git /src/piaware && \
    cp -v /src/piaware/programs/piaware/faup.tcl /src/piaware/programs/piaware/faup.tcl.original && \
    sed -i 's/package require Itcl 3.4/package require Itcl/' /src/piaware/programs/piaware/faup.tcl && \
    cd /src/piaware && \
    make -j && \
    make -j install && \
    cp -v /src/piaware/package/ca/*.pem /etc/ssl/ && \
    touch /etc/piaware.conf && \
    mkdir -p /run/piaware && \
    git clone -b ${BRANCH_DUMP1090} https://github.com/flightaware/dump1090.git /src/dump1090 && \
    cd /src/dump1090 && \
    make -j all && \
    make -j faup1090 && \
    cp -v view1090 dump1090 /usr/local/bin/ && \
    cp -v faup1090 /usr/lib/piaware/helpers/ && \
    mkdir -p /run/dump1090-fa && \
    mkdir -p /usr/share/dump1090-fa/html && \ 
    cp -a /src/dump1090/public_html/* /usr/share/dump1090-fa/html/ && \
    git clone -b ${BRANCH_MLATCLIENT} https://github.com/mutability/mlat-client.git /src/mlat-client && \
    cd /src/mlat-client && \
    ./setup.py install && \
    ln -s /usr/bin/fa-mlat-client /usr/lib/piaware/helpers/ && \
    apk del git \
            make \
            gcc \
            musl-dev \
            autoconf \
            tcl-dev \
            cmake \
            ncurses-dev \
            python3 && \
    rm -rf /var/cache/apk/* && \
    rm -rf /src && \
    tar -xzf /tmp/s6-overlay.tar.gz -C / && \
    rm -f /tmp/s6-overlay.tar.gz

COPY etc/ /etc/

EXPOSE 30104/tcp 8080/tcp 30001/tcp 30002/tcp 30003/tcp 30004/tcp 30005/tcp

ENTRYPOINT [ "/init" ]

