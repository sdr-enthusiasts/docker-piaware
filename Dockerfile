FROM ghcr.io/sdr-enthusiasts/docker-baseimage:trixie-dump978-full

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  VERBOSE_LOGGING="false"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086,SC2039,SC2068
RUN set -x && \
  TEMP_PACKAGES=() && \
  KEPT_PACKAGES=() && \
  # Essentials
  TEMP_PACKAGES+=(automake) && \
  TEMP_PACKAGES+=(build-essential) && \
  TEMP_PACKAGES+=(cmake) && \
  TEMP_PACKAGES+=(git) && \
  TEMP_PACKAGES+=(pkg-config) && \
  # s6-overlay dependencies
  TEMP_PACKAGES+=(gnupg2) && \
  TEMP_PACKAGES+=(file) && \
  # libusb for a number of things
  KEPT_PACKAGES+=(libusb-1.0-0) && \
  TEMP_PACKAGES+=(libusb-1.0-0-dev) && \
  # dump1090 dependencies
  KEPT_PACKAGES+=(libatomic1) && \
  KEPT_PACKAGES+=(libncurses6) && \
  TEMP_PACKAGES+=(libncurses-dev) && \
  # piaware-web dependencies
  KEPT_PACKAGES+=(lighttpd) && \
  KEPT_PACKAGES+=(lighttpd-mod-deflate) && \
  # mlat-client dependencies
  KEPT_PACKAGES+=(python3-minimal) && \
  KEPT_PACKAGES+=(python3-pkg-resources) && \
  TEMP_PACKAGES+=(python3-dev) && \
  TEMP_PACKAGES+=(python3-setuptools) && \
  # piaware dependencies
  KEPT_PACKAGES+=(itcl3) && \
  KEPT_PACKAGES+=(tcllib) && \
  KEPT_PACKAGES+=(net-tools) && \
  KEPT_PACKAGES+=(procps) && \
  KEPT_PACKAGES+=(socat) && \
  # tcl
  KEPT_PACKAGES+=(tcl) && \
  TEMP_PACKAGES+=(tcl-dev) && \
  KEPT_PACKAGES+=(tclx) && \
  # beast-splitter dependencies
  # if we are on trixie, we want libglib2.0-0t64, otherwise we want libglib2.0-0
  . /etc/os-release && \
  # distro="$ID" && \
  # version="$VERSION_ID" && \
  codename="$VERSION_CODENAME" && \
  if [[ "$codename" == "trixie" ]]; then \
  # needed for the stupid tcl build system
  TEMP_PACKAGES+=(devscripts) && \
  TEMP_PACKAGES+=(debhelper) && \
  TEMP_PACKAGES+=(tcl8.6-dev) && \
  TEMP_PACKAGES+=(autoconf) && \
  TEMP_PACKAGES+=(libssl-dev) && \
  TEMP_PACKAGES+=(tcl-dev) && \
  KEPT_PACKAGES+=(chrpath) && \
  # trixie specific boost 1.83 packages for tcllauncher
  TEMP_PACKAGES+=(libboost1.83-dev) && \
  TEMP_PACKAGES+=(libboost-system1.83-dev) && \
  KEPT_PACKAGES+=(libboost-system1.83.0) && \
  TEMP_PACKAGES+=(libboost-program-options1.83-dev) && \
  KEPT_PACKAGES+=(libboost-program-options1.83.0) && \
  TEMP_PACKAGES+=(libboost-regex1.83-dev) && \
  KEPT_PACKAGES+=(libboost-regex1.83.0); \
  else \
  # tcllauncher dependencies
  KEPT_PACKAGES+=(tcl-tls) && \
  TEMP_PACKAGES+=(libboost1.74-dev) && \
  TEMP_PACKAGES+=(libboost-system1.74-dev) && \
  KEPT_PACKAGES+=(libboost-system1.74.0) && \
  TEMP_PACKAGES+=(libboost-program-options1.74-dev) && \
  KEPT_PACKAGES+=(libboost-program-options1.74.0) && \
  TEMP_PACKAGES+=(libboost-regex1.74-dev) && \
  KEPT_PACKAGES+=(libboost-regex1.74.0) && \
  TEMP_PACKAGES+=(python3-distutils) ; \
  fi && \
  # Install packages.
  apt-get update && \
  apt-get install -y --no-install-recommends \
  ${KEPT_PACKAGES[@]} \
  ${TEMP_PACKAGES[@]} \
  && \
  git config --global advice.detachedHead false && \
  if [[ "$codename" == "trixie" ]]; then \
  # needed for the stupid tcl build system
  git clone --depth 1 https://github.com/flightaware/tcltls-rebuild.git /src/tcltls-rebuild && \
  pushd /src/tcltls-rebuild && \
  ./prepare-build.sh bullseye && \
  pushd package-bullseye && \
  dpkg-buildpackage -b --no-sign && \
  popd && \
  dpkg -i tcl-tls_*.deb && \
  popd; \
  fi && \
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
  # set debian package version message to get 3 green boxes
  sed /usr/lib/piaware/login.tcl -i -e 's/\tforeach {packageName packageVersion}/\tset message(piaware_package_version) $::piawareVersion\n\tset message(image_type) piaware_package\n\0/' && \
  ldconfig && \
  popd && \
  # Build & install piaware-web
  git clone "https://github.com/flightaware/piaware-web.git" "/src/piaware-web" && \
  cp -Rv /src/piaware-web/web/. /var/www/html/ && \
  # Symlink for skyaware978
  ln -vs /usr/share/dump978-fa /usr/share/skyaware978 && \
  # get dump1090 sources
  DUMP1090_VERSION=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/flightaware/dump1090.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
  export DUMP1090_VERSION && \
  git clone --depth 1 --branch "$DUMP1090_VERSION" "https://github.com/flightaware/dump1090.git" "/src/dump1090" && \
  pushd "/src/dump1090" && \
  # this fixes the architecture detection for armhf on the github native runners
  sed -i -e 's/uname -m/dpkg --print-architecture/' Makefile && \
  echo "dump1090 ${DUMP1090_VERSION}" >> /VERSIONS && \
  make -j "$(nproc)" showconfig RTLSDR=yes && \
  make -j "$(nproc)" all RTLSDR=yes -j && \
  make -j "$(nproc)" faup1090 RTLSDR=yes -j && \
  cp -v view1090 dump1090 /usr/local/bin/ && \
  cp -v faup1090 /usr/lib/piaware/helpers/ && \
  mkdir -p /usr/share/skyaware/html && \
  cp -a /src/dump1090/public_html/* /usr/share/skyaware/html && \
  # deduplicate using symlinks
  bash /scripts/deduplicate.sh /usr/share/dump978-fa/html /usr/share/skyaware/html && \
  ldconfig && \
  popd && \
  dump1090 --version && \
  # Build & install mlat-client
  BRANCH_MLATCLIENT=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' 'https://github.com/mutability/mlat-client.git' | grep -v '\^' | cut -d '/' -f 3 | grep '^v.*' | tail -1) && \
  git clone --depth 1 --branch "$BRANCH_MLATCLIENT" "https://github.com/mutability/mlat-client.git" "/src/mlat-client" && \
  pushd /src/mlat-client && \
  BRANCH_MLATCLIENT="$(git tag --sort='-creatordate' | head -1)" && \
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
  # Clean up
  apt-get autoremove -q -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -y "${TEMP_PACKAGES[@]}" && \
  apt-get clean -y && \
  # remove pycache and other cleanup
  bash /scripts/clean-build.sh && \
  rm -rf /src /tmp/* /var/lib/apt/lists/* /var/log/* /var/cache/* && \
  # Store container version
  grep piaware /VERSIONS | cut -d " " -f 2 > /IMAGE_VERSION

COPY rootfs/ /

EXPOSE 80/tcp 30003/tcp 30005/tcp 30105/tcp 30978/tcp 30979/tcp

HEALTHCHECK --start-period=7200s --interval=600s CMD /scripts/healthcheck.sh
