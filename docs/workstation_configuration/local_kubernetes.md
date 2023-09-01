---
title: Local Kubernetes Environment - Kind
authors:
    - McKraken
date: 21-Mar-2023
version: 0.1
mck:
    py_version: v3.11
tags:
    - kind
    - k8s
---

## Prerequisites for a Local Cluster with Kind

### Install Docker Engine for the Container Runtime

I ran into an Ubuntu packaging [bug](https://bugs.launchpad.net/ubuntu/+source/docker.io/+bug/2029564) (also listed [here](https://github.com/moby/moby/issues/46161)) so recommend that the source Docker repo is used.  

!!! Note
    The following steps are excerpted from [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

1. Remove the Ubuntu packages:

    ```bash
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

    ```

2. Set up HTTPS transport, add Docker's GPG key, set up the Docker `apt` repository:

    ```bash
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    ```

    ```bash
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    ```

    ```bash
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

3. Install Docker Engine

    ```bash
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

4. Set up to use it as a non-root user by adding the user to the `docker` group.
5. Make sure the `docker` and `containerd` services are running and enabled on boot.
6. Test installation with `docker run hello-world`

### Install kubectl

!!! Note
    The following steps are excerpted from [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management)

1. Set up HTTPS transport, add Docker's GPG key, set up the Docker `apt` repository:

    ```bash
    sudo apt-get update
    # apt-transport-https may be a dummy package; if so, you can skip that package
    sudo apt-get install -y apt-transport-https ca-certificates curl
    ```

    ```bash
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    ```

    ```bash
    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    ```

2. Update `apt` package index, then install kubectl:

    ```bash
    sudo apt-get update
    sudo apt-get install -y kubectl
    ```

### Install Kind

For Linux, `kind` is best installed through [Release Binaries on Github](https://github.com/kubernetes-sigs/kind/releases)

The latest version can be installed through:

```bash
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

or downloaded from the [release page](https://github.com/kubernetes-sigs/kind/releases), checked against the sha256sum file, made executable (`chmod +x ./kind`) and put in the path (`sudo mv ./kind /usr/local/bin/kind`)

## Use Kind to create your K8 cluster

Run the below:

```bash
kind create cluster
```

To see your cluster information run:

```bash
kubectl cluster-info --context kind-kind
```

### Use Kind to create a K8 cluster with multiple nodes

Save the below to a file named `kind.config`

```yaml
# this config file contains all config fields with comments
# NOTE: this is not a particularly useful config file
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# patch the generated kubeadm config with some extra settings
kubeadmConfigPatches:
- |
  apiVersion: kubelet.config.k8s.io/v1beta1
  kind: KubeletConfiguration
  evictionHard:
    nodefs.available: "0%"
# patch it further using a JSON 6902 patch
kubeadmConfigPatchesJSON6902:
- group: kubeadm.k8s.io
  version: v1beta3
  kind: ClusterConfiguration
  patch: |
    - op: add
      path: /apiServer/certSANs/-
      value: my-hostname
# 1 control plane node and 3 workers
nodes:
# the control plane node config
- role: control-plane
# the three workers
- role: worker
- role: worker
- role: worker
```

Run the below referencing your `kind.config`

```bash
kind create cluster --config '.\Documents\Kind\kind.config'
```

Now when you run get nodes you can see a control-plane and 3 worker nodes

```bash
kubectl get nodes --context kind-kind
```

![kind2](../../assets/images/kind2.png "kind2.png")
