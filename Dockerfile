FROM debian:bookworm
LABEL maintainer="Michael Buluma"
LABEL build_date="2023-04-04"

ARG DEBIAN_FRONTEND=noninteractive

ENV pip_packages "ansible cryptography"

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo systemd systemd-sysv \
       build-essential wget libffi-dev libssl-dev \
       python3-pip python3-dev python3-setuptools python3-wheel python3-apt python3-full \
       iproute2 python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# create virtual env
# RUN python3 -m venv /opt/venv
# RUN . /opt/venv/bin/activate
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Remove existing ansible
# RUN pip3 uninstall ansible && pip3 uninstall ansible-base

# Upgrade pip to latest version.
RUN pip3 install --upgrade pip --break-system-packages

# Install Ansible via pip.
RUN pip3 install $pip_packages --break-system-packages

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
