FROM registry.redhat.io/rhel9/rhel-bootc:latest
RUN dnf -y install firewalld microshift microshift-gitops python && dnf clean all
# COPY hp-user.conf /usr/lib/sysusers.d
RUN systemctl enable microshift.service

