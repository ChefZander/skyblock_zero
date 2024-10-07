mkdir -p "$1/textures"
cat nonascii-$2|
sh write-nonascii.sh "$1/textures"
cat nonascii-$2|
sed 's,.*,sh unicode-numbers.sh "&",'|
sh|
sed 's/.*/signs_lib.unicode_install(&)/'|
sort > "$1/nonascii-$2.lua"
