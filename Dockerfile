# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /smartstring
WORKDIR /smartstring

RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

COPY --from=builder smartstring/fuzz/target/x86_64-unknown-linux-gnu/release/smartstring_lazycompact /
COPY --from=builder smartstring/fuzz/target/x86_64-unknown-linux-gnu/release/smartstring_compact /
COPY --from=builder smartstring/fuzz/target/x86_64-unknown-linux-gnu/release/ordering_compact /



