# betamine

This is a Minecraft beta 1.7.3 client. At the moment it is very simple and
limited in its capabilities.

Dependencies:

* Hare (master)
* sdl2 & hare-sdl2
* hare-compress
* hare-gl
* hare-glm ([forked](https://git.sr.ht/~sircmpwn/hare-glm))

To try it out, run `make` to compile betamine and then run `./betamine <address>`
where _address_ is the address (or hostname) of a Minecraft beta 1.7.3 server.

You will need some assets -- run `./script/fetch-mojang-assets` to download the
official assets from Mojang's servers.

You can find a Minecraft beta 1.7.3 server jar
[here](https://files.betacraft.uk/server-archive/beta/b1.7.3.jar).

![Screenshot of betamine](https://redacted.moe/f/6a5160eb.png)
