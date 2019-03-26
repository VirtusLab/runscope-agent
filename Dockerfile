FROM alpine:3.9

ENV ARCHIVE_NAME="runscope-radar.zip" \
    BIN_DIRECTORY="/home/agent/bin" \
    USER="agent" \
    AGENT_UID="472" \
    AGENT_GID="472"

RUN set -x && apk --no-cache add --update ca-certificates && \
    addgroup -g "${AGENT_GID}" -S "${USER}" && \
    adduser -u "${AGENT_UID}" -S "${USER}" -G "${USER}" && \
    mkdir -p "${BIN_DIRECTORY}" && \
    wget "https://s3.amazonaws.com/runscope-downloads/runscope-radar/latest/linux-386/${ARCHIVE_NAME}" && \
    unzip "${ARCHIVE_NAME}" -d "${BIN_DIRECTORY}" && rm "${ARCHIVE_NAME}" && \
    chown -R "${USER}:${USER}" "${BIN_DIRECTORY}"

USER "${USER}"
ENTRYPOINT [ "/home/agent/bin/runscope-radar" ]
CMD ["--version"]