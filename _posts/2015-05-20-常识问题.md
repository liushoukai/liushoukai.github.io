---
title:  "面试问题"
date:   2015-05-15
categories: java
---


> **Filter与Interceptor的区别**

- Filter属于Servlet API，负责动态过滤Servlet接收的HTTP请求和响应
- Interceptor属于Web Application API，负责动态拦截action请求和响应

> **Thread.start()与Thread.run()的区别**

- 调用Thread.start()方法将在新创建的线程中运行run()方法
- 调用Thread.run()方法将运行当前的线程中运行run()方法

		public class Client {
			public static void main(String[] args) throws Exception {
				long start = System.currentTimeMillis();
				Thread t1 = new Thread(new Task());
				Thread t2 = new Thread(new Task());
				//t1.start();t2.start(); //并行
				t1.run();t2.run();   //串行
				t1.join();t2.join();
				long end = System.currentTimeMillis();
				System.out.println((end - start)/1000);
			}
			
			static class Task implements Runnable {
				@Override
				public void run() {
					try {
						TimeUnit.SECONDS.sleep(3);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		}


> **Callable\Runnable区别**

- 是否有返回值
- 是否可以抛出unchecked exception
