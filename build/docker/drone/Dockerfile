FROM alpine:3.15 as alpine

RUN apk add -U --no-cache ca-certificates tzdata

ENV USER=appuser
ENV UID=10001

RUN mkdir /tmpfiles

RUN adduser \
    -D \
    -g "" \
    -s "/sbin/nologin" \
    -H \
    -u "${UID}" \
    "${USER}"

FROM scratch
COPY --from=alpine /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=alpine /etc/passwd /etc/passwd
COPY --from=alpine /etc/group /etc/group
COPY ./bin/api .
COPY ./templates ./templates 
COPY --from=alpine --chown=appuser:appuser /tmpfiles /tmpfiles

USER appuser:appuser

CMD ["./api"]
