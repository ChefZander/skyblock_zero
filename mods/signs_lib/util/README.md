# signs-font-generate

This is a collection of helper shell scripts to create textures for
international characters to be used with the
[signs_lib](https://gitlab.com/VanessaE/signs_lib) Minetest mod.

They currently expect the
[Liberation Fonts](https://github.com/liberationfonts/liberation-fonts) to be
installed at "/usr/share/fonts/truetype/liberation".

ImageMagick is also required.

## Basic usage

sh create-signs-lib-overlay.sh <signs_lib_directory> <language-code>

For example, this command will write textures for the non-ASCII characters
of the French language to "/home/user/signs_lib":

sh create-signs-lib-overlay.sh /home/user/signs_lib fr

Currently, there is support for German (de), French (fr) and Polish (pl)
non-ASCII characters.

## Character alignment

I chose the image processing parameters in order fairly match the alignment of
the existing signs_lib textures. In order to get even better alignment at
the expense of slightly smaller textures, it is possible to also replace
existing ASCII character textures:

sh write-ascii.sh <signs_lib_texture_directory>

For example, with signs_lib residing at "/home/user/signs_lib":

sh write-ascii.sh /home/user/signs_lib/textures
