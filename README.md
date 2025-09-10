# Scope
How to build RHEL10 Edge with Microshift to push to Quay. Build Env is Fedora 42 Silverblue.

# Next
1. Create image (because we can build/host in on quay)
1. Create molecule scenario rhel-edge?


# Creating RHEL Edge Image
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/building-and-testing-rhel-bootc-images
```
$ podman login registry.redhat.io
# ~/.config/containers/auth.json
# https://access.redhat.com/terms-based-registry/ 
$ podman build -t quay.io/rh_ee_hgosteli/rhel-edge:latest .

```