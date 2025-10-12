FROM swift:6.0-jammy

WORKDIR /app

COPY . .

RUN swift build
RUN swift test
