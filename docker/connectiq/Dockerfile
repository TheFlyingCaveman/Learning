FROM ubuntu
LABEL Author=JoshuaMiller

# https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
ARG SDK_VERSION=connectiq-sdk-lin-3.2.5-2021-02-12-6d31f4357.zip

ADD https://developer.garmin.com/downloads/connect-iq/sdks/${SDK_VERSION} connectiq-sdk.zip

RUN apt-get update

RUN apt-get install -y unzip curl
RUN unzip connectiq-sdk.zip -d /connectiq-sdk

