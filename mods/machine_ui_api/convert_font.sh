# I used this script for another mod, it's my script so i am confident i can use it
# https://github.com/TheEt1234/minetest-virt/blob/master/textures/convert.sh
str=$(lua -e "for i=32,255 do io.write(string.char(i) .. '\n') end")

for file in *.ttf; do
    echo "${str}" | magick -background "rgba(0,0,0,0)" -fill white -font ${file} -pointsize 25 -gravity center label:@- ${file}.png &
done

echo "Done!"
