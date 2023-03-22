---
layout: post
title: Kubernetes Ingress
categories: kubernetes
tags: ingress
---

### Ingress 简介

---

Ingress(入口)
[Ingress][1]{:target="_blank"} 是 Kubernetes 中的一个 API 接口对象，用于管理对集群中服务的外部访问，通常是 HTTP。

Ingress 暴露从群集外部到群集内服务的HTTP和HTTPS路由接口，流量的路由规则由Ingress定义。

`Ingress controller`负责实现`Ingress`接口，通常也实现了负载均衡的功能。常见的`Ingress controller`有很多，详见：[https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/][2]{:target="_blank"}。使用Ingress之前需要部署一个Ingress控制器，例如ingress-nginx。

您可以通过创建规则集来配置访问权限，这些规则定义了哪些入站连接可以访问哪些服务。
这使您可以将路由规则整合到一个资源中。例如，您可能希望将对example.com/foo/的请求发送到service1服务，而对example.com/bar/的请求发送到service2服务。
使用Ingress，您可以轻松地进行设置，而无需创建一堆LoadBalancers或在Node上公开每个服务。

![kubernetes-ingress](/assets/img/kubernetes-ingress.png){:width="100%"}

---

### NGINX Ingress Controller

---

1.通过yaml文件安装

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.0/deploy/static/provider/cloud/deploy.yaml
```

2.通过Helm工具安装，详见官方安装指引：[https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx][3]{:targe="_blank"}。

注意⚠️：Helm 官方仓库`https://charts.helm.sh/stable`中的 Chart `stable/nginx-ingress`已经废弃。

请使用`https://kubernetes.github.io/ingress-nginx`仓库中的 Chart `ingress-nginx/ingress-nginx`。

```shell
# Get Repo Info
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo add stable https://charts.helm.sh/stable
$ helm repo update

# Search Chart
$ helm search repo ingress

NAME                           	CHART VERSION	APP VERSION	DESCRIPTION
ingress-nginx/ingress-nginx    	3.9.0        	0.41.0     	Ingress controller for Kubernetes using NGINX a...
stable/nginx-ingress           	1.41.3       	v0.34.1    	DEPRECATED! An nginx Ingress controller that us...

# Install Chart (Helm 3)
$ helm install ingress-nginx ingress-nginx/ingress-nginx
```

3.常见的安装问题

