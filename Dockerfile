FROM swift:5.0.2

RUN apt-get update
RUN apt-get install -y cmake libpq-dev libssl-dev libz-dev openssl postgresql

WORKDIR /app

COPY Makefile ./
COPY Package.swift ./
COPY Sources ./Sources
COPY Tests ./Tests

# cmark
RUN git clone https://github.com/commonmark/cmark
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift package update
RUN swift build --product Server --configuration release -Xswiftc -g && \
    swift build --product Runner --configuration release -Xswiftc -g
CMD .build/release/Server
