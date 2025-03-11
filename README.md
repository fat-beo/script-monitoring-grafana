# Grafana Monitoring Stack Installation Script

# Script Cài đặt Grafana Monitoring Stack

## Description / Mô tả

This script automates the installation of Grafana monitoring stack components on Ubuntu/Debian systems. It provides a user-friendly interface with colored output, automatic system updates, and verification steps to ensure successful installation.

Script này tự động hóa quá trình cài đặt các thành phần của Grafana monitoring stack trên các hệ thống Ubuntu/Debian. Cung cấp giao diện thân thiện với người dùng thông qua các thông báo màu sắc, tự động cập nhật hệ thống và các bước xác minh để đảm bảo cài đặt thành công.

[![GitHub](https://img.shields.io/github/license/fat-beo/script-monitoring-grafana)](https://github.com/fat-beo/script-monitoring-grafana/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/fat-beo/script-monitoring-grafana)](https://github.com/fat-beo/script-monitoring-grafana/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/fat-beo/script-monitoring-grafana)](https://github.com/fat-beo/script-monitoring-grafana/issues)

## Table of Contents / Mục lục

- [English](#english)
  - [Features](#features)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Notes](#notes)
- [Tiếng Việt](#tiếng-việt)
  - [Tính năng](#tính-năng)
  - [Cài đặt](#cài-đặt)
  - [Sử dụng](#sử-dụng)
  - [Lưu ý](#lưu-ý)

## English

### Features

- Automatic system updates before installation
- Installation verification
- Colored output for better progress tracking
- Configurable ports for all components
- Optional component selection
- Auto-update functionality for the script itself

### Installation

```bash
# Remove old script if exists
rm -f script-monitoring-grafana.sh*

# Download script from GitHub
wget https://raw.githubusercontent.com/fat-beo/script-monitoring-grafana/main/script-monitoring-grafana.sh

# Make script executable
chmod +x script-monitoring-grafana.sh
```

### Usage

1. Run the script with sudo:

```bash
sudo ./script-monitoring-grafana.sh
```

2. Choose one or more of the following options:

- `1`: Grafana
- `2`: Prometheus
- `3`: Node Exporter
- `4`: Promtail
- `5`: Loki
- `6`: NVIDIA Prometheus Exporter
- `7`: Configure Ports
- `8`: Remove All Components

### Notes

- Root privileges are required to run the script
- Default ports for components:
  - Grafana: 3000
  - Prometheus: 9090
  - Node Exporter: 9100
  - Promtail: 9080
  - Loki: 3100
  - NVIDIA Exporter: 9400
- All services are configured to listen on 0.0.0.0 for external access
- You can select multiple components by entering their numbers separated by spaces (e.g., `2 3 4`)

## Target Configuration Guide

### Configuring Prometheus and Loki

1. Open Prometheus configuration:
```bash
sudo nano /etc/prometheus/prometheus.yml
```

2. Example configuration for adding a new target:
```yaml
scrape_configs:
  - job_name: 'my_new_target'
    static_configs:
      - targets: ['192.168.1.100:9100']
    labels:
      location: 'server_room'
      environment: 'production'
```

3. Save the file:
   - Press `Ctrl + X`
   - Press `Y`
   - Press `Enter`

4. Check configuration and restart:
```bash
# Check syntax
sudo promtool check config /etc/prometheus/prometheus.yml

# Restart if syntax is correct
sudo systemctl restart prometheus
```

### Important Notes

1. Before adding target:
```bash
# Open port in firewall
sudo ufw allow target_port/tcp

# Test connection
telnet target_ip target_port
```

2. After adding target:
- Check Prometheus UI:
  - http://your_server:9090/targets
- Check Grafana:
  - http://your_server:3000

3. If there are issues:
```bash
# View Prometheus logs
sudo journalctl -u prometheus -f

# View target metrics
curl http://target_ip:target_port/metrics
```

## Tiếng Việt

### Tính năng

- Tự động cập nhật hệ thống trước khi cài đặt
- Kiểm tra và xác minh cài đặt
- Hiển thị thông báo màu sắc để dễ theo dõi tiến trình
- Cấu hình port cho tất cả các thành phần
- Lựa chọn thành phần tùy ý
- Tự động cập nhật script khi có phiên bản mới

### Cài đặt

```bash
# Xóa script cũ nếu tồn tại
rm -f script-monitoring-grafana.sh*

# Tải script từ GitHub
wget https://raw.githubusercontent.com/fat-beo/script-monitoring-grafana/main/script-monitoring-grafana.sh

# Cấp quyền thực thi cho script
chmod +x script-monitoring-grafana.sh
```

### Sử dụng

1. Chạy script với quyền sudo:

```bash
sudo ./script-monitoring-grafana.sh
```

2. Chọn một hoặc nhiều tùy chọn sau:

- `1`: Grafana
- `2`: Prometheus
- `3`: Node Exporter
- `4`: Promtail
- `5`: Loki
- `6`: NVIDIA Prometheus Exporter
- `7`: Cấu hình Ports
- `8`: Xóa Tất Cả Thành Phần

### Lưu ý

- Script yêu cầu quyền root để chạy
- Port mặc định cho các thành phần:
  - Grafana: 3000
  - Prometheus: 9090
  - Node Exporter: 9100
  - Promtail: 9080
  - Loki: 3100
  - NVIDIA Exporter: 9400
- Tất cả các dịch vụ được cấu hình để lắng nghe trên 0.0.0.0 để cho phép truy cập từ bên ngoài
- Bạn có thể chọn nhiều thành phần bằng cách nhập số của chúng cách nhau bởi dấu cách (ví dụ: `2 3 4`)

## Target Configuration Guide

### Configuring Prometheus and Loki

1. Open Prometheus configuration:
```bash
sudo nano /etc/prometheus/prometheus.yml
```

2. Example configuration for adding a new target:
```yaml
scrape_configs:
  - job_name: 'my_new_target'
    static_configs:
      - targets: ['192.168.1.100:9100']
    labels:
      location: 'server_room'
      environment: 'production'
```

3. Save the file:
   - Press `Ctrl + X`
   - Press `Y`
   - Press `Enter`

4. Check configuration and restart:
```bash
# Check syntax
sudo promtool check config /etc/prometheus/prometheus.yml

# Restart if syntax is correct
sudo systemctl restart prometheus
```

### Important Notes

1. Before adding target:
```bash
# Open port in firewall
sudo ufw allow target_port/tcp

# Test connection
telnet target_ip target_port
```

2. After adding target:
- Check Prometheus UI:
  - http://your_server:9090/targets
- Check Grafana:
  - http://your_server:3000

3. If there are issues:
```bash
# View Prometheus logs
sudo journalctl -u prometheus -f

# View target metrics
curl http://target_ip:target_port/metrics
```