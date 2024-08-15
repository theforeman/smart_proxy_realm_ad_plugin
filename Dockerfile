FROM ubuntu:22.04 

# Define package lists
ENV RUBY_PACKAGES="ruby ruby-dev gem"
ENV BUILD_TOOLS="automake autoconf gcc make libc-dev"
ENV RADCLI_DEPENDENCIES="libkrb5-dev libldap2-dev libsasl2-dev"
ENV TESTING_TOOLS="adcli krb5-user ldap-utils dnsutils ltrace strace"
ENV VERSION_CONTROL="git"
ENV NETWORK_TOOLS="iputils-ping nmap tshark"
ENV UTILITY_TOOLS="wget gnupg sudo"

# Define DNS resolver variables
ENV DNS_SERVER=192.168.3.1
ENV DNS_SEARCH=lab.local
ENV DOMAIN="lab.local"

# Preconfigure krb5-config and tshark to avoid interactive prompts
RUN echo "krb5-config krb5-config/default_realm string LAB.LOCAL" | debconf-set-selections && \
    echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# Copy the DNS setup script
COPY ./scripts/set_dns.sh /usr/local/bin/set_dns.sh
RUN chmod +x /usr/local/bin/set_dns.sh

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
    $RADCLI_DEPENDENCIES \
    $RUBY_PACKAGES \
    $BUILD_TOOLS \
    $LIBRARIES \
    $TESTING_TOOLS \
    $NETWORK_TOOLS \
    $VERSION_CONTROL \
    $UTILITY_TOOLS && \
    rm -rf /var/lib/apt/lists/*

# Install foreman-proxy nightly
RUN apt update && \
    apt install -y wget ca-certificates && \
    cd /tmp && wget https://apt.puppet.com/puppet7-release-jammy.deb && \
    apt install -y /tmp/puppet7-release-jammy.deb && \
    wget https://deb.theforeman.org/foreman.asc -O /etc/apt/trusted.gpg.d/foreman.asc && \
    echo "deb http://deb.theforeman.org/ jammy nightly" | tee /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ jammy nightly" |  tee /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins nightly" | tee -a /etc/apt/sources.list.d/foreman.list && \
    apt update -y && \
    apt upgrade -y

# Create a non-root user with sudo access
RUN groupadd -r devuser && useradd -r -g devuser -m -s /bin/bash devuser && \
    usermod -aG sudo devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the user to the newly created non-root user
USER devuser

# Set the working directory
WORKDIR /home/devuser

# Install oh-my-bash for devuser
RUN git clone https://github.com/ohmybash/oh-my-bash.git /home/devuser/.oh-my-bash && \
    cp /home/devuser/.oh-my-bash/templates/bashrc.osh-template /home/devuser/.bashrc && \
    chown -R devuser:devuser /home/devuser/.oh-my-bash /home/devuser/.bashrc

WORKDIR /app

# Set the entrypoint to the DNS setup script
ENTRYPOINT ["/usr/local/bin/set_dns.sh"]
CMD ["/bin/bash"]
