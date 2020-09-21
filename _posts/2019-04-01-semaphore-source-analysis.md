---
layout: post
title: Semaphore源码分析
categories: jdk
tags: java
---

### 基础解释

Semaphore也叫信号量，在JDK1.5被引入，可以用来控制同时访问特定资源的线程数量，通过协调各个线程，以保证合理的使用资源。
`注意：Semaphore 限制了并发访问的数量而不是使用速率。`

- Semaphore内部维护了一组虚拟的许可，许可的数量可以通过构造函数的参数指定。
- 访问特定资源前，必须使用acquire方法获得许可，如果许可数量为0，该线程则一直阻塞，直到有可用许可。访问资源后，使用release释放许可。

### 应用场景

比如，通过多线程读取远端数据源实现信息采集，为防止采集线程过多对远端数据源造成压力，所以要限制采集任务的并发执行线程数量，可以通过使用Semaphore信号量实现；

### 源码分析

```java
public Semaphore(int permits) {
    sync = new NonfairSync(permits);
}

public Semaphore(int permits, boolean fair) {
    sync = fair ? new FairSync(permits) : new NonfairSync(permits);
}
```

Semaphore通过构造方法指定permits许可数量，默认使用非公平策略的Sync实现NonfairSync；

```java
/**
 * Synchronization implementation for semaphore.  Uses AQS state
 * to represent permits. Subclassed into fair and nonfair
 * versions.
 */
abstract static class Sync extends AbstractQueuedSynchronizer {...}

/**
 * NonFair version
 */
static final class NonfairSync extends Sync {
    ...
    protected int tryAcquireShared(int acquires) {
        return nonfairTryAcquireShared(acquires);
    }
    ...
}

/**
 * Fair version
 */
static final class FairSync extends Sync {
    ...
    protected int tryAcquireShared(int acquires) {
    for (;;) {
        if (hasQueuedPredecessors())
            return -1;
        int available = getState();
        int remaining = available - acquires;
        if (remaining < 0 || compareAndSetState(available, remaining))
            return remaining;
        }
    }
    ...
}
```

Sync是什么？Sync是Semaphore的内部抽象类，Sync是继承了AQS（AbstractQueuedSynchronizer）同步器的抽象实现，AQS是java.util.concurrent提供的基础同步框架。在Doug Lea的论文《[The java.util.concurrent Synchronizer Framework](http://gee.cs.oswego.edu/dl/papers/aqs.pdf)》中，对AQS同步框架的进行了详细的描述。AQS同步器的基本功能至少包含两点：

- 获取同步状态：如果允许，则获取锁，如果不允许就阻塞线程，直到同步状态允许获取。
- 释放同步状态：修改同步状态，并且唤醒等待线程。

NonfairSync与FairSync都是Sync抽象类的具体实现，核心区别在于二者不同的tryAcquireShared实现，其中，

FairSync通过hasQueuedPredecessors()方法检查在AQS队列中是否存在等待获取Permit的线程，如果存在，则返回-1，将获取Permit的机会让给AQS队列中等待的线程，直到AQS队列的中无等待获取Permits的线程，当前线程才有机会获取Permit；

那么，AQS中的线程是怎么入队出队的呢？由于线程调用Semaphore的acquire()方法时，如果没有获取到Permit会被阻塞。因此，很直观的想法是，会在调用acquire()方法时，将无法获取到Permit的线程入队到AQS；

```java
public void acquire(int permits) throws InterruptedException {
    if (permits < 0) throw new IllegalArgumentException();
    sync.acquireSharedInterruptibly(permits);
}

public final void acquireSharedInterruptibly(int arg) throws InterruptedException {
    if (Thread.interrupted()) throw new InterruptedException();
    if (tryAcquireShared(arg) < 0) doAcquireSharedInterruptibly(arg);
}

private void doAcquireSharedInterruptibly(int arg) throws InterruptedException {
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        for (;;) {
            final Node p = node.predecessor();
            if (p == head) {
                int r = tryAcquireShared(arg);
                if (r >= 0) {
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    failed = false;
                    return;
                }
            }
            if (shouldParkAfterFailedAcquire(p, node) && parkAndCheckInterrupt())
                throw new InterruptedException();
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}

private Node addWaiter(Node mode) {
    Node node = new Node(Thread.currentThread(), mode);
    // Try the fast path of enq; backup to full enq on failure
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    enq(node);
    return node;
}
```

通过Semaphore的acquire()调用的源码，可以看到在doAcquireSharedInterruptibly()方法中，通过addWaiter(Node mode)方法为当前线程创建一个Node，然后开始尝试获取Permit，如果获取成功，则将Node设置为null，利用GC回收分配的内存；如果获取失败，则将Node加入AQS队列中；

那么，什么是Node的mode呢？

```java
static final class Node {
    /** Marker to indicate a node is waiting in shared mode */
    static final Node SHARED = new Node();
    /** Marker to indicate a node is waiting in exclusive mode */
    static final Node EXCLUSIVE = null;
    ...
}
```

首先，Node是AQS的内部类，AQS队列采用链表实现，Node为AQS队列的节点；Node存在Shared模式与Exclusive模式；具体的使用说明，会在AbstractQueuedSynchronizer的源码分析中叙述
