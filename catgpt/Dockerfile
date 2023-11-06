FROM golang:1.21 as build
LABEL authors="r_zurabyan"

WORKDIR /go/src/app
#WORKDIR /app

#COPY go.mod go.sum ./
COPY . .

RUN go mod download

#COPY *.go ./

RUN CGO_ENABLED=0 go build -o /go/bin/app
FROM gcr.io/distroless/static-debian12
COPY --from=build /go/bin/app /
CMD ["/app"]