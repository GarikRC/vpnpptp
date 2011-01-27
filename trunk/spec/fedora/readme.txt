Сборка пакетов в Fedora идентична сборке пакетов в Mandriva, кроме:
1) в spec-файле вместо строки
                             Release: %mkrel номер_релиза
указать номер релиза без %mkrel,
2) вместо пакета pptp-linux используется пакет pptp,
3) патчи Source1 не используются, убрать обязательно,
4) вместо пакета gksu используется пакет beesu - надо заменить в spec-файлах все gksu на beesu, а также исправить команды, чтобы они были вида:
Exec=beesu /usr/bin/vpnpptp
Exec=beesu /usr/bin/ponoff

Информация по альтернативной сборке без использования beesu есть в репозитории Russian Fedora: http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/fedora/updates/14/SRPMS/