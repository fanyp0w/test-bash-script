PROC="test"
URL="https://test.com/monitoring/test/api"
LOG="/var/log/monitoring.log"
STATE="/var/lib/monitor_test/state"
LOCK="/var/lock/monitor_test.lock"

mkdir -p "$(dirname "$STATE")"
touch "$STATE" "$LOG"

exec 200>"$LOCK"
flock -n 200 || exit 0  # не запускать одновременно

PID=$(pgrep -x "$PROC" | head -n1)
[[ -z $PID ]] && exit 0

START=$(ps -p "$PID" -o lstart= | xargs)
read -r OLD_PID OLD_START < "$STATE"

if [[ $OLD_PID != "$PID" || "$OLD_START" != "$START" && -n $OLD_PID ]]; then
  echo "$(date '+%F %T') PROCESS RESTARTED: pid=$PID start='$START'" >> "$LOG"
fi

if ! CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL"); then
  echo "$(date '+%F %T') SERVER UNREACHABLE: $URL" >> "$LOG"
elif [[ $CODE != 2?? ]]; then
  echo "$(date '+%F %T') SERVER ERROR: code=$CODE $URL" >> "$LOG"
fi

echo "$PID $START" > "$STATE"
