#!/bin/bash

# Define colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Default ports
GRAFANA_PORT=3000
PROMETHEUS_PORT=9090
NODE_EXPORTER_PORT=9100
PROMTAIL_PORT=9080
LOKI_PORT=3100
NVIDIA_EXPORTER_PORT=9400

# Function to check for script updates
check_for_updates() {
    echo -e "${YELLOW}Checking for script updates...${NC}"
    TMP_SCRIPT="/tmp/script-monitoring-grafana.sh"
    
    # Download the latest version
    if wget -q https://raw.githubusercontent.com/yourusername/script-monitoring-grafana/main/script-monitoring-grafana.sh -O $TMP_SCRIPT; then
        # Compare with current version
        if ! cmp -s "$0" "$TMP_SCRIPT"; then
            echo -e "${GREEN}New version found! Updating script...${NC}"
            cp "$TMP_SCRIPT" "$0"
            chmod +x "$0"
            echo -e "${GREEN}Script updated successfully! Please run the script again.${NC}"
            rm "$TMP_SCRIPT"
            exit 0
        else
            echo -e "${GREEN}Script is up to date.${NC}"
            rm "$TMP_SCRIPT"
        fi
    else
        echo -e "${RED}Failed to check for updates. Continuing with current version...${NC}"
    fi
}

# My sign
print_sign() {
    echo -e "${YELLOW}
    ███████╗ █████╗ ████████╗    ██████╗ ███████╗ ██████╗ 
    ██╔════╝██╔══██╗╚══██╔══╝    ██╔══██╗██╔════╝██╔═══██╗
    █████╗  ███████║   ██║       ██████╔╝█████╗  ██║   ██║
    ██╔══╝  ██╔══██║   ██║       ██╔══██╗██╔══╝  ██║   ██║
    ██║     ██║  ██║   ██║       ██████╔╝███████╗╚██████╔╝
    ╚═╝     ╚═╝  ╚═╝   ╚═╝       ╚═════╝ ╚══════╝ ╚═════╝ 
    ${NC}"
}

