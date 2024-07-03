FROM swift:5.10 as build

RUN apt-get --fix-missing update
RUN apt-get install -y build-essential cmake libpq-dev libz-dev python-is-python3

WORKDIR /build

COPY Package.resolved .
COPY Package.swift .
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift build -j 1 --configuration release --product Server -Xswiftc -g \
  && swift build -j 1 --configuration release --product Runner -Xswiftc -g

FROM swift:5.10-slim

RUN apt-get update
RUN apt-get install -y libpq-dev libssl-dev libz-dev openssl

WORKDIR /app

COPY --from=build /usr/include/cmark* /usr/include/
COPY --from=build /usr/lib/libcmark* /usr/lib/
COPY --from=build /build .
RUN ln -s /app/.build/release/Server /usr/bin
RUN ln -s /app/.build/release/Runner /usr/bin
CMD Server
