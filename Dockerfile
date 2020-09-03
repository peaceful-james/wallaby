# https://github.com/c0b/docker-elixir/wiki/use-observer
FROM elixir:latest

RUN apt update
# RUN apt install -y git inotify-tools
RUN apt install -y chromium-driver

RUN mkdir -p /opt/wallaby
WORKDIR /opt/wallaby

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix archive.install --force hex phx_new

COPY mix.exs .
COPY mix.lock .

# copy the deps in dev environment for faster builds
COPY deps ./deps
RUN ["mix", "deps.get"]
RUN ["mix", "deps.compile"]

WORKDIR /opt/wallaby

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY test ./test
COPY integration_test ./integration_test
COPY benchmarks ./benchmarks

RUN ["mix", "compile"]

# compile deps in test environment for faster test runs when built
RUN export MIX_ENV=test && mix deps.compile

COPY ./entrypoint.sh ./entrypoint.sh
CMD ["/bin/bash", "entrypoint.sh"]
