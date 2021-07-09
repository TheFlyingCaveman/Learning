FROM golang:1.16.5
ADD main.go /sample/

WORKDIR /sample

RUN ln -sf /dev/stdout First.log && \
    ln -sf /dev/stdout Second.log

CMD go run main.go