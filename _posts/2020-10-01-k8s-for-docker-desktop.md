---
layout: post
title: Docker Desktop 启用 Kubernetes
categories: kubernetes
tags: docker kubernetes docker-desktop
---

### Docker Desktop 简介

[Docker Desktop][4]{:target="_blank"} 是 Docker 公司推出的一款桌面应用程序，用于在本地搭建容器部署环境。

[Docker Desktop][4]{:target="_blank"} 提供对 Kubernetes 的支持，会启动一个单节点 Kubernetes 集群，并同时安装`kubectl`命令工具。

使用 [Docker Desktop][4]{:target="_blank"} 构建容器化应用程序，并将其部署到使用相同 Docker 实例的 Kuberntes 本地集群上，从而使得 Kubernetes 能够直接访问存储于 Docker 本地 Registry 的镜像。

---

### 阿里云容器服务教程

[https://github.com/AliyunContainerService/k8s-for-docker-desktop][1]{:target="_blank"}

Kubernetes 相关组建的镜像地址目前都在海外，国内无法快速拉去镜像，这个项目通过修改优先从阿里云的镜像服务器拉取镜像，然后再修改为对应的tag名称的方式，解决访问海外镜像困难的问题。

项目在`images.properties`文件中，维护了不同 Kubernetes 版本的镜像地址。

```shell
k8s.gcr.io/pause:3.2=registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
k8s.gcr.io/kube-controller-manager:v1.19.3=registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.19.3
k8s.gcr.io/kube-scheduler:v1.19.3=registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.19.3
k8s.gcr.io/kube-proxy:v1.19.3=registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.19.3
k8s.gcr.io/kube-apiserver:v1.19.3=registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.19.3
k8s.gcr.io/etcd:3.4.13-0=registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0
k8s.gcr.io/coredns:1.7.0=registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0
quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1=registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:0.26.1
```

开发者可以直接拉取`k8s-for-docker-desktop`项目，然后切换到对应 Kubernetes 版本的分支，执行`load_images.sh`脚本从阿里云拉取镜像。

```shell
#!/bin/bash

file="images.properties"

if [ -f "$file" ]
then
  echo "$file found."

  while IFS='=' read -r key value
  do
    #echo "${key}=${value}"
    docker pull ${value}
    docker tag ${value} ${key}
    docker rmi ${value}
  done < "$file"

else
  echo "$file not found."
fi
```

执行完`load_images.sh`脚本后，通过`docker images`命令可以本地的镜像。

注意⚠️：如果升级`docker-desktop`的时候，服务端存在使用旧版 API 的服务，则不会升级 Kubernetes 的服务端，要通过控制面板中`Preferences->Kubernetes`的`Reset Kubernetes Cluster`按钮重置后并自动重启 Kuberntes 集群后才会升级到最新的服务端版本。

安装完成后通过`kubectl version`命令查看。

---

### 安装问题

---

#### The connection to the server raw.githubusercontent.com was refused - did you specify the right host or port

* 原因：国内无法正确解析域名raw.githubusercontent.com的IP地址
* 解决：在[https://www.ipaddress.com/][2]{:target="_blank"}上查询域名raw.githubusercontent.com的真实IP地址为：199.232.28.133，配置IP

```shell
sudo vim /etc/hosts
199.232.28.133 raw.githubusercontent.com
```

---

#### Error: ImagePullBackOff

* 原因：创建 Pods 时需要拉取镜像，国内无法访问镜像源`us.gcr.io/k8s-artifacts-prod/ingress-nginx/controller:v0.34.1`，导致拉取镜像时报错。

```shell
Failed to pull image "us.gcr.io/k8s-artifacts-prod/ingress-nginx/controller:v0.34.1": rpc error: code = Unknown desc = Error response from daemon: Get https://us.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
Warning  Failed     5m (x118 over 35m)   kubelet, ip-10-30-46-220.cn-northwest-1.compute.internal  Error: ImagePullBackOff
Normal   BackOff    21s (x139 over 35m)  kubelet, ip-10-30-46-220.cn-northwest-1.compute.internal  Back-off pulling image "us.gcr.io/k8s-artifacts-prod/ingress-nginx/controller:v0.34.1"
```

* 解决：通过 `kubectl get deployment | grep nginx` 命令找到对应的 Deployment，替换 Deploymnet 中的镜像为阿里云提供的地址，修改成功后 k8s 会自动重新拉取镜像。

```shell
kubectl get deployment | grep nginx
kubectl edit deployment my-nginx-release-nginx-ingress-controller
us.gcr.io/k8s-artifacts-prod/ingress-nginx/controller:v0.34.1 => registry.aliyuncs.com/google_containers/nginx-ingress-controller:v0.34.1
```

---

### Kubernetes dashboard 管理面板

Kubernetes dashboard 是基于网页的 Kubernetes 用户界面。
[https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/][5]{:target="_blank"}

```shell
# 查看 Kubernetes 版本信息
kubectl version

# 查看 Kubernetes 集群信息
kubectl cluster-info

# 安装 Kubernetes dashboard 管理面板
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# 查看 Kubernetes dashboard 应用状态
kubectl get pods -n kubernetes-dashboard

# 开启 API Server 访问代理
kubectl proxy

# 通过如下 URL 访问 Kubernetes dashboard
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# 配置控制台访问令牌（对于Mac环境）
TOKEN=$(kubectl -n kube-system describe secret default | awk '$1=="token:"{print $2}')
kubectl config set-credentials docker-for-desktop --token="${TOKEN}"
echo $TOKEN

# 选择 Kubeconfig 文件
Mac: $HOME/.kube/config
Win: %UserProfile%\.kube\config

# 配置 Kubernetes dashboard 管理面板端口转发（用于直接从容器外访问管理面板）
kubectl port-forward kubernetes-dashboard-7798c48646-ctrtl 8443:8443 --namespace=kube-system
Forwarding from 127.0.0.1:8443 -> 8443

# 访问 Kubernetes dashboard 管理面板
https://localhost:8443
```

---

### 其他

```shell
kubectl -n kube-system describe secret default
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
kubectl describe pod ingress-nginx-controller-6967fb79f6-6qgvk -n ingress-nginx
```

---

### 参考资料

1. [https://github.com/AliyunContainerService/k8s-for-docker-desktop/][1]{:targe="_blank"}
2. [https://hasura.io/blog/sharing-a-local-registry-for-minikube-37c7240d0615/][3]{:targe="_blank"}

[1]:https://github.com/AliyunContainerService/k8s-for-docker-desktop/
[2]:https://www.ipaddress.com/
[3]:https://hasura.io/blog/sharing-a-local-registry-for-minikube-37c7240d0615/
[4]:https://docs.docker.com/desktop/
[5]:https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/