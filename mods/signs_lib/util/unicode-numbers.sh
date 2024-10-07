(
    echo -n "$1"|
    xxd -ps|
    sed 's/../echo $((0x&))\n/g'|
    sh
    echo -n "$1"|
    iconv -f utf-8 -t utf-32|
    xxd -ps|
    sed s/fffe0000//|
    sed 's/../&\n/g'|
    grep .|
    tac|
    tr "
" " "|
    sed 's/ //g'|
    sed s/^00//|
    sed s/^00//|
    sed 's/.*/"&"/'
)|
tr "
" ","|
sed 's/.*/{&}\n/'
