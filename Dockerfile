FROM swift:4.0

RUN apt-get update
RUN apt-get install -y postgresql libpq-dev

WORKDIR /package

COPY . ./

RUN swift package resolve
RUN swift package clean
CMD swift test
