FROM registry.redhat.io/rhel9/rhel-bootc:latest
RUN dnf -y install dnsmasq firewalld microshift microshift-gitops python && dnf clean all
COPY hp-user.conf /usr/lib/sysusers.d/hp-user.conf
COPY hp-home.conf /usr/lib/tmpfiles.d/hp-home.conf
COPY 99-hp /etc/sudoers.d/99-hp
COPY authorized_keys /usr/share/ssh/authorized_keys/hp

# FYI: Disabled Microshift because it's killing greenboot without it's secrets
# RUN systemctl enable microshift.service

