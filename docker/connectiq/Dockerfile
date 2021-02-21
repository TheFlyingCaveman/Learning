FROM ubuntu:18.04 as base
LABEL Author=JoshuaMiller

# https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
ARG SDK_VERSION=connectiq-sdk-lin-3.2.5-2021-02-12-6d31f4357.zip
# Add URL here to help doc, throw error in prepare script if this value equals default
ARG ACCESS_TOKEN=THIS_MUST_BE_SUPPLIED_WITH_YOUR_OWN_ACCESS_TOKEN

ADD https://developer.garmin.com/downloads/connect-iq/sdks/${SDK_VERSION} connectiq-sdk.zip
COPY prepare_environment.js prepare_environment.js

RUN apt-get update
RUN apt-get install -y unzip curl
RUN unzip connectiq-sdk.zip -d /connectiq-sdk/

FROM ubuntu:18.04
# Not sure if this can remain current of if it needs to match the download name
COPY --from=base /connectiq-sdk /.Garmin/ConnectIQ/Sdks/current

RUN apt-get update
RUN apt-get install libusb-1.0-0 openjdk-11-jre -y

RUN echo "PATH=$PATH:/.Garmin/ConnectIQ/Sdks/current/bin export PATH" >> ~/.bashrc