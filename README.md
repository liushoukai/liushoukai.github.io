# Kay's Blog

The blog build with Jekyll and Github Pages.

## Install Ruby on Ubuntu 14.04

```shell
sudo apt-get -y install ruby2.5 ruby2.5-dev
```

## Install RubyGems

Please refer to the official installation [document](https://rubygems.org/pages/download).

## Install Bundler with RubyGems

```shell
sudo gem install bundler
```

## Run Webpack

```shell
npm install && npm run build
```

## Run Jekyll on local Server

```shell
bundle install
jekyll doctor
jekyll server --host=0.0.0.0
jekyll server --drafts
```

