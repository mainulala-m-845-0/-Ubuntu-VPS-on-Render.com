#!/usr/bin/env bash
set -e

# ═══════════════════════════════════════════════════════════════
#  Configuration (override via Render environment variables)
# ═══════════════════════════════════════════════════════════════
PORT="${PORT:-10000}"
VPS_USER="${VPS_USER:-ubuntu}"
VPS_PASS="${VPS_PASS:-ubuntu123}"

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║         🐧  Ubuntu VPS — Starting Up          ║"
echo "╠═══════════════════════════════════════════════╣"
echo "║  User : ${VPS_USER}                            "
echo "║  Port : ${PORT}                                "
echo "╚═══════════════════════════════════════════════╝"
echo ""

# ── Create / configure VPS user ──────────────────────────────────
if ! id "${VPS_USER}" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo,adm "${VPS_USER}"
fi
echo "${VPS_USER}:${VPS_PASS}" | chpasswd
echo "${VPS_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vps-user
chmod 0440 /etc/sudoers.d/vps-user

# ── Home directories ────────────────────────────────────────────
HOME_DIR="/home/${VPS_USER}"
mkdir -p "${HOME_DIR}"/{workspace,downloads,scripts,.config}

# ── Custom .bashrc ───────────────────────────────────────────────
cat > "${HOME_DIR}/.bashrc" << 'BASHRC_END'
# ── Environment ──
export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin:${HOME}/.local/bin"
export EDITOR=nano
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups

# ── Prompt (Kali-style) ──
PS1='\[\e[1;32m\]┌──(\[\e[1;34m\]\u@ubuntu-vps\[\e[1;32m\])-[\[\e[0;1m\]\w\[\e[1;32m\]]\n\[\e[1;32m\]└─\[\e[1;34m\]\$\[\e[0m\] '

# ── Aliases ──
alias ll='ls -alFh --color=auto --group-directories-first'
alias la='ls -Ah --color=auto'
alias l='ls -CFh --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# ── VPS shortcuts ──
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install -y'
alias remove='sudo apt remove -y'
alias search='apt search'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me && echo'
alias localip='hostname -I | awk "{print \$1}"'
alias meminfo='free -h && echo "" && cat /proc/meminfo | head -5'
alias diskinfo='df -h && echo "" && lsblk 2>/dev/null'
alias cpuinfo='lscpu | head -20'
alias sysinfo='neofetch'
alias listening='ss -tulnp | grep LISTEN'
alias connections='ss -tunp'
alias topmem='ps aux --sort=-%mem | head -11'
alias topcpu='ps aux --sort=-%cpu | head -11'
alias speed='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'
alias weather='curl wttr.in/?format=3'
alias serve='python3 -m http.server'
alias path='echo $PATH | tr ":" "\n"'

# ── Functions ──
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' unknown archive type" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
sysload() {
    echo -e "\n\e[1;36m═══ System Load ═══\e[0m"
    uptime
    echo -e "\n\e[1;36m═══ Memory ═══\e[0m"
    free -h
    echo -e "\n\e[1;36m═══ Disk ═══\e[0m"
    df -h /
    echo -e "\n\e[1;36m═══ Top Processes ═══\e[0m"
    ps aux --sort=-%mem | head -6
    echo ""
}
help-vps() {
    echo -e "\n\e[1;36m╔═══════════════════════════════════════════════════╗"
    echo -e "║           \e[1;33m⚡ Ubuntu VPS — Quick Reference\e[1;36m         ║"
    echo -e "╠═══════════════════════════════════════════════════╣"
    echo -e "║\e[0m  sysinfo      System info (neofetch)              \e[1;36m║"
    echo -e "║\e[0m  sysload      CPU / RAM / disk overview           \e[1;36m║"
    echo -e "║\e[0m  myip         Public IP address                   \e[1;36m║"
    echo -e "║\e[0m  meminfo      Memory details                     \e[1;36m║"
    echo -e "║\e[0m  diskinfo     Disk usage                         \e[1;36m║"
    echo -e "║\e[0m  cpuinfo      CPU information                    \e[1;36m║"
    echo -e "║\e[0m  ports        Open ports                         \e[1;36m║"
    echo -e "║\e[0m  topmem       Top memory consumers               \e[1;36m║"
    echo -e "║\e[0m  topcpu       Top CPU consumers                  \e[1;36m║"
    echo -e "║\e[0m  update       apt update + upgrade               \e[1;36m║"
    echo -e "║\e[0m  install X    Install package                    \e[1;36m║"
    echo -e "║\e[0m  serve        Start HTTP server (port 8000)      \e[1;36m║"
    echo -e "║\e[0m  extract X    Extract any archive                \e[1;36m║"
    echo -e "║\e[0m  mkcd X       mkdir + cd                         \e[1;36m║"
    echo -e "║\e[0m  speed        Internet speed test                \e[1;36m║"
    echo -e "║\e[0m  weather      Current weather                    \e[1;36m║"
    echo -e "╚═══════════════════════════════════════════════════╝\e[0m\n"
}

# ── Welcome message ──
if [ -z "${WELCOMED}" ]; then
    export WELCOMED=1
    clear
    neofetch 2>/dev/null || echo "Ubuntu VPS"
    echo ""
    echo -e "\e[1;36m══════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;33m   ⚡ Ubuntu VPS is ready!                        \e[0m"
    echo -e "\e[0;37m   Type \e[1;32mhelp-vps\e[0;37m for available commands            \e[0m"
    echo -e "\e[1;36m══════════════════════════════════════════════════\e[0m"
    echo ""
