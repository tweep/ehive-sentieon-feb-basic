# Container 'lineage'  
# ubuntu:18.04
#            ↓
# tweep/ehive-base-ubuntu-18
#            ↓
# tweep/ehive-base-ubuntu-18-extended:latest ( aws cli, perl modules ) 

# THIS: tweep/ehive-sentieon-feb-basic 

FROM tweep/ehive-aws-rsc:latest 

WORKDIR /home/ubuntu
USER root

# This Docker file installs various bioinformatic tools for our pipelines: 
# Sentieon FEB 

RUN apt-get -y install libbz2-dev liblzma-dev libssl1.0-dev zlib1g-dev libcurl3  pkg-config

# Install bcftools 

ADD https://sourceforge.net/projects/samtools/files/samtools/1.6/bcftools-1.6.tar.bz2/download  bcftools.tar.bz2
RUN mkdir bcftools && tar xjf bcftools.tar.bz2 -C bcftools --strip-components 1  
RUN cd bcftools && ./configure --disable-bz2 --disable-lzma --prefix=/usr/local/bin 

RUN cd /usr/local/bin && wget https://github.com/samtools/htslib/releases/download/1.6/htslib-1.6.tar.bz2 &&  tar -vxjf htslib-1.6.tar.bz2 &&  cd htslib-1.6  && make
ENV PATH="/usr/local/bin/htslib-1.6:${PATH}"

# Install samtools 1.6 
ADD https://sourceforge.net/projects/samtools/files/samtools/1.6/samtools-1.6.tar.bz2/download  samtools.tar.bz2 
RUN mkdir samtools && tar xjf samtools.tar.bz2 -C samtools --strip-components 1  
RUN cd samtools && ./configure --without-curses --disable-bz2 --disable-lzma && make && make install  
ENV PATH="/home/ubuntu/samtools:${PATH}"

# Install samblaster
RUN git clone git://github.com/GregoryFaust/samblaster.git
RUN cd samblaster && make && cp samblaster /usr/local/bin/

# Install sentieon  https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-201711.04.tar.gz
#COPY sentieon-genomics-201711.04.tar.gz   .
ADD https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-201711.04.tar.gz .
RUN mkdir sentieon && tar xvf  sentieon-genomics-201711.04.tar.gz  -C sentieon --strip-components 1 
ENV PATH="/home/ubuntu/sentieon/bin:${PATH}"
ENV SENTIEON_LICENSE=resflexlm401.gene.com:8999


# Install gatk 
RUN ln -s /usr/bin/python3 /usr/bin/python  
RUN apt-get install unzip 
#ADD gatk-4.0.2.1.zip  .
ADD https://github.com/broadinstitute/gatk/releases/download/4.0.2.1/gatk-4.0.2.1.zip . 
RUN unzip gatk-4.0.2.1.zip 
ENV PATH="/home/ubuntu/gatk-4.0.2.1/:${PATH}"

# Install picard
COPY picard.jar .
ENV PICARD_HOME "/home/ubuntu/" 

ENTRYPOINT [ "/repo/ensembl-hive/scripts/dev/simple_init.py" ]
CMD [ "/bin/bash" ]
