#!/usr/bin/env python

## Create project homepage for GitLab pages

## -----------------------------------------------------------------------------

import os
import shutil
import subprocess

## -----------------------------------------------------------------------------

cmd = 'pandoc -s --self-contained \
-f markdown \
-t html5 \
-o public/index.html \
README.md'

subprocess.call(cmd, shell=True)

## -----------------------------------------------------------------------------

path_fig = os.path.join('contents', 'figures')
file_fig = 'NABEL_Network.png'

if not os.path.exists(os.path.join('public', path_fig)):
    os.makedirs(os.path.join('public', path_fig))

if not os.path.exists(os.path.join('public', path_fig, file_fig)):
    shutil.copy2(os.path.join(path_fig, file_fig),
                 os.path.join('public', path_fig))
