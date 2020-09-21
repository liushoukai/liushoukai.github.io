---
layout: post
title: Sublime使用技巧
categories: sublime
tags: tool
---

## Sublime配置

### Sublime3用户设置

```json
{
     "color_scheme": "Packages/User/SublimeLinter/Monokai (SL).tmTheme",
     "draw_white_space": "selection",
     "font_face": "Courier New",
     "font_size": 12,
     "highlight_line": true,
     "tab_size": 4,
     "translate_tabs_to_spaces": false,
     "show_encoding": true,
     "show_line_endings": true
}
```

### Sublime快捷键设置

```json
[
     // Select Lines
     { "keys": ["ctrl+shift+up"], "command": "select_lines", "args": {"forward": false} },
     { "keys": ["ctrl+shift+down"], "command": "select_lines", "args": {"forward": true} },
     // Join Lines
     { "keys": ["ctrl+j"], "command": "join_lines" },
     // Copy Lines
     { "keys": ["ctrl+alt+down"], "command": "duplicate_line" },
     // Remove Lines
     { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Delete Line.sublime-macro"} },
     // Swap Lines
     { "keys": ["alt+up"], "command": "swap_line_up" },
     { "keys": ["alt+down"], "command": "swap_line_down" }
]
```

### Build System设置

```json
$ vim nodejs.sublime-build
{
    "cmd": ["F:\\Dev\\nodejs\\node.exe", "$file"],
    "file_regex": "js$",
    "selector": "source.js"
}
```

```json
$ vim php.sublime-build
{
    "cmd": ["D:\\MyDev\\php-5.3.5\\php.exe", "$file"],
    "file_regex": "php$",
    "selector": "source.php"
}
```

## SublimeLinter配置

SublimeLinter

```json
{
    "user": {
        "paths": {
            "linux": [
                "/usr/local/php",
                "/usr/local/node"
            ],
            "osx": [],
            "windows": [
                "J:\\bin\\php",
                "J:\\bin\\node"
            ]
        }
    }
}
```

### SublimeLinter-php配置

1. 安装php
2. 配置SublimeLinter，加入PHP的路径

参考：https://packagecontrol.io/packages/SublimeLinter-php

### SublimeLinter-jshint配置

1. 安装node.js
2. 安装jshint，npm install -g jshint
3. 配置SublimeLinter，加入Node路径

参考：https://packagecontrol.io/packages/SublimeLinter-jshint

### SublimeLinter-csslint配置

1. 安装node.js
2. 安装jshint，npm install -g csslint
3. 配置SublimeLinter，加入Node路径

参考：https://packagecontrol.io/packages/SublimeLinter-csslint
