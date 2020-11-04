---
layout: post
title: Docker Desktop 启用 Kubernetes
categories: kubernetes
tags: docker kubernetes docker-desktop
---

### Docker Desktop 支持 Kubernetes 的意义

使用 Docker 构建容器化应用程序，并将其部署到同一Docker实例的Kubernetes上。

### 阿里云容器服务教程

[https://github.com/AliyunContainerService/k8s-for-docker-desktop][1]{:target="_blank"}

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

```shell
# 查看 Kubernetes 版本信息
kubectl version

# 查看 Kubernetes 集群信息
kubectl cluster-info

# 安装 Kubernetes dashboard 管理面板
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml

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

[1]:https://github.com/AliyunContainerService/k8s-for-docker-desktop/
[2]:https://www.ipaddress.com/
