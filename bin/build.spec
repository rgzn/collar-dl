import gooey
gooey_root = os.path.dirname(gooey.__file__)
gooey_languages = Tree(os.path.join(gooey_root, 'languages'), prefix = 'gooey/languages')
gooey_images = Tree(os.path.join(gooey_root, 'images'), prefix = 'gooey/images')
self_root = os.path.realpath('../')
self_etc = os.path.join(self_root, 'etc')
#gooey_images = Tree(os.path(join(self_etc, 'images'), prefix='gooey/images')
a = Analysis(['collar-dl.py'],
             pathex=["c:\\Users\jweissman\src\collar-dl\bin"],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None,
             )
pyz = PYZ(a.pure)

options = [('u', None, 'OPTION'), ('u', None, 'OPTION'), ('u', None, 'OPTION')]

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          options,
          gooey_languages, # Add them in to collected files
          gooey_images, # Same here.
          name='collar-dl.exe',
          debug=False,
          strip=None,
          upx=True,
          console=True,
          windowed=True,
          icon=os.path.join(self_etc, 'images', 'program_icon.ico'))
          #icon=os.path.join(gooey_root, 'images', 'program_icon.ico'))
