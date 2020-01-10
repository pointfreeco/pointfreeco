FROM swift:5.1 as build

RUN apt-get update
RUN apt-get install -y cmake libpq-dev libssl-dev libz-dev openssl

WORKDIR /build

COPY Package.swift .
COPY Sources ./Sources
COPY Tests ./Tests

RUN git clone https://github.com/commonmark/cmark \
  && cd cmark \
  && git checkout 1880e6535e335f143f9547494def01c13f2f331b
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift build --configuration release --product Server \
  && swift build --configuration release --product Runner

FROM swift:5.1-slim

RUN apt-get update
RUN apt-get install -y libpq-dev libssl-dev libz-dev openssl

WORKDIR /app

COPY --from=build /usr/include/cmark* /usr/include/
COPY --from=build /usr/lib/libcmark* /usr/lib/
COPY --from=build /build/.build/release/Server /usr/bin
COPY --from=build /build/.build/release/Runner /usr/bin
ENTRYPOINT ["Server"]
