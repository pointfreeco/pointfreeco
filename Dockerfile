FROM swift:5.1

RUN apt-get update
RUN apt-get install -y cmake libpq-dev libssl-dev libz-dev openssl postgresql

WORKDIR /app

COPY Makefile ./
COPY Package.swift ./
COPY Sources ./Sources
COPY Tests ./Tests

# cmark
RUN git clone https://github.com/commonmark/cmark && \
	cd cmark && \
	git checkout 1880e6535e335f143f9547494def01c13f2f331b
RUN make -C cmark INSTALL_PREFIX=/usr
RUN make -C cmark install

RUN swift package update
RUN swift build --product Server --configuration release -Xswiftc -g && \
    swift build --product Runner --configuration release -Xswiftc -g
CMD .build/release/Server