# Function to configure ports
configure_ports() {
    echo -e "${YELLOW}Configure ports for components:${NC}"
    read -p "Grafana port (default: $GRAFANA_PORT): " input
    GRAFANA_PORT=${input:-$GRAFANA_PORT}
    
    read -p "Prometheus port (default: $PROMETHEUS_PORT): " input
    PROMETHEUS_PORT=${input:-$PROMETHEUS_PORT}
    
    read -p "Node Exporter port (default: $NODE_EXPORTER_PORT): " input
    NODE_EXPORTER_PORT=${input:-$NODE_EXPORTER_PORT}
    
    read -p "Promtail port (default: $PROMTAIL_PORT): " input
    PROMTAIL_PORT=${input:-$PROMTAIL_PORT}
    
    read -p "Loki port (default: $LOKI_PORT): " input
    LOKI_PORT=${input:-$LOKI_PORT}
    
    read -p "NVIDIA Exporter port (default: $NVIDIA_EXPORTER_PORT): " input
    NVIDIA_EXPORTER_PORT=${input:-$NVIDIA_EXPORTER_PORT}
    
    # Update Grafana configuration if installed
    if [ -f "/etc/grafana/grafana.ini" ]; then
        echo -e "${YELLOW}Updating Grafana configuration...${NC}"
        sudo sed -i "s/http_port = .*/http_port = $GRAFANA_PORT/" /etc/grafana/grafana.ini
        sudo systemctl restart grafana-server
    fi
    
    # Update Prometheus configuration if installed
    if [ -f "/etc/prometheus/prometheus.yml" ]; then
        echo -e "${YELLOW}Updating Prometheus configuration...${NC}"
        # Update Prometheus own port
        sudo sed -i "s/--web.listen-address=0.0.0.0:.*/--web.listen-address=0.0.0.0:$PROMETHEUS_PORT/" /etc/systemd/system/prometheus.service
        sudo sed -i "s/targets: \['0.0.0.0:.*'\]/targets: ['0.0.0.0:$PROMETHEUS_PORT']/" /etc/prometheus/prometheus.yml
        
        # Update Node Exporter target if exists
        if grep -q "job_name: 'node'" /etc/prometheus/prometheus.yml; then
            sudo sed -i "s/targets: \['0.0.0.0:.*'\]/targets: ['0.0.0.0:$NODE_EXPORTER_PORT']/" /etc/prometheus/prometheus.yml
        fi
        
        # Update NVIDIA Exporter target if exists
        if grep -q "job_name: 'nvidia_gpu'" /etc/prometheus/prometheus.yml; then
            sudo sed -i "s/targets: \['0.0.0.0:.*'\]/targets: ['0.0.0.0:$NVIDIA_EXPORTER_PORT']/" /etc/prometheus/prometheus.yml
        fi
        
        sudo systemctl restart prometheus
    fi
    
    # Update Node Exporter configuration if installed
    if [ -f "/etc/systemd/system/node_exporter.service" ]; then
        echo -e "${YELLOW}Updating Node Exporter configuration...${NC}"
        sudo sed -i "s/--web.listen-address=0.0.0.0:.*/--web.listen-address=0.0.0.0:$NODE_EXPORTER_PORT/" /etc/systemd/system/node_exporter.service
        sudo systemctl restart node_exporter
    fi
    
    # Update Promtail configuration if installed
    if [ -f "/etc/promtail/config.yml" ]; then
        echo -e "${YELLOW}Updating Promtail configuration...${NC}"
        sudo sed -i "s/http_listen_port: .*/http_listen_port: $PROMTAIL_PORT/" /etc/promtail/config.yml
        sudo sed -i "s|url: http://0.0.0.0:.*/loki/api/v1/push|url: http://0.0.0.0:$LOKI_PORT/loki/api/v1/push|" /etc/promtail/config.yml
        sudo systemctl restart promtail
    fi
    
    # Update Loki configuration if installed
    if [ -f "/etc/loki/config.yml" ]; then
        echo -e "${YELLOW}Updating Loki configuration...${NC}"
        sudo sed -i "s/http_listen_port: .*/http_listen_port: $LOKI_PORT/" /etc/loki/config.yml
        sudo systemctl restart loki
    fi
    
    # Update NVIDIA Exporter configuration if installed
    if [ -f "/etc/systemd/system/dcgm-exporter.service" ]; then
        echo -e "${YELLOW}Updating NVIDIA Exporter configuration...${NC}"
        sudo sed -i "s/--address=0.0.0.0:.*/--address=0.0.0.0:$NVIDIA_EXPORTER_PORT/" /etc/systemd/system/dcgm-exporter.service
        sudo systemctl restart dcgm-exporter
    fi
    
    echo -e "${GREEN}Ports configured successfully!${NC}"
}

# Function to install Grafana
install_grafana() {
    echo -e "${YELLOW}Installing Grafana...${NC}"
    
    # Add Grafana GPG key
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    
    # Add Grafana repository
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    
    # Update package list
    sudo apt update
    
    # Install Grafana
    if sudo apt install grafana -y; then
        # Configure Grafana port and address
        sudo sed -i "s/;http_port = 3000/http_port = $GRAFANA_PORT/" /etc/grafana/grafana.ini
        sudo sed -i "s/;http_addr = /http_addr = 0.0.0.0/" /etc/grafana/grafana.ini
        sudo systemctl restart grafana-server
        
        echo -e "${GREEN}Grafana installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install Grafana.${NC}"
        return 1
    fi
}

