FROM ubuntu:16.04

# Update necessary packages
RUN apt-get update && apt-get install -qqy \
    awscli \
    build-essential \
    git \
    libbz2-dev \
    liblzma-dev \
    make \
    pkg-config \
    wget \
    unzip \
    zlib1g-dev

# Download, compile, and install GangSTR
RUN wget -O GangSTR-2.1.tar.gz https://github.com/gymreklab/GangSTR/releases/download/v2.1/GangSTR-2.1.tar.gz
RUN tar -xzvf GangSTR-2.1.tar.gz
WORKDIR GangSTR-2.1
RUN ./install-gangstr.sh
RUN ldconfig

# Install samtools
WORKDIR ..
RUN wget -O samtools-1.9.tar.bz2 https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar -xjf samtools-1.9.tar.bz2
WORKDIR samtools-1.9
RUN ./configure --without-curses && make && make install
WORKDIR ..

# Add the fetch_and_run.sh script
ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh

# Get set up to run
WORKDIR /tmp
USER nobody
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]