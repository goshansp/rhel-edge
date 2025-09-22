# Scope
How to build RHEL9 Edge with Microshift to push to Quay. Build Env is RHEL9 (see infrastructure.git/scripts/README.md) because subscription entitlements needed. At the time of writing there is no GA Microshift for RHEL10.


# WIP
1. Tailscale
1. Fix partition order raw/metal, so p4 is at the end ... currently creates p3 after p4 and its a pain to resize p4 100%
1. Update from previous Image ...
1. Done: Deploy to metal (ansible_role_router.git)
1. Create and Publish Update
1. Host the image raw/qcow2 on a tailscaled/http server (pxe nginx)


# WIP: Upgrade Process
1. Preliminary: Step 1 from `Initial Image Creation and Deployment Process`
1. TODO: Base Upgrade on previous image ... How to version?
1. Push to Quay
1. Ensure repo is public (Robot Account on 17.09.2025 was unable to authenticate)
1. On the target `sudo bootc upgrade`


# TODO: Partitioning
Root is always last on the PV. This is why the VG (p4) is sector-wise before root (p3) and we cannot resize it. Can we put root on LV without consuming the entire VG?

https://osbuild.org/docs/user-guide/partitioning/


# Initial Image Creation and Deployment Process

## Step 2b: Create .raw.xz Image Deploy to Metal
1. Create .raw.xz
```
$ sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./config.raw.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    registry.redhat.io/rhel10/bootc-image-builder:latest \
    --type raw \
    --config /config.toml \
  quay.io/rh_ee_hgosteli/rhel-edge:latest
$ sudo xz -T0 -9 -k output/image/disk.raw
$ exit
$ scp rhel9:./git/rhel-edge/output/image/disk.raw.xz .
$ python3 -m http.server 8000
```
1. Boot USB Coreos installer
```
# Only for re-deploy:
$ sudo vgremove -ff root-vg

$ sudo coreos-installer install /dev/nvme0n1 --image-url http://green:8000/disk.raw.xz --insecure
$ sudo poweroff
```

## Step 2a: Build Image as .qcow2 and Boot as VM
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/creating-bootc-compatible-base-disk-images-with-bootc-image-builder_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems
```
$ ssh rhel9
$ sudo dnf install git
$ git clone git@github.com:goshansp/rhel-edge
$ sudo subscription-manager register --username rh-ee-hgosteli
$ sudo subscription-manager repos --enable rhocp-4.19-for-rhel-9-$(uname -m)-rpms --enable fast-datapath-for-rhel-9-$(uname -m)-rpms --enable gitops-1.16-for-rhel-9-$(uname -m)-rpms
$ sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
$ sudo mkdir /root/.config/; sudo mkdir /root/.config/containers; sudo vi /root/.config/containers/auth.json
$ sudo podman login registry.redhat.io
$ sudo podman login quay.io
# rh_ee_hgosteli
$ mkdir output
$ sudo podman pull quay.io/rh_ee_hgosteli/rhel-edge:latest
$ sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./config.qcow2.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    registry.redhat.io/rhel10/bootc-image-builder:latest \
    --type qcow2 \
    --config /config.toml \
  quay.io/rh_ee_hgosteli/rhel-edge:latest

$ scp rhel9:./git/rhel-edge/output/qcow2/disk.qcow2 ~/.local/molecule/images/disk.qcow2

./fire_vm.sh
```


## Step 1: Creating Bootc RHEL Edge Image (On RHEL9)
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

$ sudo podman login quay.io --authfile /etc/containers/auth.json
# rh_ee_hgosteli
$ sudo podman push quay.io/rh_ee_hgosteli/rhel-edge:latest
```

# ADR

## ADR root user
There is a `develop` user without password. It was needed because without a user sysuser would not properly comission `hp`.

## XFS vs. EXT4
Because happy path and scalability. Can not be shrinked.

## Where to put config? Blueprint vs Image
Image because blueprint only ships for installation. No Upgrade path.

## Rebase Ostree-Container
Ostree Commit and Containers seem not to allow for upgrade path as of 12.09.2025 - hence we redeploy.

## Build Env
Cannot inject subs easily on Quay, hence we build on an x86 and push to Quay.
