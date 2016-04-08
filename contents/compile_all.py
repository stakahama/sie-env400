#!/usr/bin/python
import glob
import subprocess
for f in glob.glob('*.Rmd'):
    subprocess.call('R -e "rmarkdown::render(\'{}\')"'.format(f), shell=True)

## subprocess.call('ln -sv $PWD/figures_rmd/lec04_unnamed-chunk-10-1.png figures', shell=True)
