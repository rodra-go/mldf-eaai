FROM nvidia/cuda:11.8.0-base-ubuntu22.04

RUN apt-get update

RUN apt-get install bash -y
RUN apt-get install sudo -y
RUN apt-get install git -y

# Install Python 3.8.5 from source
RUN export LC_ALL=C.UTF-8
RUN export LANG=C.UTF-8

RUN apt-get install -y \
    build-essential \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    wget \
    zlib1g-dev \
    liblzma-dev

RUN wget https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz
RUN tar -xf Python-3.8.5.tgz
RUN cd Python-3.8.5 && \
    ./configure --enable-optimizations && \
    make -j 8 && \
    make install

ENV GROUP_ID=1000 \
    USER_ID=1000 \
    USERNAME=user01 \
    PASSWORD=pass

RUN addgroup --gid $GROUP_ID $USERNAME
RUN adduser --uid $USER_ID \
    --ingroup $USERNAME \
    --shell /bin/bash \
    --disabled-password \
    --gecos "" $USERNAME
RUN usermod -aG 100 $USERNAME
RUN usermod -aG sudo $USERNAME
RUN echo "$USERNAME:$PASSWORD" | chpasswd

ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
ENV PATH="/usr/local/bin/:${PATH}"

RUN python3 -m pip install --upgrade pip setuptools

USER $USERNAME
RUN python3 -m pip install --no-warn-script-location \
        kedro==0.18.3 \
        kedro-viz==5.1.1 \
        kedro-mlflow==0.11.4 \
        dask[complete]==2022.10.2 \
        dask-ml[complete]==2022.5.27 \
        pyarrow==10.0.0 \
        gdown==4.5.1

COPY --chown=$USER_ID:$GROUP_ID . /usr/src/code
WORKDIR /usr/src/code
RUN if [ -f "pyproject.toml" ] ; then \
    pip install -r src/requirements.txt ; fi


EXPOSE 8888
EXPOSE 5000
EXPOSE 8787
EXPOSE 4141