FROM debian:jessie

RUN apt-get update -y

# Install build pre-requisites
RUN apt-get install -y build-essential debhelper tcl8.6-dev autoconf python3-dev python3-venv dh-systemd libz-dev wget git-sh

# Build & install bladeRF
WORKDIR /src
RUN apt-get install -y cmake pkg-config doxygen libusb-1.0-0-dev libtecla-dev libncurses5-dev help2man pandoc
WORKDIR /src/bladeRF
RUN git clone https://github.com/Nuand/bladeRF.git
WORKDIR /src/bladeRF/bladeRF
RUN dpkg-buildpackage -b
WORKDIR /src/bladeRF
RUN dpkg -i *blade*.deb

# Install librtlsdr-dev for RTLSDR radios
WORKDIR /src
RUN apt-get install -y librtlsdr-dev

# Build & install dump1090-fa
WORKDIR /src
RUN apt-get install -y lighttpd 
WORKDIR /src/dump1090-fa
RUN git clone https://github.com/flightaware/dump1090.git
WORKDIR /src/dump1090-fa/dump1090
RUN dpkg-buildpackage -b
WORKDIR /src/dump1090-fa
RUN dpkg -i dump1090*.deb

# Build & install piaware
WORKDIR /src
RUN apt-get install -y init-system-helpers net-tools  tclx8.4 tcllib tcl-tls itcl3
RUN git clone https://github.com/flightaware/piaware_builder.git
WORKDIR /src/piaware_builder
RUN ./sensible-build.sh jessie
WORKDIR /src/piaware_builder/package-jessie
RUN dpkg-buildpackage -b
WORKDIR /src/piaware_builder
RUN dpkg -i piaware*.deb

# Add files
COPY lighttpd_config_50-piaware.conf /etc/lighttpd/conf-available/50-piaware.conf
RUN ln -s /etc/lighttpd/conf-available/50-piaware.conf /etc/lighttpd/conf-enabled/50-piaware.conf
COPY piaware_config /root/.piaware
COPY entrypoint.sh /root/entrypoint.sh
RUN piaware-config allow-auto-updates yes
RUN piaware-config allow-manual-updates yes
RUN chmod a+x /root/entrypoint.sh
RUN mkdir -p /run/piaware
RUN mkdir -p /run/dump1090-fa

# Clean up
WORKDIR /
RUN rm -rf /src
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Set entrypoint
CMD ["/root/entrypoint.sh"]
