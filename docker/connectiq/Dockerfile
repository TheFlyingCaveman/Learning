FROM openjdk
LABEL Author=JoshuaMiller

ADD https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip  /

RUN apt-get update && \
    apt-get install -y unzip --no-install-recommend && \
    unzip connectiq-sdk-manager-linux.zip -d/ connectiq
