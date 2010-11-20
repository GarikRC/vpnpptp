Сборка пакетов в Fedora идентична сборке пакетов в Mandriva, кроме:
1) в spec-файле вместо Release: %mkrel_номер_релиза указать номер релиза без %mkrel, также убрать другие определения,
2) зависимости сборки gdk-pixbuf, gtk+, libglib1.2-devel, libgdk-pixbuf2-devel, lib64glib1.2-devel, lib64gdk-pixbuf2-devel не обязательны,
3) вместо пакета pptp-linux используется пакет pptp,
4) патчи Source1 не используются, убрать обязательно,
5) вместо пакета gksu используется пакет beesu - надо заменить в spec-файлах все gksu на beesu, а также исправить команды, чтобы они были вида:
Exec=beesu /opt/vpnpptp/vpnpptp
Exec=beesu /opt/vpnpptp/ponoff