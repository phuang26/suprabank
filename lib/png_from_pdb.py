#!/usr/bin/env python
# -*- coding: UTF8 -*-
"""
author: Guillaume Bouvier
email: guillaume.bouvier@ens-cachan.org
creation date: 2014 04 29
license: GNU GPL
Please feel free to use and modify this, but keep the above information.
Thanks!
"""

import sys
sys.path.append('/c5/shared/pymol/1.7.0.0-python-2.7.5-shared/lib/python2.7/site-packages/')

import __main__
__main__.pymol_argv = ['pymol','-qc'] # Pymol: quiet and no GUI
import pymol
pymol.finish_launching()

pdb_file =sys.argv[1]
pdb_name =pdb_file.split('.')[0]
pymol.cmd.load(pdb_file, pdb_name)
pymol.cmd.disable("all")
pymol.cmd.enable(pdb_name)
#print pymol.cmd.get_names()
pymol.cmd.hide('all')
pymol.cmd.show('cartoon')
#pymol.cmd.set('cartoon_fancy_helices',1)
pymol.cmd.set('opaque_background', 0)
#pymol.cmd.set('bg_rgb',[1,1,1])
pymol.cmd.color('density', 'ss s')
pymol.cmd.color('forest', 'ss h')
pymol.cmd.color('firebrick', 'ss l+')
pymol.cmd.png("%s.png"%(pdb_name), width=600, height=600, dpi=300, ray=1)
pymol.cmd.quit()
