---
layout: post
title: Ruby Jekyll Blog
categories: ruby
tags: jekyll
---

## 安装Ruby版本管理器RVM

RVM(Ruby Version Manager)是一个Ruby版本管理工具，类似nodejs中的nave。

1、安装Ruby版本管理器RVM，参考：https://rvm.io/rvm/install。

```shell
source ~/.rvm/scripts/rvm
# 安装默认会在 ~/.bashrc ~/.zshrc 两个配置文件中追加下述配置
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
```

2、使用RVM安装Ruby 3.2.1 版本。

```shell
rvm install ruby 3.2.1
rvm --default use 3.2.1
ruby -v
gem -v
```

3、更新RubyGems镜像源

Gem是Ruby语言中的包，是一种打包的规范。RubyGem是Gem包管理工具。

```shell
gem sources -l
gem sources --add https://ruby.taobao.org/ --remove http://rubygems.org/
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
```


## Bundler

Bundler 是 Gem 的依赖管理工具，能够跟踪并安装项目中所需的版本的 Gems。

```shell
# 安装bundle
gem install bundler

# 在当前目录下生成新的Gemfile文件
bundle init

# 在项目根目录的 Gemfile 中指定依赖项：（注意⚠️：需要将Gemfile和Gemfile.lock纳入版本控制）

##########################################
# source "https://rubygems.org"
source 'https://gems.ruby-china.com'
gem 'jekyll'

group :jekyll_plugins do
  gem 'jekyll-paginate'
  gem 'jekyll-watch'
  gem 'pygments.rb'
  gem 'redcarpet'
  gem 'kramdown'
  gem 'coderay'
  gem 'rouge'
  gem 'public_suffix'
end
##########################################

# 安装Gemfile文件内的依赖项
bundle install
```
