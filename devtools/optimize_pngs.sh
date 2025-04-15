# from https://github.com/luanti-org/minetest_game/blob/master/utils/optimize_textures.sh
find .. -name '*.png' -print0 | xargs -0 optipng -o7 -zm1-9 -nc -strip all -clobber
