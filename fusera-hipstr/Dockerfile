FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -qqy \
    awscli \
    zlib1g-dev libbz2-dev libz-dev liblzma-dev bzip2 \
    libcurl4-openssl-dev libssl-dev \
    python3 python3-pip \
    make gcc g++ \
    unzip \
    libfuse-dev \
    curl \
    wget

# Install samtools (needed to index reference fasta files)
RUN wget -O samtools-1.9.tar.bz2 https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar -xjf samtools-1.9.tar.bz2
WORKDIR samtools-1.9
RUN ./configure --without-curses && make && make install
WORKDIR ..

# Install HipSTR
RUN wget https://github.com/tfwillems/HipSTR/archive/v0.7.tar.gz
RUN tar -xzvf v0.7.tar.gz 
WORKDIR HipSTR-0.7/
RUN make
RUN cp HipSTR /usr/local/bin/
WORKDIR ..

# Install fusera
RUN wget https://github.com/mitre/fusera/archive/v1.0.0.tar.gz
RUN tar -xzvf v1.0.0.tar.gz
WORKDIR fusera-1.0.0
RUN bash install.sh

# Add the fetch_and_run.sh script
ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh

# Set up directories
RUN mkdir /data
RUN mkdir /results

# Get set up to run
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
