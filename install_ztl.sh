#!/bin/bash
set -e

INSTALL_DIR="/root/Zero-Trust-Lite"
SERVICE_FILE="/lib/systemd/system/ztl.service"

echo "[EN] Creating directory: $INSTALL_DIR"
echo "[CN] 创建目录: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[EN] Fetching latest Zero-Trust-Lite release info..."
echo "[CN] 获取最新 Zero-Trust-Lite Release 信息..."
API_JSON=$(curl -s https://api.github.com/repos/Usagi537233/Zero-Trust-Lite/releases/latest)

echo "[EN] Selecting asset exactly named 'zero-trust-lite'..."
echo "[CN] 精确匹配名字为 'zero-trust-lite' 的 Linux 可执行文件..."

DOWNLOAD_URL=$(echo "$API_JSON" \
    | jq -r '.assets[] | select(.name == "zero-trust-lite") | .browser_download_url')

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
    echo "[EN] ERROR: No asset named 'zero-trust-lite' found."
    echo "[CN] 错误：未找到名为 'zero-trust-lite' 的文件。"
    exit 1
fi

echo "[EN] Downloading zero-trust-lite (directly into folder)..."
echo "[CN] 正在下载 zero-trust-lite（直接保存到目录）..."

# ⭐ 关键：直接下载到当前目录，不指定文件名，不重命名
curl -LO "$DOWNLOAD_URL"

# 给 Zero-Trust-Lite 加执行权限
chmod +x zero-trust-lite

echo "[EN] Creating start.sh"
echo "[CN] 创建 start.sh"
cat > start.sh <<'EOF'
#!/bin/bash
nohup ./zero-trust-lite -c config.json > /dev/null 2>&1 &
EOF
chmod +x start.sh

echo "[EN] Creating systemd service"
echo "[CN] 创建 systemd 服务"
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Zero-Trust-Lite
After=network.target

[Service]
Type=forking
User=root
Group=root
WorkingDirectory=/root/Zero-Trust-Lite
KillMode=control-group
Restart=no
ExecStart=/root/Zero-Trust-Lite/start.sh

[Install]
WantedBy=multi-user.target
EOF

echo "[EN] Reloading systemd"
echo "[CN] 重载 systemd"
systemctl daemon-reload

echo "[EN] Enabling ztl.service on boot"
echo "[CN] 设置 ztl.service 开机启动"
systemctl enable ztl.service

echo "[EN] Starting ztl.service"
echo "[CN] 启动 ztl.service"
systemctl start ztl.service

echo "[EN] Zero-Trust-Lite installation completed!"
echo "[CN] Zero-Trust-Lite 安装完成！"
