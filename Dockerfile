# stage 1: build
FROM golang:1.21 as build
LABEL stage=intermediate
WORKDIR /app
COPY . .
RUN pwd
RUN ls -la
RUN make build

# stage 2: runtime
FROM gcr.io/distroless/static-debian12:latest-amd64
COPY --from=build /app/catgpt/bin/catgpt /
CMD ["/catgpt"]