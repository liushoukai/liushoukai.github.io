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

## jekyll kramdown 语法高亮

GitHub 推荐使用的 Jekyll 的 Markdown 插件为 kramdown。kramdown 是一个强大且高性能的文本转换引擎，kramdown是markdown的超集。在Jekyll中支持, 可以用于Github搭建博客. 和Jekyll一样使用Ruby作为核心语言。由于Maruku不再更新, Github推荐使用kramdown作为markdown解析。

官方文档：https://kramdown.gettalong.org/documentation.html

`Rouge语法高亮`

1、配置 kramdown 转换引擎在转换 Markdown 为 HTML 的时候，使用 rouge 格式的样式（具体只语法高亮所用的 css 的 class）
```
markdown: kramdown
kramdown: 
  input: GFM 
  syntax_highlighter: rouge
```
2、使用Rouge生成并引入Rouge语法高亮样式
```shell
gem install rouge
rougify help style

##########################################
available themes:
  base16, base16.dark, base16.light, base16.monokai, base16.monokai.dark, base16.monokai.light, base16.solarized, base16.solarized.dark, base16.solarized.light, colorful, github, gruvbox, gruvbox.dark, gruvbox.light, igorpro, molokai, monokai, monokai.sublime, thankful_eyes, tulip
##########################################

rougify style github > assets/css/syntax_highlighter.css
rougify style thankful_eyes > assets/css/syntax_highlighter.css
```

3、修改页面样式
```html
<link rel="stylesheet" type="text/css" href="{{ '/assets/css/syntax_highlighter.css' | prepend: site.baseurl }}" />
```

`Coderay语法高亮`
```
markdown: kramdown
kramdown: 
  input: GFM 
  syntax_highlighter: coderay
```