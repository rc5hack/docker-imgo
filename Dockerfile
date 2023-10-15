
# Stage 1: stage-builder
#########################################################

FROM ubuntu:22.04 AS stage-builder
LABEL builder=imgo-builder

RUN apt-get update && \
    apt-get -y -q --no-install-recommends install -- \
        ca-certificates git wget make gcc libc6 libc6-dev libpng-dev tar unzip && \
    apt-get clean && \
    rm -rf -- /var/lib/apt/lists/*
WORKDIR /opt/imgo
RUN mkdir -- /opt/imgo/bin
RUN git clone https://github.com/rc5hack/imgo.git ./imgo-sources && cp -v -- imgo-sources/imgo /opt/imgo/bin/
RUN wget http://static.jonof.id.au/dl/kenutils/pngout-20150319-linux-static.tar.gz -O pngout.tar.gz && tar -xvf pngout.tar.gz && cp -v -- pngout-20150319-linux-static/`uname -m`/pngout-static /opt/imgo/bin/pngout
RUN wget https://github.com/imgo/imgo-tools/raw/master/src/defluff/defluff-0.3.2-linux-`uname -m`.zip -O defluff.zip && unzip defluff.zip && chmod a+x defluff && cp -v -- defluff /opt/imgo/bin/
RUN wget http://frdx.free.fr/cryopng/cryopng-linux-x86.tgz -O cryo.tgz && tar -zxf cryo.tgz && cp -v -- cryo-files/cryopng /opt/imgo/bin/
RUN mkdir pngrewrite && cd pngrewrite/ && wget http://entropymine.com/jason/pngrewrite/pngrewrite-1.4.0.zip -O pngrewrite.zip && unzip pngrewrite.zip && make && cp ./pngrewrite /opt/imgo/bin/

# Stage 2: stage-runner
#########################################################

FROM ubuntu:22.04 AS stage-runner

RUN apt-get update && \
    apt-get -y --no-install-recommends install -- \
        libimage-exiftool-perl libjpeg-progs libpng-dev advancecomp gifsicle imagemagick optipng pngnq && \
    apt-get clean && \
    rm -rf -- /var/lib/apt/lists/*
COPY --from=stage-builder /opt/imgo/bin/* /usr/local/bin/
