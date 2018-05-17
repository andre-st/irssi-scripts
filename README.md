# André's Irssi Scripts

[Irssi](https://irssi.org/) is a GPL licensed, proven Internet Relay Chat (IRC) textmode client with support for Perl scripting.

| Script       | Brief Description
|--------------|-------------------
| jalso.pl     | "Join also" is a channel recommender, based on aggregated whois-data of users in the current channel
| osd.pl       | "On Screen Display" displays chat lines at the bottom of a X11 desktop when the Irssi is invisible

&nbsp;


## Script jalso.pl – Kollaboratives Filtern von IRC-Kanälen

![Screenshot](jalso-20101127.png?raw=true "Screenshot")

Schwer überschaubar: 39 Tausend Kanäle im IRCnet, 63 Tausend im QuakeNet, 20 Tausend im EFnet
- Kanalsuche bisher nur mit `list` oder Alis
- manchmal weiß man nicht, was man haben kann - danach sucht man nicht
- ähnliche Kanäle mglw. besser besucht
- andere Kanäle mglw. spezifischer oder allgemeiner (#javascript <-> #webdesign)
- hilfreiches Verhalten/Wissen anderer Benutzer: sie besuchen inhaltlich _zusammenhängende_ Kanäle
  - Zusammenhang z.B. fachlich, geografisch, organisatorisch, weltanschaulich
  - Heuristik: Inhaltliche Nähe korreliert positiv mit der Mächtigkeit der Teilnehmer-Schnittmenge

Installation unter *nix oder Windows:
1. [Irssi](https://irssi.org/) ist bei Linux oft vorinstalliert
2. [jalso.pl](jalso.pl) nach `~/.irssi/scripts/`  bzw. bei Windows n. `%USERPROFILE%\.irssi\scripts` kopieren
3. in Irssi oder im `.irssi/startup`-File das Kommando `/load jalso.pl` tippen
4. im Kanal schließlich `/jalso` eingeben
5. irc.freenode.net wird leider nicht mehr unterstützt, s. Doku im Quelltext

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


