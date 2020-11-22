FROM jenkins/jenkins:latest
USER root
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88

# ANDROID SDK START

#RUN apt-get update && apt-get install -y dialog apt-utils  android-sdk
ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/30.0.2"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN dpkg --add-architecture i386 && \
    apt-get update -yqq && \
    apt-get install -y curl expect git libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 dialog apt-utils openjdk-8-jdk wget unzip vim && \
    apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

RUN mkdir -p ~/.android/
RUN touch ~/.android/repositories.cfg

WORKDIR /opt
RUN wget -q http://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O sdk-tools-linux.zip
RUN unzip sdk-tools-linux.zip
RUN rm sdk-tools-linux.zip

RUN mkdir android-sdk-linux
RUN mv tools android-sdk-linux

WORKDIR /opt/android-sdk-linux

RUN sdkmanager "cmdline-tools;latest"
RUN sdkmanager "build-tools;30.0.2"
RUN sdkmanager "platform-tools"
RUN sdkmanager "platforms;android-29"

RUN sdkmanager --licenses

RUN chmod 777 -R /opt/android-sdk-linux

TODO: FIX LICENSE

# ANDROID SDK END

RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"

RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins blueocean:1.24.3
