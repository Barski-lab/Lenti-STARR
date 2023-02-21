###################################################################################################
# Build Cmd:        docker build --no-cache --rm -t biowardrobe2/starr:v0.0.1 -f Dockerfile .
# Pull Cmd:         docker pull biowardrobe2/starr:v0.0.1
# Run Cmd:          docker run --rm -ti biowardrobe2/starr:v0.0.1 /bin/bash
###################################################################################################

FROM r-base:4.2.2
LABEL maintainer="misha.kotliar@gmail.com"
ENV DEBIAN_FRONTEND noninteractive

ENV MACS2_URL "https://github.com/macs3-project/MACS.git"
ENV MACS2_VERSION "2.2.7.1"

WORKDIR /tmp

COPY ./process.sh /usr/local/bin/process.sh

RUN apt-get update && \
    apt-get install -y git gcc-10-base libgcc-10-dev libssl-dev openssl wget build-essential zlib1g-dev libffi-dev vim && \
    wget https://www.python.org/ftp/python/3.8.13/Python-3.8.13.tgz && \
    tar -xvf Python-3.8.13.tgz && \
    cd Python-3.8.13 && \
    ./configure --enable-optimizations && \
    make && \
    make install && \
    ln -fs /usr/local/bin/python3 /usr/bin/python3 && \
    ln -fs /usr/local/bin/python3 /usr/bin/python && \
    cd .. && \
    wget -q -O - https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz | tar -zxv && \
    cd bedtools2 && \
    make && \
    make install && \
    cd .. && \
    git clone --depth 1 --branch v${MACS2_VERSION} ${MACS2_URL} && \
    cd MACS && \
    sed -i -e 's/numpy>=/numpy /g' setup.py && \
    pip3 install . && \
    cd .. && \
    R -e 'install.packages("fitdistrplus")' && \
    chmod +x /usr/local/bin/process.sh && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* && \
    strip /usr/local/bin/*; true