ARG FROM_KIND_IMAGE=kindest/node:latest
FROM ${FROM_KIND_IMAGE}

ARG CRIO_VERSION=v1.33
ARG KUBERNETES_VERSION=v1.33
# ARG CRIO_PROJECT_PATH=prerelease:/$CRIO_VERSION
ARG CRIO_PROJECT_PATH=stable:/$CRIO_VERSION

RUN echo "Installing Packages ..." \
    && apt-get clean \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common vim gnupg

RUN echo "setting up repos according to cri-o website..."

# should not be needed since this is from a FROM_KIND_IMAGE
# RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

RUN curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/$CRIO_PROJECT_PATH/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/$CRIO_PROJECT_PATH/deb/ /" | tee /etc/apt/sources.list.d/cri-o.list
RUN apt-get update -y

RUN echo "Installing cio-o" \
     && DEBIAN_FRONTEND=noninteractive apt-get --option=Dpkg::Options::=--force-confdef install -y cri-o 
 
RUN echo "Enabling CRIO ..." \
     && sed -i 's/containerd/crio/g' /etc/crictl.yaml \ 
     && rm -f /var/run/crio/crio.sock \
     && systemctl disable containerd \
     && systemctl enable crio
