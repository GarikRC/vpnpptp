RU:
Сборка пакетов в openSUSE идентична сборке пакетов в Mageia, кроме:
1) в spec-файле вместо строки
                             Release: %mkrel номер_релиза
указать номер релиза без %mkrel,
2) патчи vpnpptp.pm, vpnmcc.pm не используются, но можно оставить.

EN:
Building packages for openSUSE is like Mageia, except:
1) in the spec-file instead of a string
                              Release: %mkrel number_release
specify the release number without %mkrel,
2) patches vpnpptp.pm, vpnmcc.pm are not used, but you are not required to remove them.
