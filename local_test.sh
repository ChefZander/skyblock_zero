docker run --rm -it -v $(pwd):/github/workspace \
    -e INPUT_TEST_MODE=game \
    -e INPUT_MAPGEN=v7 \
    -e INPUT_ENABLE_COVERAGE=true \
    -e INPUT_ADDITIONAL_CONFIG="secure.trusted_mods=mtt,libox"\
    ghcr.io/buckaroobanzay/mtt