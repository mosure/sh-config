FROM nvidia/cuda:11.2.2-runtime-ubuntu20.04

RUN apt-get -y update
RUN apt-get -y upgrade

ARG USER_GID=1000
ARG USER_UID=1000
ARG USERNAME=mosure

ENV TERM=xterm-256color

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get -y install sudo wget git zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME


# Install ZSH + theme
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./.powerlevel10k

COPY .p10k.zsh .
COPY .zshrc .

RUN /bin/zsh


# Install bazel
RUN sudo apt-get -y install apt-transport-https curl gnupg
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
RUN sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

RUN sudo apt-get -y update && sudo apt-get -y install bazel g++ unzip zip


RUN sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

CMD ["/bin/zsh"]
