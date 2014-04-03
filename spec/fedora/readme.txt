RU:
Сборка пакетов в Fedora идентична сборке пакетов в Mageia, кроме:
1) в spec-файле вместо строки
                             Release: %mkrel номер_релиза
указать номер релиза без %mkrel,
2) патчи Source1, Source2 не используются, убрать обязательно, убрать все строки, содержащие vpnmcc.

EN:
Building packages for Fedora is like Mageia, except:
1) in the spec-file instead of a string
                              Release: %mkrel number_release
specify the release number without %mkrel,
2) patches Source1, Source2 are not used, please delete, remove all lines containing vpnmcc.
