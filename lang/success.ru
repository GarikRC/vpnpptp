Установка соединения VPN PPTP/L2TP/OpenL2TP завершена!

Вы можете подключаться к интернету:
1) С помощью ярлыка на рабочем столе;
2) Запустив ponoff (Управление соединением VPN PPTP/L2TP/OpenL2TP) из Меню запуска приложений;
3) Выполнив в консоли под администратором команду ponoff;
4) Выполнив в консоли под администратором команду /usr/sbin/pppd call имя_соединения (в этом случае VPN PPTP будет работать без графического интерфейса) для соединения, а для отключения - команду killall pppd;
5) Запустив xl2tpd как сервис, и выполнив в консоли под администратором команду echo "c имя_соединения" > /var/run/xl2tpd/l2tp-control (в этом случае VPN L2TP будет работать без графического интерфейса) для соединения, а для отключения - команду killall pppd и команду echo "d имя_соединения" > /var/run/xl2tpd/l2tp-control;
6) Выполнив в консоли под администратором команду bash /var/lib/vpnpptp/имя_соединения/openl2tp-start (в этом случае VPN OpenL2TP будет работать без графического интерфейса) для соединения, а для отключения - команду bash /var/lib/vpnpptp/имя_соединения/openl2tp-stop;
7) Выполнив в консоли под администратором команду /usr/bin/vpnlinux имя_соединения (в этом случае VPN будет работать без графического интерфейса) для соединения, а для отключения - команду /usr/bin/vpnlinux stop.

Данный конфигуратор vpnpptp (Настройка соединения VPN PPTP/L2TP/OpenL2TP) можно вызвать в консоли под администратором командой vpnpptp или из Меню запуска приложений, или из Центра Управления Вашего дистрибутива (например, раздел Сеть и Интернет->Настройка VPN-соединений->VPN PPTP/L2TP/OpenL2TP).

Если соединение неправильно сконфигурировалось, то запустите данный конфигуратор повторно. Проверьте правильность введенных данных. Пользуйтесь тестовым запуском чтобы отладить подключение, смотрите логи. Если не появился ярлык на рабочем столе, то обновите рабочий стол (например, F5).

Управлять подключением к интернету Вы можете с помощью значка в трее, щелкнув по нему правой кнопкой мыши.

Предлагается 2 варианта выхода из программы:
1) вернуться в состояние, которое было изначально до запуска VPN, можно лишь если нет аварии на линии;
2) если же на линии авария, то при аварийном выходе из программы сеть будет перезапущена.

Соединение устанавливается автоматически в течение времени дозвона. Если оно за это время не установилось, то делается повторная попытка установить соединение в течение времени дозвона и т.д. Программа умеет автоматически восстанавливать соединение в случае аварий.
Если соединение установилось, но интернет не работает, то проверьте настройки файервола (или отключите его совсем).
Более подробную информацию и сопроводительную документацию о программе можно найти в папке /usr/share/vpnpptp/wiki/

С замечаниями и пожеланиями по работе программы обращаться: loginov_alex@inbox.ru, loginov.alex.valer@gmail.com

Ссылки:
http://code.google.com/p/vpnpptp/ - страница проекта.
http://unixforum.org/index.php?showtopic=89669 - форум.
http://linuxforum.ru/viewtopic.php?id=147 - форум.
