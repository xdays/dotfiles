#!/bin/bash
# -*- coding: utf-8 -*-
 
if [ "$(uname)" = "Linux" ]; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi
