(
    seq $((0x$(echo -n a | xxd -ps))) $((0x$(echo -n z | xxd -ps)))
    seq $((0x$(echo -n A | xxd -ps))) $((0x$(echo -n Z | xxd -ps)))
    seq $((0x$(echo -n 0 | xxd -ps))) $((0x$(echo -n 9 | xxd -ps)))
    echo -n " #$%&'()*+,-./:;<=>?@[]^_{|}~!\"\\\`"|
    xxd -ps|
    sed 's/../&\n/g'|
    grep .|
    sed 's/.*/echo $((0x&))/'|
    sh
)|
sed 's<^<printf "%.02x\\n" <'|
sh|
sed 's<.*</bin/echo -n -e "convert\\\
 -debug annotate\\\
 -size 180x180 xc:white\\\
 -font /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf\\\
 -gravity northwest\\\
 -pointsize 16\\\
 +antialias\\\
 -annotate 0 '"'"'"\
/bin/echo -n -e "\\x&"|\
sed '"'"'s>'"'"'"'"'"'"'"'"'>\&"\&"\&>'"'"'\
/bin/echo -n -e "'"'"'\\\
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
 '"$1"'/signs_lib_font_16px_&.png%'"'"'|\
sh -e -x\
convert\\\
 -debug annotate\\\
 -size 180x180 xc:white\\\
 -font /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf\\\
 -gravity northwest\\\
 -pointsize 32\\\
 +antialias\\\
 -annotate 0 '"'"'"\
/bin/echo -n -e "\\x&"|\
sed '"'"'s>'"'"'"'"'"'"'"'"'>\&"\&"\&>'"'"'\
/bin/echo -n -e "'"'"'\\\
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
 '"$1"'/signs_lib_font_32px_&.png%'"'"'|\
sh -e -x\
"<'|
sh|
sh -e -x
rm -f "$1/im-out.png"
rm -f "$1/im.err"
