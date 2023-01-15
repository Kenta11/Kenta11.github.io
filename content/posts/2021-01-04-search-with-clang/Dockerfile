FROM ubuntu:20.04
LABEL maintainer "Kenta Arai <>"

COPY sample.py /sample.py

RUN apt update -y; apt dist-upgrade -y; apt autoremove -y && \
    apt install git python3 python-clang -y && \
    git clone https://github.com/vim/vim && \
    python3 sample.py vim_snprintf vim/src/main.c
