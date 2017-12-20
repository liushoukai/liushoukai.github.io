### 问题描述
由于服务器235故障，导致部署在235的Redis数据库无法使用，临时将域名redis235.xxx.com解析到232上的Redis数据库。
在服务器235恢复后，重新将域名redis235.xxx.com解析回235上的Redis数据库，发现Resin上的应用程序仍然在读写232上的Redis。

### 问题原因
由于InetAddress解析redis235.xxx.com域名到232后，缓存了域名的解析结果，导致重新解析域名到235时，出现上述的问题。
虽然Resin配置中存在<jvm-arg>-Dnetworkaddress.cache.ttl=600</jvm-arg>，但是由于networkaddress.cache.ttl不属于系统属性，
因而这样的设置是无效的。

#### InetAddress缓存机制
java.net.InetAddress有一个缓存用于存储解析成功与解析失败的域名。默认情况下：
- 如果已安装Security Manager服务，为了防止DNS欺骗攻击，解析成功的域名结果将被永久缓存。
- 如果未安装Security Manager服务，域名解析的结果将会被缓存一段时间。域名解析失败的结果将被缓存很短的时间（默认为：10秒）以提高性能。

以下两个Java安全属性控制用于主机名解析结果缓存的TTL值：
- networkaddress.cache.ttl
代表域名解析成功后对解析结果的缓存时间，类型为整数，单位为秒数。
其中，-1表示永久缓存。通过sun.net.InetAddressCachePolicy.get()查看。

- networkaddress.cache.negative.ttl (default: 10)
代表域名解析失败后对解析结果的缓存时间，类型为整数，单位为秒数。
其中，0表示从不缓存；-1表示永久缓存。通过sun.net.InetAddressCachePolicy.getNegative()查看。

#### 设置InetAddress缓存TTL
因为networkaddress.cache.ttl不属于System中的属性，而是Security中的属性。
所以通过-Dnetworkaddress.cache.ttl=600以及System.setProperty("networkaddress.cache.ttl", 600)进行设置都是无效的，
如果想通过系统属性（-D或System.setProerty）指定networkaddress.cache.ttl参数，有以下两种方式：
1、-Dsun.net.inetaddr.ttl=600
2、java.security.Security.setProperty("networkaddress.cache.ttl" , "600")
3、修改$JRE_HOME/lib/security/java.security文件中的networkaddress.cache.ttl配置
注意：Security.setProperty必须要在所有代码前执行，即存在Resin、Tomcat服务器本身先使用Java networking stack初始化，
然后才执行部署的应用程序代码，导致应用程序代码中的Security.setProperty设置无法生效。

### 解决方案
1、修改Resin配置为：<jvm-arg>-Dsun.net.inetaddr.ttl=600</jvm-arg>
2、重启缓存服务

### 后续思考
1、如何查看InetAddress中缓存的DNS信息？
```java
private static void printDNSCache(String cacheName) throws Exception {
    Class<InetAddress> klass = InetAddress.class;
    Field acf = klass.getDeclaredField(cacheName);
    acf.setAccessible(true);
    Object addressCache = acf.get(null);
    Class cacheKlass = addressCache.getClass();
    Field cf = cacheKlass.getDeclaredField("cache");
    cf.setAccessible(true);
    Map<String, Object> cache = (Map<String, Object>) cf.get(addressCache);
    for (Map.Entry<String, Object> hi : cache.entrySet()) {
        Object cacheEntry = hi.getValue();
        Class cacheEntryKlass = cacheEntry.getClass();
        Field expf = cacheEntryKlass.getDeclaredField("expiration");
        expf.setAccessible(true);
        long expires = (Long) expf.get(cacheEntry);

        Field af = cacheEntryKlass.getDeclaredField("address");
        af.setAccessible(true);
        InetAddress[] addresses = (InetAddress[]) af.get(cacheEntry);
        List<String> ads = new ArrayList<String>(addresses.length);
        for (InetAddress address : addresses) {
            ads.add(address.getHostAddress());
        }

        System.out.println(hi.getKey() + " "+new Date(expires) +" " +ads);
    }
}
```

2、如何刷新InetAddress中缓存的DNS信息？


#### 参考资料
[https://stackoverflow.com/questions/1835421/java-dns-cache-viewer](https://stackoverflow.com/questions/1835421/java-dns-cache-viewer)
[https://stackoverflow.com/questions/1256556/any-way-to-make-java-honor-the-dns-caching-timeout-ttl](https://stackoverflow.com/questions/1256556/any-way-to-make-java-honor-the-dns-caching-timeout-ttl)
