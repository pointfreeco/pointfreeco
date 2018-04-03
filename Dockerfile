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
RUN make linux-install-cmark

RUN swift package update
RUN swift build --product Server --configuration release
CMD .build/release/Server
