FROM debian:jessie

RUN apt-get update -y && apt-get install -y --no-install-recommends build-essential debhelper tcl8.6-dev autoconf python3-dev python3-venv dh-systemd libz-dev wget git-sh cmake pkg-config doxygen libusb-1.0-0-dev libtecla-dev libncurses5-dev help2man pandoc librtlsdr-dev lighttpd init-system-helpers net-tools  tclx8.4 tcllib tcl-tls itcl3 && rm -rf /var/lib/apt/lists/*

COPY lighttpd_config_50-piaware.conf /etc/lighttpd/conf-available/50-piaware.conf
COPY piaware_config /root/.piaware
COPY entrypoint.sh /root/entrypoint.sh

RUN mkdir -p /src/bladeRF/bladeRF && \
    git clone https://github.com/Nuand/bladeRF.git /src/bladeRF/bladeRF && \
    mkdir -p /src/dump1090-fa/dump1090 && \
    git clone https://github.com/flightaware/dump1090.git /src/dump1090-fa/dump1090 && \
    mkdir -p /src/piaware_builder && \
    git clone https://github.com/flightaware/piaware_builder.git /src/piaware_builder && \
    cd /src/bladeRF/bladeRF && \
    dpkg-buildpackage -b && \
    cd /src/bladeRF && \
    dpkg -i *blade*.deb && \
    cd /src/dump1090-fa/dump1090 && \
    dpkg-buildpackage -b && \
    cd /src/dump1090-fa && \
    dpkg -i dump1090*.deb && \
    cd /src/piaware_builder && \
    ./sensible-build.sh jessie && \
    cd /src/piaware_builder/package-jessie && \
    dpkg-buildpackage -b && \
    cd /src/piaware_builder && \
    dpkg -i piaware*.deb && \
    ln -s /etc/lighttpd/conf-available/50-piaware.conf /etc/lighttpd/conf-enabled/50-piaware.conf && \
    piaware-config allow-auto-updates yes && \
    piaware-config allow-manual-updates yes && \
    chmod a+x /root/entrypoint.sh && \
    mkdir -p /run/piaware && \
    mkdir -p /run/dump1090-fa && \
    cd / && \
    rm -rf /src

# Set entrypoint
CMD ["/root/entrypoint.sh"]
