---
layout: post
title: Rust 学习笔记
categories: language
tags: rust
---

Tokio异步运行时，rust目前最流行，最有名气的异步库。
axun，Tokio系旗下的web框架，这次就是要体验一下Tokio全家桶
sqlx 异步数据库框架,并不是orm框架那种，没有DSL，用户自己编写sql语句，将查询结果按列取出或映射到struct上
once_cell初始化全局变量库
serde、serde_json序列化专用库
tracing、tracing-subscriber，日志库
dotenv环境变量库
jsonwebtoken jwt认证库
chrono时间库
Axum + Perseus + Sycamore
