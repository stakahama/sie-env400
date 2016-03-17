#!/usr/bin/env python

import os
import shutil

here = 'contents/figures'
there  = os.path.join(os.environ['HOME'],'Documents/Work/EPFL/teaching/data_analysis_project/figures')

with open(os.path.join(here,'list.txt')) as f:
    figlist = f.read().split('\n')

for fig in figlist:
    fighere = os.path.join(here, fig)
    if os.path.exists(fighere):
        continue
    shutil.copy2(os.path.join(there, fig), fighere)
