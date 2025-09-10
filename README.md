# Scope
How to build RHEL9 Edge with Microshift to push to Quay. Build Env is RHEL9 (see infrastructure.git/scripts/README.md) because subscription entitlements needed. At the time of writing there is no Microshift for RHEL10.

# Next
1. Create image
1. Add Microshift
1. Push to Quay
1. Run vm on KVM
1. (Build on Quay)
1. Create molecule scenario rhel-edge? ansible_role_template


# WIP: Create QCOW2 Image and boot the machine
```
podman create --name temp-container quay.io/rh_ee_hgosteli/rhel-edge:latest
podman export temp-container -o microshift-root.tar
qemu-img create -f qcow2 microshift.qcow2 20G

... put the stuff in ...

#!/bin/bash
virt-install \
  --memory 16000 \
  --vcpus 4 \
  --name microshift-vm \
  --disk ~/git/goshansp/rhel-edge/microshift.qcow2,device=disk,bus=virtio,format=qcow2 \
  --os-variant rhel9-unknown \
  --virt-type kvm \
  --graphics none \
  --console pty,target_type=serial \
  --import \
  --connect qemu:///session \
  --network bridge=virbr0,model=virtio \
  --noautoconsole




```


# Creating RHEL Edge Image (On RHEL9)
```
$ sudo dnf install podman
# https://access.redhat.com/terms-based-registry/ ... get the token.
$ mkdir ~/.config/; mkdir ~/.config/containers; vi ~/.config/containers/auth.json
$ podman login registry.redhat.io

$ podman build \
  --volume /etc/yum.repos.d:/etc/yum.repos.d:ro \
  --volume /etc/pki/entitlement:/etc/pki/entitlement:ro \
  --volume /etc/rhsm:/etc/rhsm:ro \
  -t quay.io/rh_ee_hgosteli/rhel-edge:latest .

$ podman login quay.io
# rh_ee_hgosteli
$ podman push quay.io/rh_ee_hgosteli/rhel-edge:latest
```
