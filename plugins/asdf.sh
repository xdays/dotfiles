#!/bin/bash
# -*- coding: utf-8 -*-
 
if [ -e $HOME/.asdf ]; then
    . $HOME/.asdf/asdf.sh
fi

[ -e ~/.asdf/plugins/java/ ] && source ~/.asdf/plugins/java/set-java-home.sh
