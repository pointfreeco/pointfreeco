FROM norionomura/swift:421

# postgres
RUN apt-get update
RUN apt-get install -y postgresql libpq-dev

ENV OSS 1
WORKDIR /app

COPY .build/dependencies-state.json ./.build/dependencies-state.json
COPY .env ./
COPY Makefile ./
COPY Package.swift ./
COPY Packages ./Packages
COPY Sources ./Sources
COPY Tests ./Tests

# cmark
RUN apt-get -y install cmake
RUN git clone https://github.com/commonmark/cmark
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift package update
RUN swift build --product Server --configuration release
CMD ./.build/release/Server
