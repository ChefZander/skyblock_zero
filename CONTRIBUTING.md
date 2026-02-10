# Copyright and Licensing of your Work
First and foremost, I suggest you at the very least educate yourself a bit on copyright in general. There are many online resources, but you can start with the following:

- [Wikiepdia's article on Copyright](https://en.wikipedia.org/wiki/Copyright) and even youtube videos.
- [US Copyright Office's article on copyright](https://www.copyright.gov/what-is-copyright/) which of course is US-specific.
- [Github's quick guide to open source software licensing](https://github.com/readme/guides/open-source-licensing). Broadly covers licenses common within open source (that includes Luanti!).

Next, please read the *[Copyright and Licensing](README.md#copyright-and-licensing)* section from the `README.md` for context.

In each non-'git submodule' mod there is a file named `COPYRIGHT.md` containing copyright information. It's important that you ensure copyright information about you and your contribution is correct. Subsections below will help guide you for each type of work.

The format of an author's/contributor's copyright notice is *Copyright (C) `YEAR` `NAME`. `CONTACT?`. `LICENSE`. `SOURCE?`* e.g. *Copyright (C) 2024-2026 ChefZander. GPL-3.0-only.*

- `YEAR` refers to the year of your work being published. e.g. Alice have contributed texture `AAA.png` made in 2023, and later made it cooler in 2025 and 2026. So, the year would be `2023, 2025-2026`.

- `NAME` refers to the name the author/contributor identifies with, even online. Don't choose names that you do not identify yourself with. In Alice's case, she apparently has a Github username *white_rabbit4512* and she uses that pseudonym instead of her real name.

- `CONTACT?` refers to the optional contact, usually e-mails. e.g. Bob wants to be contacted with `<i.am@bob.com>` so he puts that. Alice doesn't however, trying to avoid spam mails.

- `LICENSE` refers to the [SPDX license identifier](https://spdx.org/licenses/), which is basically just a short name precisely referring to the actual license used.

- `SOURCE?` refers to the original source. When you are using works by other people, you should link the original source for transparency.

Alice's copyright notice for `AAA.png`: *Copyright (C) 2023, 2025-2026 white_rabbit4512. CC-BY 4.0*

## Source Code

Skyblock: Zero licenses for code is per-mod instead of per-file in order to simplify attribution. For each mod you changed in your contribution:
1. You should check and understand its source code license.
2. You should ensure that the source code copyright information about yourself is correct.

If it is the first time you modified a mod, that usually means your name has yet to appear in the *Source Code* section of `COPYRIGHT.md`. Please fix that following the contributor's copyright notice format discussed earlier (the other contributors' copyright notices should help hint you too).

You don't need to study all licenses, just the ones you're working with directly. Extra resources on specific source code licenses:
- [GPL family of licenses](https://www.fsf.org/licensing/education/) (including LGPL) are discusssed in-depth by its steward, the Free Software Foundation. These licenses are popular within the Luanti community, so it's beneficial to take the time studying a bit on this.
- [MIT license aka MIT/Expat license](https://en.wikipedia.org/wiki/MIT_License) is also a popular permissive license within the Luanti comunity. Unlike the GPL family, this is a [permissive license](https://en.wikipedia.org/wiki/Permissive_software_license).

Some licenses require you to add a copyright notice on files modified from the original mod. Currently, this is required by the LGPL-2.0, LGPL-2.1, GPL-2.0 and Apache-2.0 licenses. In such cases, you will be attributing people like so:

```
This file is part of <mod name> mod.

Original mod.
Copyright (C) 2000-2020 Original <mod name> Mod Contributors

Modifications for Skyblock: Zero.
Copyright (C) 2024-2025 Skyblock: Zero <mod name> Contributors

Please see COPYRIGHT.md for names of authors and contributors.

<brief license notice>
```

Please see the contents of the relevant license for the brief license notice. For example, at the end of Apache-2.0's full text recommends this:

> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>     http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.


## Assets and Media

Skyblock: Zero licenses for assets are per-file instead of per-mod as this is the standard way of doing this across MTG mods and because of re-use of existing media by different authors who has never come into contact. For each file you add, remove or change in your contribution:
1. You should check and understand its license.
2. You should ensure that the copyright information about yourself is correct.

- Most license for assets and media uses the [Creative Commons family of licenses](https://creativecommons.org/share-your-work/cclicenses/) which generally covers all needs related to assets in Luanti community.
- Sometimes permissive licenses are used instead such as MIT or 0BSD. Although they refer to the work as software, it's still reasonable to ascertain terms from the license applied to e.g. an audio file.
- [Creative Commons Zero](https://creativecommons.org/publicdomain/zero/1.0/): it's also important to consider the CC0 which is also a substantially popular way to "let go" of one's work completely to the public as much as possible. Most notably, one no longer owns the copyright of their work.

If you're adding an asset that is a derivative/remix of another person's work, you need to credit the person. There are examples of crediting derivative work throughout various `COPYRIGHT.md` documents. A hypothetical example where Bob adds `awesome_kaboom.ogg` sound:

````md
`sounds/awesome_kaboom.ogg` Copyright (C) 2026 Bob. CC BY-SA 4.0. Derivative of "plank fall.wav" by Cleo. CC0. <cleop.py/sounds/plank-fall-wav-1288572>
````

**Avoid** the *NonCommercial* variants of Creative Commons licenses as those are considered non-free and are [limited within ContentDB](https://content.luanti.org/help/non_free/#whats-so-bad-about-licenses-that-forbid-commercial-use).

**Avoid** assets without any clear licensing. For example, some Luanti mods don't provide any copyright information about 3D models and textures. As you should be aware already about copyright, this likely means the author did not give out rights for you to use their work (all rights reserved).

**Avoid** assets licensed under copyleft software licenses, in particular the GPL and LGPL. The contents of the licenses work best on code, and is hard to understand/determine how it applies to e.g. sound.