FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get -yqq update
#Install tzdata
RUN apt-get -yqq install tzdata

#Install killall
RUN apt-get -yqq install psmisc

# Set timezone
RUN echo "US/Pacific" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Create a default user
RUN useradd automation --shell /bin/bash --create-home

# Update the repositories
# Install utilities
# Install XVFB and TinyWM
# Install fonts
# Install Python
RUN apt-get -yqq update
RUN apt-get -yqq install curl unzip
RUN apt-get -yqq install xvfb tinywm
RUN apt-get -yqq install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic
# RUN apt-get -yqq install python
# RUN rm -rf /var/lib/apt/lists/*

RUN apt-get -yqq install language-pack-en-base
RUN dpkg-reconfigure locales
RUN export LC_ALL="en_US.UTF-8"

RUN mkdir -p /run/user
RUN chmod -R 777 /run/user/

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -yqq update
RUN apt-get -yqq install google-chrome-stable
# RUN rm -rf /var/lib/apt/lists/*

# Install Firefox
RUN apt-get -yqq install firefox

#Install Maven
RUN apt-get -yqq install maven

#Install apt tools
RUN apt-get -yqq install software-properties-common python-software-properties

#Install Oracle Java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install GeckoDriver
RUN curl -L https://github.com/mozilla/geckodriver/releases/download/v0.16.1/geckodriver-v0.16.1-linux64.tar.gz | tar xz -C /usr/local/bin

# Verify
RUN firefox --version
RUN google-chrome --version
RUN geckodriver --version
RUN chromedriver --version

EXPOSE 4444
