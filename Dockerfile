FROM ubuntu:plucky AS build

RUN apt-get update
RUN apt install -y gawk patch bzip2 tar make libgmp-dev libmpfr-dev libmpc-dev gettext wget libelf-dev texinfo bison flex sed git build-essential diffutils curl libjpeg-dev libpng-dev python3 pkg-config cmake libisofs-dev meson ninja-build rake cmake

SHELL ["/bin/bash", "-l", "-c"]

RUN mkdir -p /opt/toolchains/dc
RUN chmod -R 755 /opt/toolchains/dc
RUN chown -R $(id -u):$(id -g) /opt/toolchains/dc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
RUN echo ". \"$HOME/.cargo/env\"" >> $HOME/.bashrc

RUN git clone https://github.com/dreamcast-rs/rust-for-dreamcast.git /opt/toolchains/dc/rust
RUN git clone https://github.com/dreamcast-rs/KallistiOS /opt/toolchains/dc/rust/kos

RUN /opt/toolchains/dc/rust/misc/install-toolchain.sh -j4

RUN echo 'source /opt/toolchains/dc/rust/misc/environ.sh' >> $HOME/.bashrc

WORKDIR /opt/toolchains/dc/rust/kos/
RUN source /opt/toolchains/dc/rust/misc/environ.sh; make

WORKDIR /root/
RUN git config --global user.email "enter@youremail.com"
RUN git config --global user.name "Enter Name"
RUN source /opt/toolchains/dc/rust/misc/environ.sh; /opt/toolchains/dc/rust/misc/install-rust.sh

RUN rustup component add rust-analyzer

RUN cd /opt/toolchains/dc/rust/kos/utils/dc-chain && make toolchain_profile=rustc-dev clean distclean
RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

FROM scratch
COPY --from=build / /

