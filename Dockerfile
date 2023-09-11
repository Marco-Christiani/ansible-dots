FROM ubuntu:focal AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y software-properties-common curl git build-essential && \
  apt-add-repository -y ppa:ansible/ansible && \
  apt-get update && \
  apt-get install -y curl git ansible build-essential && \
  apt-get clean autoclean && \
  apt-get autoremove --yes

RUN apt-get install -y sudo

# Create user and group
RUN addgroup --gid 1000 theprimeagen \
  && adduser --gecos theprimeagen --uid 1000 --gid 1000 --disabled-password theprimeagen \
  # Set a password (e.g., 'password') for the user
  && echo "theprimeagen:password" | chpasswd \
  # Add the user to sudo group
  && usermod -aG sudo theprimeagen \
  # (Optional) Allow the user to run sudo without password (comment out if not desired)
  && echo "theprimeagen ALL=NOPASSWD: ALL" > /etc/sudoers.d/theprimeagen \
  && chmod 0440 /etc/sudoers.d/theprimeagen

ARG TAGS
USER theprimeagen
ENV USER=theprimeagen

WORKDIR /home/theprimeagen
COPY . .

# .local/ is standard on real/desktop but not docker
RUN mkdir -p /home/theprimeagen/.local/bin
ENV ANSIBLE_PASSWORD_FILE=pass.txt

# CMD ["sh", "-c", "ansible-playbook $TAGS setup.yml"]
CMD ["bash", "-c", "ansible-playbook setup.yml -i localhost"]
