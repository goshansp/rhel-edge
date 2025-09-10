# Scope
How to build RHEL9 Edge with Microshift to push to Quay. Build Env is RHEL9 (see infrastructure.git/scripts/README.md) because subscription entitlements needed. At the time of writing there is no Microshift for RHEL10.

# Next
1. Create image
1. Add Microshift
1. Push to Quay
1. Build on Quay
1. Create molecule scenario rhel-edge?


# Creating RHEL Edge Image (On RHEL9)
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/building-and-testing-rhel-bootc-images
```
$ sudo dnf install podman
# https://access.redhat.com/terms-based-registry/ ... get the token.
$ mkdir ~/.config/; mkdir ~/.config/containers; vi ~/.config/containers/auth.json
$ podman login registry.redhat.io

$ podman build -t quay.io/rh_ee_hgosteli/rhel-edge:latest .

$ podman build \
  --volume /etc/yum.repos.d:/etc/yum.repos.d:ro \
  --volume /etc/pki/entitlement:/etc/pki/entitlement:ro \
  --volume /etc/rhsm:/etc/rhsm:ro \
  -t quay.io/rh_ee_hgosteli/rhel-edge:latest .


$ podman push quay.io/rh_ee_hgosteli/rhel-edge:latest

```
