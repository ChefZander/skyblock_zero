ffmpeg -i $1 -ac 1 $1.tmp.ogg
mv $1.tmp.ogg $1
