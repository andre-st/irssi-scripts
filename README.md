# André's Irssi Scripts

![Maintenance](https://img.shields.io/maintenance/yes/2019.svg)


[Irssi](https://irssi.org/) is a GPL licensed, proven Internet Relay Chat (IRC) textmode client with support for Perl scripting.

| Script       | Brief Description
|--------------|-------------------
| jalso.pl     | "Join also" is a channel recommender, based on aggregated whois-data of users in the current channel
| osd.pl       | "On Screen Display" displays chat lines at the bottom of a X11 desktop when the Irssi is invisible

&nbsp;


## Script 1: Collaborative Filtering of IRC Channels – jalso.pl

![Screenshot](jalso-20101127.png?raw=true "Screenshot")

Difficult to oversee 39 thousand channels on IRCnet, 63 thousand on QuakeNet, 20 thousand on EFnet
- channel search so far only with `list` or ALIS (Advanced List Service) or [web-search](http://irc.netsplit.de/channels/) (~500 networks)
- sometimes you don't know what you can get — so you don't look for it
- similar channels may be more visited — names?
- other channels may be more specific or general (#javascript <-> #webdesign)
- helpful behavior/knowledge of other users: they visit related channels
  - the relation is, e.g., professional, geographical, organizational, ideological
  - Heuristic: relatedness correlates positively with the cardinality of the intersection of their participants

Installation on \*nix or Windows:
1. [Irssi](https://irssi.org/) comes pre-installed on Linux
2. copy [jalso.pl](jalso.pl) to `~/.irssi/scripts/autorun/`  or `%USERPROFILE%\.irssi\scripts\autorun\` (Windows)
3. type `/jalso` in the channel
4. unfortunately, irc.freenode.net is no longer supported, see comments in the source code

&nbsp;


## Script 2: Follow Chats Without Visible Irssi Window – osd.pl

Anyone who works and chats in parallel, regularly checks for new text in the chat window. He also interrupts his work, if there's no text, because he only knows it afterwards. But if he is told when it is worthwhile, then he can keep an eye on the work:

New answers appear directly on the desktop and disappear again:
![Screenshot](osd-20110213.png?raw=true "Screenshot")

Since text overlays distract too, they are more useful in quieter chats — IRC users idle most of the time, though. Individual channels can be muted with the `/osdmute` command in Irssi. In addition, automatic coloring makes it easier to distinguish between important and less important channels without having to read the answers. Overlays only appear when Irssi is invisible.

Installation on GNU/Linux:
1. [Irssi](https://irssi.org/) comes pre-installed on Linux
2. install libXosd (`system/xosd` package on Slackware)
3. `$ sudo perl -MCPAN -e 'install X::Osd'`
4. copy [osd.pl](osd.pl) to `~/.irssi/scripts/autorun/`

&nbsp;


## Feedback

If you like this project, give it a star on GitHub.
Report bugs or suggestions [via GitHub](https://github.com/andre-st/irssi-scripts/issues) 
or see the [AUTHORS.md](AUTHORS.md) file.
