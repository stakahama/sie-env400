#!/usr/bin/env python

import os
import shutil
import glob
import re

here = 'contents/figures'
there  = os.path.join(os.environ['HOME'],'Documents/Work/EPFL/teaching/data_analysis_project/figures')

figfile = os.path.join(here, 'list.txt')

if os.path.exists(figfile):
    with open(figfile) as f:
        figlist = f.read().split('\n')
else:
    figlist = []

def extractfigs(filename):
    with open(filename) as f:
        img = []
        for line in f:
            if '<img ' in line:
                figname = re.match('.+src="([^"]+)".+', line).group(1)
                img.append(os.path.basename(figname))
    return img
                
for rmd in glob.glob('contents/*.Rmd'):
    figlist += extractfigs(rmd)

figlist = list(set(figlist))

for fig in figlist:
    fighere = os.path.join(here, fig)
    figthere = os.path.join(there, fig)
    if not os.path.exists(figthere):
        print fig, 'not found'
        continue
    if os.path.exists(fighere):
        continue
    shutil.copy2(os.path.join(there, fig), fighere)
    print fig, 'copied'
