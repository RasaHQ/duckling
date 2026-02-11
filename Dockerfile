FROM haskell:9-bookworm AS builder

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libpcre3-dev build-essential pkg-config --fix-missing --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /log

WORKDIR /duckling

ADD . .

ENV LANG=C.UTF-8

RUN stack setup --install-ghc

ADD . .

# NOTE:`stack build` will use as many cores as are available to build
# in parallel. However, this can cause OOM issues as the linking step
# in GHC can be expensive. If the build fails, try specifying the
# '-j1' flag to force the build to run sequentially.
RUN stack install -j1

FROM debian:bookworm

ENV LANG=C.UTF-8

RUN apt-get update -qq && \
  apt-get install -qq -y libpcre3 libgmp10 --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /root/.local/bin/duckling-example-exe /usr/local/bin/

COPY ./debian.sources /etc/apt/sources.list.d/debian.sources

RUN /bin/rm -f /etc/apt/sources.list/* && apt update && apt upgrade -y --without-new-pkgs && apt full-upgrade -y && apt install -y libgnutls30t64 && apt -y autoremove && useradd -c duckling -N -m duckling

EXPOSE 8000

USER duckling
WORKDIR /home/duckling
CMD ["duckling-example-exe", "-p", "8000"]
