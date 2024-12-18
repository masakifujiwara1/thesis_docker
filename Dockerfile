FROM ubuntu:20.04

ARG TEXLIVE_VERSION=2023

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes
ENV PATH="/usr/local/texlive/bin:$PATH"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        make \
        wget \
        libfontconfig1-dev \
        libfreetype6-dev \
        ghostscript \
        perl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG USER_NAME=ubuntu
ARG GROUP_NAME=ubuntu
ARG UID=1000
ARG GID=1000
ARG PASSWORD=ubuntu
RUN groupadd -g $GID $GROUP_NAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USER_NAME && \
    echo $USER_NAME:$PASSWORD | chpasswd && \
    echo "$USER_NAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/$USER_NAME
ENV TERM=xterm-256color

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-pip \
        python3-dev && \
    pip3 install --no-cache-dir pygments

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-pip \
        python3-dev && \
    pip3 install --no-cache-dir pygments && \
    mkdir /tmp/install-tl-unx && \
    wget -O - ftp://tug.org/historic/systems/texlive/${TEXLIVE_VERSION}/install-tl-unx.tar.gz \
        | tar -xzv -C /tmp/install-tl-unx --strip-components=1 && \
    /bin/echo -e 'selected_scheme scheme-basic\ntlpdbopt_install_docfiles 0\ntlpdbopt_install_srcfiles 0' \
        > /tmp/install-tl-unx/texlive.profile && \
    /tmp/install-tl-unx/install-tl \
        --profile /tmp/install-tl-unx/texlive.profile \
        -repository  ftp://tug.org/texlive/historic/${TEXLIVE_VERSION}/tlnet-final/ && \
    rm -r /tmp/install-tl-unx && \
    ln -sf /usr/local/texlive/${TEXLIVE_VERSION}/bin/$(uname -m)-linux /usr/local/texlive/bin && \
    apt-get remove -y --purge \
        build-essential \
        python3 && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN tlmgr update --self && \
    tlmgr install \
        collection-bibtexextra \
        collection-fontsrecommended \
        collection-langenglish \
        collection-langjapanese \
        collection-latexextra \
        collection-latexrecommended \
        collection-luatex \
        collection-mathscience \
        collection-plaingeneric \
        collection-xetex \
        latexmk \
        latexdiff

USER $USER_NAME

COPY thesis_template/.latexmkrc /
COPY thesis_template/.latexmkrc /root/

CMD ["bash"]