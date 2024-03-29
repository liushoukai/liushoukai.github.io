# Kay's Blog

The blog build with Jekyll and Github Pages.

## Install Ruby on Ubuntu 16.04

```shell
sudo apt-get -y install ruby2.5 ruby2.5-dev
ruby --version
```

## Install RubyGems

Please refer to the official installation [document](https://rubygems.org/pages/download).

## Install Bundler with RubyGems

```shell
sudo gem install bundler jekyll
bundle install
bundle update
```

## Run Webpack

```shell
sudo npm install -g npm npm-check-updates
npm-check-updates -u
npm install && npm run build
```

## Run Jekyll on local Server

```shell
jekyll doctor
jekyll clean && jekyll server --host=0.0.0.0 --incremental --drafts
```

## syntax_highlighter: rouge

```shell
rougify style github > assets/css/syntax_highlighter.css
rougify style thankful_eyes > assets/css/syntax_highlighter.css
```

## Background Images

- [https://www.toptal.com/designers/subtlepatterns/](https://www.toptal.com/designers/subtlepatterns/)
