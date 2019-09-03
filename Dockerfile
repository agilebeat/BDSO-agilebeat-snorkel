FROM python:3.6-slim-stretch
RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    build-essential \
    git \
    wget \
    curl \
    unzip


ENTRYPOINT ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
