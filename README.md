## Установка

```bash
sudo cp monitor_test.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor_test.sh
sudo cp monitor_test.service /etc/systemd/system/
sudo cp monitor_test.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now monitor_test.timer
