# An incomplete base Docker image for running JupyterHub 
# 
# Add your configuration to create a complete derivative Docker image. 
# 
# Include your configuration settings by starting with one of two options: 
# 
# Option 1: 
# 
# FROM jupyterhub/jupyterhub:latest 
# 
# And put your configuration file jupyterhub_config.py in /srv/jupyterhub/jupyterhub_config.py. 
# 
# Option 2: 
# 
# Or you can create your jupyterhub config and database on the host machine, and mount it with: 
# 
# docker run -v $PWD:/srv/jupyterhub -t jupyterhub/jupyterhub 
# 
# NOTE 
# If you base on jupyterhub/jupyterhub-onbuild 
# your jupyterhub_config.py will be added automatically 
# from your docker directory. 

FROM ubuntu:18.04 
LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# install nodejs, utf8 locale, set CDN because default httpredir is unreliable 
ENV DEBIAN_FRONTEND noninteractive 
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install wget git bzip2 && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8 

# install Python + NodeJS with conda 
RUN wget -q https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O /tmp/anaconda.sh  && \
    bash /tmp/anaconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge -c r \
      python=3.6 sqlalchemy tornado jinja2 traitlets requests pip pycurl r-base r-essentials \
      nodejs configurable-http-proxy && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/anaconda.sh
ENV PATH=/opt/conda/bin:$PATH 

ADD . /src/jupyterhub
WORKDIR /src/jupyterhub

RUN pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN mkdir -p /srv/jupyterhub/

RUN jupyterhub --generate-config -f /srv/jupyterhub/jupyterhub_config.py && \
    cat /srv/jupyterhub/jupyterhub_config.py | sed 's/#c.Authenticator.admin_users = set()/c.Authenticator.admin_users = {"xfu"}/' > tmp && \
    mv tmp /srv/jupyterhub/jupyterhub_config.py && \
    useradd -m -d /srv/jupyterhub/xfu xfu && echo 'xfu:123456' | chpasswd 

WORKDIR /srv/jupyterhub/
EXPOSE 8000 

LABEL org.jupyter.service="jupyterhub"

CMD ["jupyterhub"]
