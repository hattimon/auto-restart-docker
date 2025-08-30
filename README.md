# 🚀 Auto Restart Docker Containers (Raspberry Pi)

Automatyczny monitoring i restart kontenerów Docker.  
Zapewnia, że kontenery zawsze działają, a jeśli padną → zostaną uruchomione ponownie.

## 🔧 Instalacja

1. Pobierz i uruchom instalator:
   ```bash
   wget https://raw.githubusercontent.com/hattimon/auto-restart-docker/main/install-auto-restart.sh
   chmod +x install-auto-restart.sh
   sudo ./install-auto-restart.sh
   ```

2. Skrypt:
   - instaluje `docker` (jeśli go nie ma)
   - pobiera obraz `alpine`
   - tworzy pliki:
     - `/home/crankk/auto_restart_containers.sh`
     - `/home/crankk/start_containers.sh`
     - `/home/crankk/auto_restart_containers.log`
     - `/home/crankk/startup.log`
   - dodaje usługę systemową `auto-restart-containers`

## ▶️ Sterowanie usługą

```bash
# sprawdź status
systemctl status auto-restart-containers

# zatrzymaj usługę
sudo systemctl stop auto-restart-containers

# włącz ponownie
sudo systemctl start auto-restart-containers
```

## 📂 Pliki

- `auto_restart_containers.sh` – główny skrypt monitorujący  
- `start_containers.sh` – ręczny start wszystkich kontenerów  
- `auto_restart_containers.log` – logi monitorowania  
- `startup.log` – logi uruchamiania ręcznego  

## ✨ Zalety

- pełna automatyzacja  
- odporność na restarty systemu  
- docker + alpine zawsze gotowe  
- logi w osobnych plikach