fi
BASHRC_END

chown -R "${VPS_USER}:${VPS_USER}" "${HOME_DIR}"

# ── Generate nginx.conf ────────────────────────────────────────
sed "s/PORT_PLACEHOLDER/${PORT}/g" /app/nginx.conf.template > /etc/nginx/nginx.conf

# ── Generate htpasswd (basic auth) ──────────────────────────────
echo "${VPS_USER}:$(openssl passwd -apr1 "${VPS_PASS}")" > /etc/nginx/.htpasswd

# ── Stats generator ─────────────────────────────────────────────
cat > /app/stats-loop.sh << 'STATSEOF'
#!/bin/bash
while true; do
    MEM_TOTAL=$(free -m | awk '/Mem:/{print $2}')
    MEM_USED=$(free -m  | awk '/Mem:/{print $3}')
    MEM_FREE=$(free -m  | awk '/Mem:/{print $4}')
    [ "$MEM_TOTAL" -gt 0 ] 2>/dev/null && MEM_PCT=$((MEM_USED*100/MEM_TOTAL)) || MEM_PCT=0

    DISK_TOTAL=$(df -BM / | awk 'NR==2{gsub(/M/,"",$2);print $2}')
    DISK_USED=$(df -BM /  | awk 'NR==2{gsub(/M/,"",$3);print $3}')
    DISK_FREE=$(df -BM /  | awk 'NR==2{gsub(/M/,"",$4);print $4}')
    DISK_PCT=$(df / | awk 'NR==2{gsub(/%/,"",$5);print $5}')

    LOAD_1=$(cat /proc/loadavg | awk '{print $1}')
    LOAD_5=$(cat /proc/loadavg | awk '{print $2}')
    CORES=$(nproc 2>/dev/null || echo 1)
    PROCS=$(ps aux --no-heading 2>/dev/null | wc -l)
    UPTIME_STR=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
    HOSTNAME_STR=$(hostname 2>/dev/null || echo "vps")
    KERNEL=$(uname -r 2>/dev/null || echo "N/A")

    cat > /var/www/dashboard/stats.json << SJEOF
{
  "hostname":"${HOSTNAME_STR}",
  "kernel":"${KERNEL}",
  "uptime":"${UPTIME_STR}",
  "cores":${CORES},
  "load1":"${LOAD_1}",
  "load5":"${LOAD_5}",
  "mem_total":${MEM_TOTAL},
  "mem_used":${MEM_USED},
  "mem_free":${MEM_FREE},
  "mem_pct":${MEM_PCT},
  "disk_total":${DISK_TOTAL},
  "disk_used":${DISK_USED},
  "disk_free":${DISK_FREE},
  "disk_pct":${DISK_PCT},
  "procs":${PROCS},
  "ts":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
SJEOF
    sleep 4
done
STATSEOF
chmod +x /app/stats-loop.sh

# ── Supervisor configuration ────────────────────────────────────
cat > /etc/supervisor/conf.d/vps.conf << SUPEOF
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
user=root

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
priority=10
stdout_logfile=/var/log/supervisor/nginx-out.log
stderr_logfile=/var/log/supervisor/nginx-err.log

[program:ttyd]
command=ttyd
    --writable
    --port 7681
    --base-path /terminal
    --ping-interval 30
    su - ${VPS_USER}
autostart=true
autorestart=true
priority=20
stdout_logfile=/var/log/supervisor/ttyd-out.log
stderr_logfile=/var/log/supervisor/ttyd-err.log

[program:filebrowser]
command=filebrowser
    --noauth
    --address 127.0.0.1
    --port 8080
    --baseurl /files
    --root ${HOME_DIR}
    --database /tmp/filebrowser.db
autostart=true
autorestart=true
priority=30
stdout_logfile=/var/log/supervisor/fb-out.log
stderr_logfile=/var/log/supervisor/fb-err.log

[program:stats]
command=/app/stats-loop.sh
autostart=true
autorestart=true
priority=40
stdout_logfile=/dev/null
stderr_logfile=/dev/null

[program:sshd]
command=/usr/sbin/sshd -D
autostart=true
autorestart=true
priority=50
stdout_logfile=/var/log/supervisor/sshd-out.log
stderr_logfile=/var/log/supervisor/sshd-err.log
SUPEOF

# ── Prepare SSHD ────────────────────────────────────────────────
mkdir -p /run/sshd
ssh-keygen -A 2>/dev/null
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/'       /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ── Initial stats file ──────────────────────────────────────────
echo '{"hostname":"vps","uptime":"starting","cores":1,"load1":"0","load5":"0","mem_total":0,"mem_used":0,"mem_free":0,"mem_pct":0,"disk_total":0,"disk_used":0,"disk_free":0,"disk_pct":0,"procs":0,"ts":""}' \
    > /var/www/dashboard/stats.json

echo ""
echo "✅  All services starting on port ${PORT}"
echo "    Dashboard  →  /            "
echo "    Terminal   →  /terminal/   "
echo "    Files      →  /files/      "
echo ""

# ── Launch ───────────────────────────────────────────────────────
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/vps.conf
