FROM python:3.6-slim-stretch

## Change from sh to bash
RUN ls -al /bin/sh \
	&& rm /bin/sh \
	&& ln -sf /bin/bash /bin/sh

# ??
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install deps
RUN apt-get update \
  && apt-get install -y unzip build-essential gcc git curl grep dpkg sed vim python wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 mercurial

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD python/requirements.txt /opt/requirements.txt

WORKDIR /opt/snorkel

RUN cd /opt/ \
	&& ls -alh /opt \
	&& git clone https://github.com/HazyResearch/snorkel.git \
	&& cd snorkel \
	&& git submodule update --init --recursive 

RUN cd /opt/ \
	&& pip install -r requirements.txt

RUN rm -rf /opt/snorkel/.git

# Install Python library for Data Science
RUN pip --no-cache-dir install \
	 jupyter \
 	 ipykernel \
     	 vaderSentiment \
         && \
         python -m ipykernel.kernelspec

# Set up Jupyter Notebook config
ENV CONFIG /root/.jupyter/jupyter_notebook_config.py
ENV CONFIG_IPYTHON /root/.ipython/profile_default/ipython_config.py 

RUN jupyter notebook --generate-config --allow-root && \
    ipython profile create

RUN echo "c.NotebookApp.ip = '0.0.0.0'" >>${CONFIG} && \
    echo "c.NotebookApp.port = 8888" >>${CONFIG} && \
    echo "c.NotebookApp.open_browser = False" >>${CONFIG} && \
    echo "c.NotebookApp.iopub_data_rate_limit=10000000000" >>${CONFIG} && \
    echo "c.MultiKernelManager.default_kernel_name = 'python3'" >>${CONFIG} 

RUN echo "c.InteractiveShellApp.exec_lines = ['%matplotlib inline']" >>${CONFIG_IPYTHON} 

# Copy sample notebooks.
#COPY notebooks /notebooks

# Port
EXPOSE 8888

VOLUME /root/bdso

# Run Jupyter Notebook
WORKDIR "/root/bdso"
CMD ["jupyter","notebook", "--allow-root"]

