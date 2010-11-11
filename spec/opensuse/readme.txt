Сборка пакетов в openSUSE идентична сборке пакетов в Mandriva, кроме:
1) в spec-файле вместо Release: %mkrel_номер_релиза указать номер релиза без %mkrel,
2) зависимости сборки gdk-pixbuf, gtk+, libglib1.2-devel, libgdk-pixbuf2-devel, lib64glib1.2-devel, lib64gdk-pixbuf2-devel не обязательны,
3) вместо пакета pptp-linux используется пакет pptp,
4) патчи Source1 не используются.