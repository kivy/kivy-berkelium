Berkelium extension for Kivy
============================

Berkelium is a BSD licensed library for offscreen rendering via Chromium
project. Check http://berkelium.org/ for more information about it. We are using
a patched version of Berkelium, available at https://github.com/tito/berkelium
(branch chromium8-alternate-bin)


Notes
-----

- This extension require Kivy 1.0.7 minimum !
- This extension is under development. It's actually working and tested
  only for Linux 64 bits.
- MacOSX can't be supported at the moment, since Kivy require Python
  64bits, and Chromium can't be built under 64bits on MacOSX.


How to install
--------------

1. Download .kex https://github.com/kivy/kivy-berkelium/archives/master
2. Copy the .kex to ~/.kivy/extensions


How to test
-----------

1. Download https://github.com/kivy/kivy-berkelium/raw/master/demo/main.py
2. Run with "python main.py"


How to recompile
----------------

.. note::
    This method have been tested only on Linux (Ubuntu 11.10 and 12.04) 64bits.

#. sudo apt-get install chrpath libcurl4-nss-dev libgtk2-dev libgconf2-dev libgnome-keyring-dev dbus-glib-1-dev flex bison libjpeg62-dev
#. sudo apt-get install binutils-gold chrpath
#. git clone git://github.com/kivy/berkelium
#. git checkout chromium11
#. util/build-chromium.sh --deps
#. cmake . -DCMAKE_BUILD_TYPE=Release
#. make
#. git clone git://github.com/kivy/kivy-berkelium
#. cd kivy-berkelium
#. make
#. mv dist/berkelium-1.2.linux-x86_64.zip dist/berkelium-1.2.linux-x86_64.kex

And you can copy the berkelium-1.2.linux-x86_64.kex into your ~/.kivy/extensions
