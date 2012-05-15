from os import walk
from os.path import join, sep
from distutils.core import setup
from distutils.cmd import Command
from distutils.extension import Extension
from subprocess import call
from Cython.Distutils import build_ext


class PackageBuild(Command):
    description = 'Create Extension Package'
    user_options = []

    def run(self):
        # Call this file and make a distributable .zip file that has our desired
        # folder structure
        call(['python', 'setup.py', 'install', '--root', 'build/zip', '--install-lib',
              '/', '--install-platlib', '/', '--install-data', '/berkelium/data',
              'bdist', '--formats=zip'])

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

cmdclass = {
    'create_package': PackageBuild,
    'build_ext': build_ext
}

ext = Extension(
    'berkelium._berkelium',
    ['berkelium/_berkelium.pyx'],
    include_dirs=['../include'],
    library_dirs=['berkelium/data'],
    libraries=['libberkelium'],
    extra_link_args=['-Wl,-rpath=$ORIGIN/data'],
    language='c++',
)

# list all files to compile
data_files = []
for root, dirnames, filenames in walk(join('berkelium', 'data')):
    for filename in filenames:
        fn = join(root, filename)
        fn = sep.join(fn.split(sep)[1:])
        data_files.append(fn)

setup(
    name='berkelium',
    version='1.2',
    author='Mathieu Virbel',
    author_email='mat@kivy.org',
    url='http://txzone.net/',
    license='LGPL',
    description='A webbrowser based on Berkelium project',
    ext_modules=[ext],
    cmdclass=cmdclass,
    packages=['berkelium'],
    package_dir={'berkelium': 'berkelium'},
    package_data={'berkelium': data_files}
)
