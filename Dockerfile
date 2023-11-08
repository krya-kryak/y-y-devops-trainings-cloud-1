# stage 1: build
FROM golang:1.21
LABEL stage=intermediate
WORKDIR /app
COPY . .
RUN pwd
RUN ls -la
RUN make build