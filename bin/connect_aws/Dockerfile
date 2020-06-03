FROM alpine:latest

COPY requirements.txt /

RUN apk update && \
    apk add \
    openssh \
    python \
    py-pip \
    && \
    pip install -r requirements.txt

COPY connect_cloud.sh /
COPY connect_cloud.py /

ENTRYPOINT ["/connect_cloud.sh"]