```shell
# 。
$ kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS             RESTARTS   AGE
ingress-nginx-admission-create-t8fn9        0/1     Completed          0          88s
ingress-nginx-admission-patch-zcptf         0/1     Completed          1          88s
ingress-nginx-controller-85b8d88cf5-wfwsj   0/1     ImagePullBackOff   0          88s

# 问题：查看Pod状态为`ImagePullBackOff`，采用退避算法重试拉取镜像。进一步查看 Pod 异常的原因，发现拉取镜像`k8s.gcr.io/ingress-nginx/controller:v0.41.0`失败。
# 解决：gcr.io的源镜像无法拉取，考虑在海外拉取镜像`k8s.gcr.io/ingress-nginx/controller:v0.41.0`后上传 DockerHub 做 Mirror。然后修改 deployment 中的镜像地址。
$ kubectl describe pod ingress-nginx-controller-85b8d88cf5-s44pg -n ingress-nginx

Name:         ingress-nginx-controller-85b8d88cf5-s44pg
Namespace:    ingress-nginx
Priority:     0
Node:         docker-desktop/192.168.65.3
Start Time:   Wed, 11 Nov 2020 12:28:09 +0800
Labels:       app.kubernetes.io/component=controller
              app.kubernetes.io/instance=ingress-nginx
              app.kubernetes.io/name=ingress-nginx
              pod-template-hash=85b8d88cf5
Annotations:  <none>
Status:       Pending
IP:           10.1.0.136
IPs:
  IP:           10.1.0.136
Controlled By:  ReplicaSet/ingress-nginx-controller-85b8d88cf5
Containers:
  controller:
    Container ID:
    Image:         k8s.gcr.io/ingress-nginx/controller:v0.41.0@sha256:e6019e536cfb921afb99408d5292fa88b017c49dd29d05fc8dbc456aa770d590
    Image ID:
    Ports:         80/TCP, 443/TCP, 8443/TCP
    Host Ports:    0/TCP, 0/TCP, 0/TCP
    Args:
      /nginx-ingress-controller
      --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
      --election-id=ingress-controller-leader
      --ingress-class=nginx
      --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
      --validating-webhook=:8443
      --validating-webhook-certificate=/usr/local/certificates/cert
      --validating-webhook-key=/usr/local/certificates/key
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Requests:
      cpu:      100m
      memory:   90Mi
    Liveness:   http-get http://:10254/healthz delay=10s timeout=1s period=10s #success=1 #failure=5
    Readiness:  http-get http://:10254/healthz delay=10s timeout=1s period=10s #success=1 #failure=3
    Environment:
      POD_NAME:       ingress-nginx-controller-85b8d88cf5-s44pg (v1:metadata.name)
      POD_NAMESPACE:  ingress-nginx (v1:metadata.namespace)
      LD_PRELOAD:     /usr/local/lib/libmimalloc.so
    Mounts:
      /usr/local/certificates/ from webhook-cert (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from ingress-nginx-token-5knns (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  webhook-cert:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  ingress-nginx-admission
    Optional:    false
  ingress-nginx-token-5knns:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  ingress-nginx-token-5knns
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  kubernetes.io/os=linux
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason       Age                    From               Message
  ----     ------       ----                   ----               -------
  Normal   Scheduled    5m48s                  default-scheduler  Successfully assigned ingress-nginx/ingress-nginx-controller-85b8d88cf5-s44pg to docker-desktop
  Warning  FailedMount  5m17s (x7 over 5m49s)  kubelet            MountVolume.SetUp failed for volume "webhook-cert" : secret "ingress-nginx-admission" not found
  Normal   Pulling      3m36s (x3 over 4m44s)  kubelet            Pulling image "k8s.gcr.io/ingress-nginx/controller:v0.41.0@sha256:e6019e536cfb921afb99408d5292fa88b017c49dd29d05fc8dbc456aa770d590"
  Warning  Failed       3m21s (x3 over 4m28s)  kubelet            Error: ErrImagePull
  Normal   BackOff      2m54s (x4 over 4m28s)  kubelet            Back-off pulling image "k8s.gcr.io/ingress-nginx/controller:v0.41.0@sha256:e6019e536cfb921afb99408d5292fa88b017c49dd29d05fc8dbc456aa770d590"
  Warning  Failed       2m41s (x5 over 4m28s)  kubelet            Error: ImagePullBackOff
  Warning  Failed       35s (x5 over 4m28s)    kubelet            Failed to pull image "k8s.gcr.io/ingress-nginx/controller:v0.41.0@sha256:e6019e536cfb921afb99408d5292fa88b017c49dd29d05fc8dbc456aa770d590": rpc error: code = Unknown desc = Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

---

### 卸载 Ingress Controller

---

```shell
# Delete the ingress-nginx namespace to uninstall the Ingress controller along with all the auxiliary resources that were created:
$ kubectl delete namespace ingress-nginx

# Delete the ClusterRole and ClusterRoleBinding created in that step:
$ kubectl delete clusterrole ingress-nginx
$ kubectl delete clusterrolebinding ingress-nginx
```

---

### Ingress 规则配置

---

```shell
$ kubectl apply -f ingress.yml
ingress.networking.k8s.io/example-ingress created

$ kubectl get ingress
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME              CLASS    HOSTS   ADDRESS     PORTS   AGE
example-ingress   <none>   *       localhost   80      42m

$ kubectl delete ingress example-ingress
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.extensions "example-ingress" deleted
```

### 参考资料

* [https://kubernetes.io/docs/concepts/services-networking/ingress/][1]{:target="_blank"}

[1]:https://kubernetes.io/docs/concepts/services-networking/ingress/
[2]:https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
[3]:https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
