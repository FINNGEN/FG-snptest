FROM gcr.io/finngen-refinery-dev/bioinformatics:0.5

LABEL maintainer="veerapen@broadinstitute.org"

RUN apt-get clean && apt-get update

RUN apt-get install python3-pip --yes && \
    apt-get remove default-jre --yes && apt autoremove --yes && apt-get clean

RUN apt update && \
  apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev --yes && \
  wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && tar -xf Python-3.8.0.tgz && rm Python-3.8.0.tgz && \
  Python-3.8.0/configure --enable-optimizations && make altinstall 

RUN pip3.8 install cget networkx utils numpy pandas

RUN curl -LO 'www.well.ox.ac.uk/~gav/resources/snptest_v2.5.4-beta3_linux_x86_64_dynamic.tgz' && \
    tar zxvf snptest_v2.5.4-beta3_linux_x86_64_dynamic.tgz && rm snptest_v2.5.4-beta3_linux_x86_64_dynamic.tgz && \
    mv snptest_v2.5.4-beta3_linux_x86_64_dynamic/snptest_v2.5.4-beta3 snptest_v2.5.4-beta3_linux_x86_64_dynamic/snptest && \
    mv snptest_v2.5.4-beta3_linux_x86_64_dynamic/* /usr/local/bin/

RUN curl -LO 'http://s3.amazonaws.com/plink2-assets/plink2_linux_avx2_20210302.zip' && \
    unzip plink2_linux_avx2_20210302.zip && rm plink2_linux_avx2_20210302.zip && \
    mv plink2 plink && \
    mv plink /usr/local/bin/

RUN Rscript -e "install.packages('janitor', repos = 'http://cran.us.r-project.org/'); \
  install.packages('ggmosaic', repos = 'http://cran.us.r-project.org/'); \
  install.packages('readr', repos = 'http://cran.us.r-project.org/'); \
  install.packages('knitr', repos = 'http://cran.us.r-project.org/'); \
  install.packages('kableExtra', repos = 'http://cran.us.r-project.org/'); \
  install.packages('dplyr', repos = 'http://cran.us.r-project.org/'); \
  install.packages('R.utils',repos = 'http://cran.us.r-project.org/'); \
  install.packages('optparse', repos = 'http://cran.us.r-project.org/')"

ADD scripts/FG-snptest_1.R  /usr/local/bin/

ADD scripts/FG-snptest_2.R  /usr/local/bin/

RUN chmod a+x /usr/local/bin/FG-snptest_1.R /usr/local/bin/FG-snptest_2.R

ADD scripts/*.py /usr/local/bin/

RUN chmod a+x /usr/local/bin/*.py