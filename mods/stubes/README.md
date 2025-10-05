# Stubes

An attempt to be luanti's best item transport.

I am using 32x32 textures for the tubes, because i could not fit a recognizable arrow into a 32x32 texture without making the node bigger.
I am also doing the textures in the style of Skyblock Zero. PRs for textures for other games are welcome.

This mod was inspired by pipeworks and by mindustry.

## Terminology
In-game, Stubes should refer to themselves as just item tubes, but in code/comparisons they should be referred to as stubes to distinguish them from other implementations of item tubes.

## Compatibility
STubes don't implement their own way of letting nodes accept stube tubed items.  
The preffered way for a node to accept STube tubed items is using pipeworks, but there will be other ways in the future.

| Name            | Status            | Notes                                                            |
| --------------- | ----------------- | ---------------------------------------------------------------- |
| **Pipeworks**   | Mostly compatible | Currently, stube to pipeworks *tube* transport does not exist.   |
| Tubelib         | Not compatible    | PRs welcome! Although i am unsure if there is demand.            |
| Others?         | Not compatible    | Let me know if there is anything else worth adding to this table |

### MAJOR INTERNAL IMPROVEMENTS/INTERNAL-ONLY BREAKING CHANGES ARE WELCOME

If you don't think therere is no need for internal restructuring/breaking changes, make an issue.

Currently i am interested in major improvements because:
- the stubes/routing block split is kinda strange? i dunno if stubes sohuld just

## Performance
- Tubed item visuals which aren't near the player aren't shown (so that gets rid of the need to perform costly `move_to` calls)
- It should be able to handle 10 000 items easily

# API: TODO
