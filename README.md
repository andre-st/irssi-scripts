# André's Irssi Scripts

[Irssi](https://irssi.org/) is a GPL licensed, proven Internet Relay Chat (IRC) textmode client with support for Perl scripting.

| Script       | Brief Description
|--------------|-------------------
| jalso.pl     | "Join also" is a channel recommender, based on aggregated whois-data of users in the current channel
| osd.pl       | "On Screen Display" displays chat lines at the bottom of a X11 desktop when the Irssi is invisible

&nbsp;


## Script jalso.pl – Collaborative filtering of IRC channels

![Screenshot](jalso-20101127.png?raw=true "Screenshot")

Difficult to oversee 39 thousand channels on IRCnet, 63 thousand on QuakeNet, 20 thousand on EFnet
- channel search so far only with `list` or ALIS (Advanced List Service) or [web-search](http://irc.netsplit.de/channels/) (~500 networks)
- sometimes you don't know what you can get - so you do not look for it
- similar channels may be more visited
- other channels may be more specific or general (#javascript <-> #webdesign)
- helpful behavior/knowledge of other users: they visit related channels
  - the relation is, e.g., professional, geographical, organizational, ideological
  - Heuristic: relatedness correlates positively with the cardinality of the intersection of their participants

Installation on \*nix or Windows:
1. [Irssi](https://irssi.org/) comes pre-installed on Linux
2. copy [jalso.pl](jalso.pl) to `~/.irssi/scripts/autorun`  or `%USERPROFILE%\.irssi\scripts\autorun` (Windows)
3. type `/ jalso` in the channel
4. unfortunately, irc.freenode.net is no longer supported, see comments in the source code

&nbsp;


## Script osd.pl – Beiläufiges Mitlesen von Internet-Relay-Chats

Wer arbeitet und nebenher chattet prüft regelmäßig, ob neuer Text im Chat-Fenster steht. Dabei unterbricht er auch seine Arbeit, wenn nichts darin steht, weil er es nur hinterher feststellt. Wird ihm aber mitgeteilt, wann es sich lohnt, dann kann er die Arbeit im Blick behalten:

Neue Antworten erscheinen kurz auf der Arbeitsoberfläche:
![Screenshot](osd-20110213.png?raw=true "Screenshot")

Weil Einblendungen aber auch ablenken nützen sie eher bei ruhigeren Chats – im IRC wird viel geidlet. Einzelne Kanäle lassen sich mit dem `/osdmute`-Kommando in Irssi stummschalten. Zudem erleichtert die automatische Färbung, wichtige und weniger wichtige Kanäle auseinanderzuhalten, ohne immer lesen zu müssen. Einblendungen erscheinen auch nur, wenn Irssi unsichtbar ist.

Installation unter GNU/Linux:
1. [Irssi](https://irssi.org/) ist bei Linux oft vorinstalliert
2. libXosd installieren (Paket `system/xosd` bei Slackware)
3. `$ sudo perl -MCPAN -e 'install X::Osd'`
4. [osd.pl](osd.pl) nach `~/.irssi/scripts/` kopieren
5. in Irssi oder im `.irssi/startup`-File das Kommando `/load osd.pl` tippen

&nbsp;


## Feedback

Use [GitHub](https://github.com/andre-st/irssi-scripts/issues) or see [AUTHORS.md](AUTHORS.md) file


## Nutzungslizenz
Creative Commons BY-SA


