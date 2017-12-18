FROM swift:4.0

RUN apt-get update
RUN apt-get install -y postgresql libpq-dev

WORKDIR /package

COPY . ./

# Helps with: https://bugs.swift.org/browse/SR-6500
RUN rm -rf /package/.build/debug

RUN swift package resolve
RUN swift package clean
RUN make db
CMD swift test