# Function to install Prometheus
install_prometheus() {
    echo -e "${YELLOW}Installing Prometheus...${NC}"
    
    # Create prometheus user
    sudo useradd --no-create-home --shell /bin/false prometheus
    
    # Create directories
    sudo mkdir -p /etc/prometheus
    sudo mkdir -p /var/lib/prometheus
    
    # Download Prometheus
    PROMETHEUS_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget https://github.com/prometheus/prometheus/releases/download/${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION#v}.linux-amd64.tar.gz
    
    # Extract and install
    tar xvf prometheus-*.tar.gz
    cd prometheus-*/
    sudo cp prometheus /usr/local/bin/
    sudo cp promtool /usr/local/bin/
    sudo cp -r consoles/ /etc/prometheus
    sudo cp -r console_libraries/ /etc/prometheus
    cd ..
    rm -rf prometheus-*
    
    # Configure Prometheus
    cat << EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['0.0.0.0:$PROMETHEUS_PORT']
EOF

    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:$PROMETHEUS_PORT

[Install]
WantedBy=multi-user.target
EOF

    # Set permissions
    sudo chown -R prometheus:prometheus /etc/prometheus
    sudo chown -R prometheus:prometheus /var/lib/prometheus
    
    # Start service
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl enable prometheus
    
    if sudo systemctl is-active --quiet prometheus; then
        echo -e "${GREEN}Prometheus installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install Prometheus.${NC}"
        return 1
    fi
}

# Function to install Node Exporter
install_node_exporter() {
    echo -e "${YELLOW}Installing Node Exporter...${NC}"
    
    # Create node_exporter user
    sudo useradd --no-create-home --shell /bin/false node_exporter
    
    # Download Node Exporter
    NODE_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget https://github.com/prometheus/node_exporter/releases/download/${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION#v}.linux-amd64.tar.gz
    
    # Extract and install
    tar xvf node_exporter-*.tar.gz
    sudo cp node_exporter-*/node_exporter /usr/local/bin/
    rm -rf node_exporter-*
    
    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:$NODE_EXPORTER_PORT

[Install]
WantedBy=multi-user.target
EOF

    # Start service
    sudo systemctl daemon-reload
    sudo systemctl start node_exporter
    sudo systemctl enable node_exporter
    
    # Add to Prometheus config
    sudo sed -i '/scrape_configs:/a\  - job_name: '\''node'\''\n    static_configs:\n      - targets: ['\''0.0.0.0:'$NODE_EXPORTER_PORT'\'']' /etc/prometheus/prometheus.yml
    sudo systemctl restart prometheus
    
    if sudo systemctl is-active --quiet node_exporter; then
        echo -e "${GREEN}Node Exporter installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install Node Exporter.${NC}"
        return 1
    fi
}

