FROM swift:4.0

ENV SKIP_TESTS 1

RUN swift --version

RUN apt-get update
RUN apt-get install -y postgresql libpq-dev

WORKDIR /app

COPY Makefile ./
RUN make install-cmark

COPY Package.swift ./
RUN swift package update

COPY Sources ./Sources
RUN swift build --configuration release

CMD ./.build/release/pointfreeco
