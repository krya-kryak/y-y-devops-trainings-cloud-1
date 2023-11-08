# stage 1: build
FROM golang:1.21
WORKDIR /app
COPY . .
RUN pwd
RUN ls -la
RUN make build