# Scope
How to build RHEL9 Edge with Microshift to push to Quay. Build Env is RHEL9 (see infrastructure.git/scripts/README.md) because subscription entitlements needed. At the time of writing there is no Microshift for RHEL10.


# Next
1. (Build on Quay)
1. Meet Microshift Requirements (LVM,... infrastructure.git/scripts/microsdhift.md)
1. Create molecule scenario rhel-edge? ansible_role_template


# WIP: Step 2:Create QCOW2 Image from Container
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/creating-bootc-compatible-base-disk-images-with-bootc-image-builder_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems
```
$ ssh rhel9
$ sudo subscription-manager register --username rh-ee-hgosteli
$ sudo subscription-manager repos --enable rhocp-4.19-for-rhel-9-$(uname -m)-rpms --enable fast-datapath-for-rhel-9-$(uname -m)-rpms
$ sudo mkdir /root/.config/; sudo mkdir /root/.config/containers; sudo vi /root/.config/containers/auth.json
$ sudo podman login registry.redhat.io
$ mkdir output
$ sudo podman pull quay.io/rh_ee_hgosteli/rhel-edge:latest
$ sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./config.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    registry.redhat.io/rhel10/bootc-image-builder:latest \
    --type qcow2 \
    --config /config.toml \
  quay.io/rh_ee_hgosteli/rhel-edge:latest
$ scp rhel9:./output/qcow2/disk.qcow2 .

./fire_vm.sh
```


# Step 1: Creating Bootc RHEL Edge Image (On RHEL9)
```
$ sudo dnf install podman
# https://access.redhat.com/terms-based-registry/token/hgosteli/docker-config ... auth.json
$ mkdir ~/.config/; mkdir ~/.config/containers; vi ~/.config/containers/auth.json
$ podman login registry.redhat.io

$ sudo podman build \
  --volume /etc/yum.repos.d:/etc/yum.repos.d:z \
  --volume /etc/pki/entitlement:/etc/pki/entitlement:z \
  --volume /etc/rhsm:/etc/rhsm:z \
  -t quay.io/rh_ee_hgosteli/rhel-edge:latest .

$ sudo podman login quay.io
# rh_ee_hgosteli
$ sudo podman push quay.io/rh_ee_hgosteli/rhel-edge:latest
```
