FROM python:3.7-alpine as build

RUN apk add --no-cache --progress \
        build-base \
        cargo \
        git \
        libffi-dev \
        openssl-dev

WORKDIR /wheels
RUN pip install -U pip
# Unless this environment variable is set, Syncplay's setup.py tries to grab GUI dependencies
RUN SNAPCRAFT_PART_BUILD=1 pip wheel git+https://github.com/syncplay/syncplay.git@v1.6.7#egg=syncplay

FROM python:3.7-alpine

RUN  apk add --no-cache --update --progress \
        openssl \
        libffi

COPY --from=build /wheels /wheels
WORKDIR /wheels
RUN pip install *.whl

EXPOSE 8999
COPY ./entrypoint.sh /entrypoint.sh

# Run as non-root user                                                                                                  
WORKDIR /app/syncplay
RUN addgroup -g 800 -S syncplay && \
    adduser -u 800 -S syncplay -G syncplay && \
    chown -R syncplay:syncplay /app/syncplay

USER syncplay
ENTRYPOINT ["/entrypoint.sh"]
