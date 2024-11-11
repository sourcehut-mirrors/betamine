# betamine

This is an implementation of Minecraft beta 1.7.3. At the moment it is little
more than a glorified world renderer.

Dependencies:

* Hare
* sdl2 & hare-sdl2
* hare-glm
* hare-gl

To try it out, run `make` to compile betamine and then run `./betamine <path>`
where _path_ is the path to a world in `~/.minecraft/saves` which was created
by Minecraft beta 1.7.3.

![Screenshot of betamine](https://redacted.moe/f/a0c2f3ff.png)

You will need some assets -- run `./script/fetch-mojang-assets` to download the
official assets from Mojang's servers.
