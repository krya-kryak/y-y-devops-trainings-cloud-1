FROM golang:1.21
RUN pwd
RUN ls -la
RUN ls -la ./bin
RUN ls -la ./src
RUN go mod download