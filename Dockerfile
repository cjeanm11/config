# docker build --build-arg TAGS="0.1" -t setup . && docker run -it --rm setup
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    software-properties-common \
    curl \
    git \
    zsh \
    sudo \
    build-essential \
    && apt-add-repository -y ppa:ansible/ansible \
    && apt install -y ansible \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin

COPY ansible/*.yml /usr/local/bin/
COPY .vimrc /root
COPY .config/ /root/.config
COPY .zsh_profile /root
COPY .zshrc /root
COPY .tmux.conf /root
COPY .bashrc /root

RUN ansible-playbook init.yml

CMD ["zsh"]
