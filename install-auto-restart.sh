#!/bin/bash
set -e

# ================================
# Auto Restart Docker Containers
# ================================

SERVICE_USER="crankk"
SERVICE_DIR="/home/$SERVICE_USER"
SCRIPT_RESTART="auto_restart_containers.sh"
SCRIPT_START="start_containers.sh"
LOG_FILE="$SERVICE_DIR/auto_restart_containers.log"
STARTUP_LOG="$SERVICE_DIR/startup.log"
SERVICE_NAME="auto-restart-containers"

echo "=== Instalacja automatycznego restartu kontenerów ==="

# 1. Upewnij się, że docker jest zainstalowany
if ! command -v docker &>/dev/null; then
    echo "[INFO] Instaluję Docker..."
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
fi

# 2. Pobierz obraz alpine jeśli go nie ma
if [[ "$(docker images -q alpine:latest 2>/dev/null)" == "" ]]; then
    echo "[INFO] Pobieram obraz alpine..."
    docker pull alpine:latest
fi

# 3. Upewnij się, że katalog istnieje
mkdir -p "$SERVICE_DIR"
chown $SERVICE_USER:$SERVICE_USER "$SERVICE_DIR"

# 4. Utwórz skrypt auto-restart
cat > "$SERVICE_DIR/$SCRIPT_RESTART" << 'EOF'
#!/bin/bash
# Monitorowanie kontenerów i automatyczny restart

LOG_FILE="/home/crankk/auto_restart_containers.log"

while true; do
    for container in crankk crankk-pktfwd crankk-terminal watchtower miner grafana db honeygain earnapp pawnsapp gaganode piphi-network-image crankk-update; do
        if [ "$(docker ps -q -f name=^/${container}$)" == "" ]; then
            echo "$(date): Restartuję kontener $container" | tee -a "$LOG_FILE"
            docker start "$container" >/dev/null 2>&1 || docker run -d --name "$container" alpine sleep infinity
        fi
    done
    sleep 10
done
EOF
chmod +x "$SERVICE_DIR/$SCRIPT_RESTART"
chown $SERVICE_USER:$SERVICE_USER "$SERVICE_DIR/$SCRIPT_RESTART"

# 5. Utwórz skrypt startowy (opcjonalny, ręczny start kontenerów)
cat > "$SERVICE_DIR/$SCRIPT_START" << 'EOF'
#!/bin/bash
# Ręczne uruchamianie kontenerów

echo "$(date): Uruchamiam kontenery..." | tee -a /home/crankk/startup.log

for container in crankk crankk-pktfwd crankk-terminal watchtower miner grafana db honeygain earnapp pawnsapp gaganode piphi-network-image crankk-update; do
    if [ "$(docker ps -q -f name=^/${container}$)" == "" ]; then
        echo "$(date): Startuję kontener $container" | tee -a /home/crankk/startup.log
        docker start "$container" >/dev/null 2>&1 || docker run -d --name "$container" alpine sleep infinity
    else
        echo "$(date): $container już działa" | tee -a /home/crankk/startup.log
    fi
done
EOF
chmod +x "$SERVICE_DIR/$SCRIPT_START"
chown $SERVICE_USER:$SERVICE_USER "$SERVICE_DIR/$SCRIPT_START"

# 6. Utwórz puste pliki logów, jeśli nie istnieją
touch "$LOG_FILE" "$STARTUP_LOG"
chown $SERVICE_USER:$SERVICE_USER "$LOG_FILE" "$STARTUP_LOG"

# 7. Utwórz usługę systemd
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Auto Restart Docker Containers
After=docker.service
Requires=docker.service

[Service]
ExecStart=$SERVICE_DIR/$SCRIPT_RESTART
Restart=always
User=$SERVICE_USER
WorkingDirectory=$SERVICE_DIR

[Install]
WantedBy=multi-user.target
EOF

# 8. Włącz usługę
systemctl daemon-reload
systemctl enable --now $SERVICE_NAME

echo "=== Instalacja zakończona! ==="
echo "Usługa: systemctl status $SERVICE_NAME"
echo "Logi: $LOG_FILE"
echo "Startowy log: $STARTUP_LOG"
