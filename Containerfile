FROM registry.redhat.io/rhel9/rhel-bootc:latest
RUN dnf -y install microshift python && dnf clean all
# COPY hp-user.conf /usr/lib/sysusers.d
