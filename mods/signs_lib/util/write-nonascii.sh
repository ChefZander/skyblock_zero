sed 's,.*,sh unicode-numbers.sh "&",'|
sh|
sed 's/'"'"'/&"&"&/g'|
sed 's/%/&&/g'|
sed "s,.*,printf '&\\\n',"|
sed "s/\([0-9]*\),/'\nprintf '\\\x%.02x' \1\nprintf '/g"|
sh|
sed 's<{\(.*\)"\(.*\)"}</bin/echo -e "convert\\\
 -debug annotate\\\
 -size 180x180 xc:white\\\
 -font /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf\\\
 -gravity northwest\\\
 -pointsize 16\\\
 +antialias\\\
 -annotate 0 '"'"'\1'"'"'\\\
 "'"$1"'/im-out.png" 2> "'"$1"'/im.err"\
grep '"'"' width: '"'"' "'"$1"'/im.err"|\
sed '"'"'s/.* width: //'"'"'|\
sed '"'"'s/;.*//'"'"'|\
sed '"'"'s|^|printf \\\"%.0f\\\" |'"'"'|\
sh|\
sed '"'"'s%.*%convert\\\
 '"$1"'/im-out.png\\\
 -negate\\\
 -monochrome\\\
 -transparent white\\\
 -crop \\$((\&+1))x16+0+2\\\
 +repage\\\
 '"$1"'/signs_lib_font_16px_\2.png%'"'"'|\
sh -e -x\
convert\\\
 -debug annotate\\\
 -size 180x180 xc:white\\\
 -font /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf\\\
 -gravity northwest\\\
 -pointsize 32\\\
 +antialias\\\
 -annotate 0 '"'"'\1'"'"'\\\
 "'"$1"'/im-out.png" 2> "'"$1"'/im.err"\
grep '"'"' width: '"'"' "'"$1"'/im.err"|\
sed '"'"'s/.* width: //'"'"'|\
sed '"'"'s/;.*//'"'"'|\
sed '"'"'s|^|printf \\\"%.0f\\\" |'"'"'|\
sh|\
sed '"'"'s%.*%convert\\\
 '"$1"'/im-out.png\\\
 -negate\\\
 -monochrome\\\
 -transparent white\\\
 -crop \\$((\&+1))x32+0+4\\\
 +repage\\\
 '"$1"'/signs_lib_font_32px_\2.png%'"'"'|\
sh -e -x"<'|
sh|
sh -e -x
rm -f "$1/im-out.png"
rm -f "$1/im.err"
