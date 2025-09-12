#!/bin/bash
virt-install \
  --memory 16000 \
  --vcpus 4 \
  --name microshift-vm \
  --disk ./disk.qcow2,device=disk,bus=virtio,format=qcow2 \
  --os-variant rhel9-unknown \
  --virt-type kvm \
  --graphics none \
  --console pty,target_type=serial \
  --import \
  --connect qemu:///session \
  --network bridge=virbr0,model=virtio \
  --noautoconsole
  