
import os
import glob
import subprocess

here = 'contents/figures'

def convert(pdf, newext='.svg', overwrite=False):
    newfile = os.path.splitext(pdf)[0]+newext
    if not overwrite and os.path.exists(newfile):
        return False
    subprocess.call('convert {} {}'.format(pdf, newfile), shell=True)
    return True

for fig in glob.glob(os.path.join(here, '*.pdf')):
    print fig
    convert(fig)
