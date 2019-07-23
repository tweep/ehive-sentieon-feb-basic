# Container 'lineage' 
# tweep/ehive-base-ubuntu-18
#            ↓
#            ↓
# tweep/ehve-base-ubuntu-18-extended:latest

# ehve-base-ubuntu-18-extended contains aws cli + some other required perl modules  
FROM tweep/ehve-base-ubuntu-18-extended:latest




# Install bcftools 
#ADD https://sourceforge.net/projects/samtools/files/samtools/1.6/bcftools-1.6.tar.bz2/download  bcftools.tar.bz2
#RUN mkdir bcftools && tar xjf bcftools.tar.bz2 -C bcftools --strip-components 1  
#RUN apt-get -y install zlib1g-dev 
#RUN cd bcftools && /configure --disable-bz2 --disable-lzma && make install 

# Install samtools 1.6 
ADD https://sourceforge.net/projects/samtools/files/samtools/1.6/samtools-1.6.tar.bz2/download  samtools.tar.bz2 
RUN mkdir samtools && tar xjf samtools.tar.bz2 -C samtools --strip-components 1  
RUN apt-get -y install zlib1g-dev 
RUN cd samtools && ./configure --without-curses --disable-bz2 --disable-lzma && make && make install  

# Install sentieon  https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-201711.04.tar.gz
#COPY sentieon-genomics-201711.04.tar.gz   .
ADD https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-201711.04.tar.gz .
RUN mkdir sentieon && tar xvf  sentieon-genomics-201711.04.tar.gz  -C sentieon --strip-components 1 
ENV PATH "/sentieon/bin:$PATH"
ENV SENTIEON_LICENSE=resflexlm401.gene.com:8999


# Install gatk 
RUN ln -s /usr/bin/python3 /usr/bin/python  
RUN apt-get install unzip 
#ADD gatk-4.0.2.1.zip  .
ADD https://github.com/broadinstitute/gatk/releases/download/4.0.2.1/gatk-4.0.2.1.zip . 
RUN unzip gatk-4.0.2.1.zip 
ENV PATH "/gatk-4.0.2.1/:$PATH"

# Install picard
COPY picard.jar .
ENV PICARD_HOME /

ENTRYPOINT [ "/repo/ensembl-hive/scripts/dev/simple_init.py" ]
#USER ubuntu
CMD [ "/bin/bash" ]
