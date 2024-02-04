#!/bin/bash

# Установка WireGuard
function install_wireguard() {
    echo "Добавление репозитория ELRepo..."
    yum install epel-release -y
    yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y
    yum install yum-plugin-elrepo -y

    echo "Установка WireGuard..."
    yum install kmod-wireguard wireguard-tools -y

    echo "WireGuard установлен."
}

# Настройка сервера WireGuard
function setup_server() {
    echo "Генерация серверных ключей..."
    wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

    server_private_key=$(cat /etc/wireguard/privatekey)
    server_public_key=$(cat /etc/wireguard/publickey)

    echo "Создание конфигурации сервера..."
    echo "[Interface]
Address = 10.0.0.1/24
SaveConfig = true
PrivateKey = $server_private_key
ListenPort = 51820" > /etc/wireguard/wg0.conf

    echo "Включение IP forwarding..."
    echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf
    sysctl -p

    echo "Настройка сервера WireGuard завершена."
}

# Генерация ключей и конфигурации для клиента
function add_client() {
    client_name=$1
    wg genkey | tee /etc/wireguard/${client_name}_privatekey | wg pubkey > /etc/wireguard/${client_name}_publickey

    client_private_key=$(cat /etc/wireguard/${client_name}_privatekey)
    client_public_key=$(cat /etc/wireguard/${client_name}_publickey)
    server_public_key=$(cat /etc/wireguard/publickey)

    echo "Создание конфигурации для клиента $client_name..."
    echo "[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24

[Peer]
PublicKey = $server_public_key
Endpoint = {SERVER_ADDRESS}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25" > /etc/wireguard/${client_name}.conf

    echo "Конфигурация для клиента $client_name создана."
}

# Проверка наличия аргументов командной строки
if [[ $# -eq 0 ]]; then
    echo "Начало установки и настройки WireGuard..."
    install_wireguard
    setup_server
    echo "WireGuard готов к использованию. Теперь вы можете добавить клиентов, используя add_client."
else
    echo "Добавление клиента: $1"
    add_client $1
fi
