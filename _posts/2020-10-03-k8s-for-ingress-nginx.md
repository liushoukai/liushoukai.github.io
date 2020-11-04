---
layout: post
title: Kubernetes包管理工具Helm
categories: kubernetes
tags: docker kubernetes helm
---

### ingress简介

Ingress(入口)
在Kubernetes中，Ingress是一个对象，该对象允许从Kubernetes集群外部访问Kubernetes服务。您可以通过创建规则集来配置访问权限，这些规则定义了哪些入站连接可以访问哪些服务。
这使您可以将路由规则整合到一个资源中。例如，您可能希望将对example.com/api/v1/的请求发送到api-v1服务，而对example.com/api/v2/的请求发送到api-v2服务。
使用Ingress，您可以轻松地进行设置，而无需创建一堆LoadBalancers或在Node上公开每个服务。

Kubernetes Ingress vs LoadBalancer vs NodePort
这些选项都做相同的事情。它们使您可以向外部网络请求公开服务。它们使您可以从Kubernetes集群外部向集群内部的服务发送请求。

NodePort
NodePort是您在服务的YAML中声明的配置设置。将服务规范的类型设置为NodePort。然后，Kubernetes将在每个节点上为该服务分配一个特定的端口，并且对该端口上集群的任何请求都将转发到该服务。 这很酷，很简单，但并不是超级强大。您不知道将为您的服务分配哪个端口，并且该端口可能会在某个时候重新分配。

https://kubernetes.github.io/ingress-nginx/deploy/

使用helm安装ingress-nginx

```shell
$ helm search repo ingress
NAME                           	CHART VERSION	APP VERSION	DESCRIPTION
stable/gce-ingress             	1.2.0        	1.4.0      	A GCE Ingress Controller
stable/ingressmonitorcontroller	1.0.48       	1.0.47     	IngressMonitorController chart that runs on kub...
stable/nginx-ingress           	1.41.3       	v0.34.1    	DEPRECATED! An nginx Ingress controller that us...
stable/contour                 	0.2.0        	v0.15.0    	Contour Ingress controller for Kubernetes
stable/external-dns            	1.8.0        	0.5.14     	Configure external DNS servers (AWS Route53, Go...
stable/kong                    	0.36.7       	1.4        	DEPRECATED The Cloud-Native Ingress and API-man...
stable/lamp                    	1.1.3        	7          	Modular and transparent LAMP stack chart suppor...
stable/nginx-lego              	0.3.1        	           	Chart for nginx-ingress-controller and kube-lego
stable/traefik                 	1.87.2       	1.7.24     	A Traefik based Kubernetes ingress controller w...
stable/voyager                 	3.2.4        	6.0.0      	DEPRECATED Voyager by AppsCode - Secure Ingress...
```

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.40.2/deploy/static/provider/cloud/deploy.yaml


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-release ingress-nginx/ingress-nginx