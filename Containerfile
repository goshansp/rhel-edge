FROM registry.redhat.io/rhel9/rhel-bootc:latest
RUN dnf -y install firewalld microshift microshift-gitops python && dnf clean all
COPY hp-user.conf /usr/lib/sysusers.d/hp-user.conf
COPY hp-ssh.conf /usr/lib/tmpfiles.d/hp-ssh.conf
COPY 99-hp /etc/sudoers.d/99-hp
COPY hp-authorized_keys.conf /usr/lib/tmpfiles.d/hp-authorized-keys.conf

# FYI: Disabled Microshift because it's killing greenboot without it's secrets
# RUN systemctl enable microshift.service

