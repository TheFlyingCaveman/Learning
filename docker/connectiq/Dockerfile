FROM ubuntu:18.04 as base
# https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
ARG SDK_VERSION=connectiq-sdk-lin-3.2.5-2021-02-12-6d31f4357
# Add URL here to help doc, throw error in prepare script if this value equals default
ARG ACCESS_TOKEN=THIS_MUST_BE_SUPPLIED_WITH_YOUR_OWN_ACCESS_TOKEN

ADD https://developer.garmin.com/downloads/connect-iq/sdks/${SDK_VERSION}.zip connectiq-sdk.zip

RUN apt-get update
RUN apt-get install -y unzip curl
RUN unzip connectiq-sdk.zip -d /connectiq-sdk/

FROM golang:1.7.3 as appBase
WORKDIR /usr/app
COPY banana_fetcher .
RUN go build -o ./out/bananaFetcher

FROM ubuntu:18.04 as bananaFetcher
ARG ACCESS_TOKEN
COPY --from=appBase /usr/app/out /bin
RUN apt-get update
RUN apt-get install -y ca-certificates
RUN bananaFetcher ${ACCESS_TOKEN} /Devices

FROM xvfb-w-java
LABEL Author=JoshuaMiller
ARG SDK_VERSION
# Not sure if this can remain current of if it needs to match the download name
COPY --from=base /connectiq-sdk /.Garmin/ConnectIQ/Sdks/${SDK_VERSION}
COPY --from=bananaFetcher /Devices /.Garmin/ConnectIQ/Devices
COPY capture_screen.sh .

RUN echo "PATH=$PATH:/.Garmin/ConnectIQ/Sdks/current/bin export PATH" >> ~/.bashrc