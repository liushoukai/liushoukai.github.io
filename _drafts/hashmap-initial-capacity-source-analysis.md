## 场景描述

最近，项目中常常见到类似下面的一段代码，即在初始化HashMap容量的时候，将插入HashMap的元素数量除以3/4（即乘以4/3），从而防止插入元素数量大于HashMap默认初始容量DEFAULT_INITIAL_CAPACITY=16对应阈值而导致的扩容；

```java
Map<Integer, MenuItem> tmpMap = new HashMap<>(menuList.size() * 4 / 3);
```

## 源码分析

查看源码发现传入的`menuList.size() * 4 / 3`被赋值给HashMap作为扩容阈值`threshold`。

```java
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                           initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                           loadFactor);

    this.loadFactor = loadFactor;
    threshold = initialCapacity;
    init();
}
```

## 处理结论

