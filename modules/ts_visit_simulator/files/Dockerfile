FROM centos:7

LABEL authors="Andres Anania <aanania@lsst.org>, Sebastian Pereira <sebastian.pereira@inria.cl>"

# install required software
RUN yum -y --enablerepo=extras install epel-release \
  gsl \
  unzip \
  wget \
  git \
  tk \
  tk-devel \
  swig \
  ncurses-libs \
  xterm \
  xorg-x11-fonts-misc \
  java-1.8.0-openjdk-devel \
  boost-python \
  boost-python-devel \
  maven \
  python-devel \
  python-pip \
  python-wheel \
  gnome-terminal \
  nano && \
  yum clean all

RUN yum groupinstall -y "Development Tools" "Development Libraries" && \
  yum clean all

# install python3
RUN wget ftp://ftp.noao.edu/pub/dmills/python3-to-install.tgz
RUN tar -zxvf python3-to-install.tgz && rm python3-to-install.tgz
RUN cd Python-3.6.3 && make install

#COPY ./ts_visit_simulator /home/docker/workspace/ts_visit_simulator

COPY ./requirements.txt /home/docker/lsst/LSST-server/requirements.txt
RUN pip3 install -r /home/docker/lsst/LSST-server/requirements.txt

COPY ./run.sh /home/docker/lsst/run.sh

RUN chmod +x /home/docker/lsst/run.sh
ENTRYPOINT source /home/docker/workspace/ts_visit_simulator/setup.env && \
  /home/docker/lsst/run.sh
