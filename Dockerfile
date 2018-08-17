FROM norionomura/swift:41

# postgres
RUN apt-get update
RUN apt-get install -y postgresql libpq-dev

WORKDIR /app

COPY Makefile ./
COPY Package.swift ./
COPY Sources ./Sources
COPY Tests ./Tests

# cmark
RUN apt-get update
RUN apt-get -y install cmake
RUN git clone https://github.com/commonmark/cmark
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift package update
RUN swift build --product Server --configuration release && \
    swift build --product Runner --configuration release
CMD .build/release/Server
