---
title:  "Difference between KVM and LXC"
date:   2015-05-14 18:04:27
---

###Linux Containers Compared to KVM

>VirtualizationThe main difference between the KVM virtualization and Linux Containers is that virtual machines require a separate kernel instance to run on, while containers can be deployed from the host operating system. This significantly reduces the complexity of container creation and maintenance. Also, the reduced overhead lets you create a large number of containers with faster startup and shutdown speeds. Both Linux Containers and KVM virtualization have certain advantages and drawbacks that influence the use cases in which these technologies are typically applied:

### KVM virtualizationKVM

>virtualization lets you boot full operating systems of different kinds, even non-Linux systems. However, a complex setup is sometimes needed. Virtual machines are resource-intensive so you can run only a limited number of them on your host machine.
Running separate kernel instances generally means better separation and security. If one of the kernels terminates unexpectedly, it does not disable the whole system. On the other hand, this isolation makes it harder for virtual machines to communicate with the rest of the system, and therefore several interpretation mechanisms must be used.
Guest virtual machine is isolated from host changes, which lets you run different versions of the same application on the host and virtual machine. KVM also provides many useful features such as live migration. For more information on these capabilities, see Red Hat Enterprise Linux 7 Virtualization Deployment and Administration Guide.

###Linux Containers:

>The current version of Linux Containers is designed primarily to support isolation of one or more applications, with plans to implement full OS containers in the near future. You can create or destroy containers very easily and they are convenient to maintain.
System-wide changes are visible in each container. For example, if you upgrade an application on the host machine, this change will apply to all sandboxes that run instances of this application.
Since containers are lightweight, a large number of them can run simultaneously on a host machine. The theoretical maximum is 6000 containers and 12,000 bind mounts of root file system directories. Also, containers are faster to create and have low startup times.
