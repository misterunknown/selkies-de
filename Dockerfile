FROM debian:trixie

# prepare docker container
RUN \
    echo "**** upgrade the system ****" && \
    apt update && apt full-upgrade -y && \
    echo "**** install dependencies (like described in "Quick start" here: https://selkies-project.github.io/selkies/start/ ****" && \
    apt install --no-install-recommends -y jq tar gzip ca-certificates curl \
        libpulse0 wayland-protocols libwayland-dev libwayland-egl1 x11-utils \
        x11-xkb-utils x11-xserver-utils xserver-xorg-core libx11-xcb1 \
        libxcb-dri3-0 libxkbcommon0 libxdamage1 libxfixes3 libxv1 libxtst6 \
        libxext6 xvfb \
        locales \
        lxde \
        patch && \
    echo "**** configure german locale ****" && \
    sed -i 's/^# *de_DE.UTF-8/de_DE.UTF-8/' /etc/locale.gen && \
    locale-gen de_DE.UTF-8 && \
    update-locale LANG=de_DE.UTF-8 && \
    echo "**** create user ****" && \
    useradd -s /bin/bash -u 1000 -m -p awesomepw user && \
    echo "**** install selkies (also from the quick start guide) ****" && \
    mkdir -p /usr/local/share/selkies && cd /usr/local/share/selkies && \
    export SELKIES_VERSION="$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')" && \
    curl -fsSL "https://github.com/selkies-project/selkies/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-portable-v${SELKIES_VERSION}_amd64.tar.gz" | tar -xzf -

COPY patch.0001 /tmp

RUN \
    patch /usr/local/share/selkies/selkies-gstreamer/lib/python3.12/site-packages/selkies_gstreamer/webrtc_input.py < /tmp/patch.0001

COPY selkies.sh /usr/local/bin

USER user

ENTRYPOINT ["/usr/local/bin/selkies.sh"]
