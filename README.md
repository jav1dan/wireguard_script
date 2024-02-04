# Script For WireGuard
Script to quick installing Wireguard on CentOS7

1. Скачайте script.sh на ваш сервер
2. Поменяйте `{SERVER_ADDRESS}` на IP адрес Вашего сервера
3. Сделайте файл исполняемым с помощью функции `chmod +x script.sh`
4. Для первоначальной настройки запустите скрипт
`./setup_wireguard.sh`
5. Для создания пары ключей для клиента (к примеру для клиента с client1)
`./setup_wireguard.sh client1`
