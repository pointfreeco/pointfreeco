FROM swift:5.7 as build

RUN apt-get --fix-missing update
RUN apt-get install -y build-essential cmake libpq-dev libssl-dev libz-dev openssl python-is-python3

WORKDIR /build

COPY Package.swift .
COPY Sources ./Sources
COPY Tests ./Tests

RUN git clone https://github.com/commonmark/cmark \
  && cd cmark \
  && git checkout 1880e6535e335f143f9547494def01c13f2f331b
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift build -j 1 --configuration release --product Server -Xswiftc -g \
  && swift build -j 1 --configuration release --product Runner -Xswiftc -g

FROM swift:5.7-slim

RUN apt-get update
RUN apt-get install -y libpq-dev libssl-dev libz-dev openssl

WORKDIR /app

COPY --from=build /usr/include/cmark* /usr/include/
COPY --from=build /usr/lib/libcmark* /usr/lib/
COPY --from=build /build/.build/release/Server /usr/bin
COPY --from=build /build/.build/release/Runner /usr/bin
CMD Server
