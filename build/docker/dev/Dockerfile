FROM golang:1.16 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends tzdata

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ARG SSH_PRIVATE_KEY

WORKDIR /app

COPY . .

RUN make install
RUN go build ./cmd/main.go

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /app /
COPY ./templates ./templates 

CMD ["./main"]

EXPOSE 3000