# Function to install Promtail
install_promtail() {
    echo -e "${YELLOW}Installing Promtail...${NC}"
    
    # Download Promtail
    LOKI_VERSION=$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/promtail-linux-amd64.zip
    unzip promtail-linux-amd64.zip
    sudo mv promtail-linux-amd64 /usr/local/bin/promtail
    
    # Create config directory
    sudo mkdir -p /etc/promtail
    
    # Create config file
    cat << EOF | sudo tee /etc/promtail/config.yml
server:
  http_listen_address: 0.0.0.0
  http_listen_port: $PROMTAIL_PORT
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://0.0.0.0:$LOKI_PORT/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
    - targets:
        - 0.0.0.0
      labels:
        job: varlogs
        __path__: /var/log/*log
EOF

    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/promtail.service
[Unit]
Description=Promtail
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yml

[Install]
WantedBy=multi-user.target
EOF

    # Start service
    sudo systemctl daemon-reload
    sudo systemctl start promtail
    sudo systemctl enable promtail
    
    if sudo systemctl is-active --quiet promtail; then
        echo -e "${GREEN}Promtail installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install Promtail.${NC}"
        return 1
    fi
}

# Function to install Loki
install_loki() {
    echo -e "${YELLOW}Installing Loki...${NC}"
    
    # Download Loki
    LOKI_VERSION=$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/loki-linux-amd64.zip
    unzip loki-linux-amd64.zip
    sudo mv loki-linux-amd64 /usr/local/bin/loki
    
    # Create config directory
    sudo mkdir -p /etc/loki
    
    # Create config file
    cat << EOF | sudo tee /etc/loki/config.yml
auth_enabled: false

server:
  http_listen_address: 0.0.0.0
  http_listen_port: $LOKI_PORT

ingester:
  lifecycler:
    address: 0.0.0.0
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2020-05-15
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /tmp/loki/index

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
EOF

    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/loki.service
[Unit]
Description=Loki
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/loki -config.file=/etc/loki/config.yml

[Install]
WantedBy=multi-user.target
EOF

    # Start service
    sudo systemctl daemon-reload
    sudo systemctl start loki
    sudo systemctl enable loki
    
    if sudo systemctl is-active --quiet loki; then
        echo -e "${GREEN}Loki installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install Loki.${NC}"
        return 1
    fi
}

# Function to install NVIDIA Prometheus Exporter
install_nvidia_prometheus() {
    echo -e "${YELLOW}Installing NVIDIA Prometheus Exporter...${NC}"
    
    # Check if NVIDIA drivers are installed
    if ! command -v nvidia-smi &> /dev/null; then
        echo -e "${RED}NVIDIA drivers are not installed. Please install drivers first.${NC}"
        return 1
    fi
    
    # Download DCGM Exporter
    wget https://github.com/NVIDIA/dcgm-exporter/releases/latest/download/dcgm-exporter
    chmod +x dcgm-exporter
    sudo mv dcgm-exporter /usr/local/bin/
    
    # Create systemd service
    cat << EOF | sudo tee /etc/systemd/system/dcgm-exporter.service
[Unit]
Description=NVIDIA DCGM Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dcgm-exporter --address=0.0.0.0:$NVIDIA_EXPORTER_PORT

[Install]
WantedBy=multi-user.target
EOF

    # Start service
    sudo systemctl daemon-reload
    sudo systemctl start dcgm-exporter
    sudo systemctl enable dcgm-exporter
    
    # Add to Prometheus config
    sudo sed -i '/scrape_configs:/a\  - job_name: '\''nvidia_gpu'\''\n    static_configs:\n      - targets: ['\''0.0.0.0:'$NVIDIA_EXPORTER_PORT'\'']' /etc/prometheus/prometheus.yml
    sudo systemctl restart prometheus
    
    if sudo systemctl is-active --quiet dcgm-exporter; then
        echo -e "${GREEN}NVIDIA Prometheus Exporter installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Failed to install NVIDIA Prometheus Exporter.${NC}"
        return 1
    fi
}

# Function to remove all components
remove_all_components() {
    echo -e "${YELLOW}Removing all monitoring components...${NC}"
    local success=true

    # Stop and remove services
    local services=("grafana-server" "prometheus" "node_exporter" "promtail" "loki" "dcgm-exporter")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo -e "Stopping and removing $service..."
            sudo systemctl stop $service
            sudo systemctl disable $service
            sudo rm -f /etc/systemd/system/$service.service
        fi
    done

    # Remove Grafana
    if dpkg -l | grep -q grafana; then
        echo -e "Removing Grafana..."
        sudo apt-get remove --purge grafana -y
        sudo rm -rf /etc/grafana
        sudo rm -rf /var/lib/grafana
    fi

    # Remove Prometheus
    if [ -d "/etc/prometheus" ]; then
        echo -e "Removing Prometheus..."
        sudo rm -rf /etc/prometheus
        sudo rm -rf /var/lib/prometheus
        sudo rm -f /usr/local/bin/prometheus
        sudo rm -f /usr/local/bin/promtool
        sudo userdel prometheus
    fi

    # Remove Node Exporter
    if [ -f "/usr/local/bin/node_exporter" ]; then
        echo -e "Removing Node Exporter..."
        sudo rm -f /usr/local/bin/node_exporter
        sudo userdel node_exporter
    fi

    # Remove Promtail
    if [ -f "/usr/local/bin/promtail" ]; then
        echo -e "Removing Promtail..."
        sudo rm -rf /etc/promtail
        sudo rm -f /usr/local/bin/promtail
    fi

    # Remove Loki
    if [ -f "/usr/local/bin/loki" ]; then
        echo -e "Removing Loki..."
        sudo rm -rf /etc/loki
        sudo rm -f /usr/local/bin/loki
        sudo rm -rf /tmp/loki
    fi

    # Remove NVIDIA DCGM Exporter
    if [ -f "/usr/local/bin/dcgm-exporter" ]; then
        echo -e "Removing NVIDIA DCGM Exporter..."
        sudo rm -f /usr/local/bin/dcgm-exporter
    fi

    # Reload systemd
    sudo systemctl daemon-reload

    # Remove APT repository
    sudo rm -f /etc/apt/sources.list.d/grafana.list
    sudo apt-get update

    echo -e "${GREEN}All components have been removed successfully!${NC}"
}

# Function to handle multiple selections
handle_selections() {
    local selections=("$@")
    local success=true
    
    # Install selected components
    for selection in "${selections[@]}"; do
        case $selection in
            1)
                install_grafana || success=false
                ;;
            2)
                install_prometheus || success=false
                ;;
            3)
                install_node_exporter || success=false
                ;;
            4)
                install_promtail || success=false
                ;;
            5)
                install_loki || success=false
                ;;
            6)
                install_nvidia_prometheus || success=false
                ;;
        esac
    done
    
    if [ "$success" = true ]; then
        echo -e "${GREEN}All selected components have been installed successfully!${NC}"
        echo -e "${GREEN}You can access the components at:${NC}"
        echo -e "Grafana: http://0.0.0.0:$GRAFANA_PORT"
        echo -e "Prometheus: http://0.0.0.0:$PROMETHEUS_PORT"
        echo -e "Node Exporter: http://0.0.0.0:$NODE_EXPORTER_PORT"
        echo -e "Promtail: http://0.0.0.0:$PROMTAIL_PORT"
        echo -e "Loki: http://0.0.0.0:$LOKI_PORT"
        echo -e "NVIDIA Exporter: http://0.0.0.0:$NVIDIA_EXPORTER_PORT"
    else
        echo -e "${RED}Some components failed to install. Please check the logs.${NC}"
    fi
}

# Check if the script is running with root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Please use sudo.${NC}"
    exit 1
else
    print_sign
    echo -e "${YELLOW}Updating package lists and upgrading packages...${NC}"
    if ! (sudo apt update && sudo apt upgrade -y); then
        echo -e "${RED}Failed to update and upgrade packages. Continuing...${NC}"
    fi
    
    echo -e "\n${GREEN}Select components to install:${NC}"
    echo "1. Grafana"
    echo "2. Prometheus"
    echo "3. Node Exporter"
    echo "4. Promtail"
    echo "5. Loki"
    echo "6. NVIDIA Prometheus Exporter"
    echo "7. Configure Ports"
    echo "8. Remove All Components"
    echo -e "\n${YELLOW}Enter the corresponding numbers separated by spaces (e.g., 2 3 4):${NC}"
    
    read -a selections
    
    # Check if input is empty
    if [ ${#selections[@]} -eq 0 ]; then
        echo -e "${RED}Please select at least one option!${NC}"
        exit 1
    fi
    
    # Check for remove all option
    for selection in "${selections[@]}"; do
        if [ "$selection" = "8" ]; then
            read -p "Are you sure you want to remove all components? This action cannot be undone. (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                remove_all_components
            fi
            exit 0
        fi
    done
    
    # Check if port configuration is selected
    for selection in "${selections[@]}"; do
        if [ "$selection" = "7" ]; then
            configure_ports
            # Remove 7 from selections array
            selections=("${selections[@]/7}")
            break
        fi
    done
    
    # Process selections
    handle_selections "${selections[@]}"
fi
