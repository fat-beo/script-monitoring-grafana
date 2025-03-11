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
  - [Target Configuration Guide](#target-configuration-guide)
- [Tiếng Việt](#tiếng-việt)
  - [Tính năng](#tính-năng)
  - [Cài đặt](#cài-đặt)
  - [Sử dụng](#sử-dụng)
  - [Lưu ý](#lưu-ý)
  - [Hướng dẫn cấu hình thêm target](#hướng-dẫn-cấu-hình-thêm-target)

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
  - NVIDIA SMI Exporter: 9400
- All services are configured to listen on 0.0.0.0 for external access
- You can select multiple components by entering their numbers separated by spaces (e.g., `2 3 4`)
- For NVIDIA SMI Exporter:
  - Requires NVIDIA drivers to be installed
  - If installation fails, check if nvidia-smi is available:
    ```bash
    # Check NVIDIA driver installation
    nvidia-smi

    # Install NVIDIA SMI Exporter
    wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.1.0/nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
    tar xvf nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
    sudo mv nvidia_gpu_exporter /usr/local/bin/
    sudo chmod +x /usr/local/bin/nvidia_gpu_exporter
    ```

### Target Configuration Guide

### Configuring Prometheus and Loki

1. Backup current configuration (recommended):
```bash
sudo cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.backup
```

2. Open Prometheus configuration:
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

### Chi tiết các thành phần

#### Node Exporter
- Port mặc định: 9100
- Chức năng: Thu thập các metrics về hệ thống như CPU, RAM, disk I/O, network
- Metrics path: `/metrics`
- Các metrics quan trọng:
  - `node_cpu_seconds_total`: Thời gian CPU
  - `node_memory_MemTotal_bytes`: Tổng RAM
  - `node_filesystem_size_bytes`: Dung lượng ổ đĩa
  - `node_network_receive_bytes_total`: Network traffic

#### Loki
- Port mặc định: 3100
- Chức năng: Hệ thống thu thập và lưu trữ logs
- API endpoints:
  - `/loki/api/v1/push`: Nhận logs
  - `/loki/api/v1/query`: Query logs
- Tính năng:
  - Lưu trữ logs hiệu quả
  - Hỗ trợ query logs với LogQL
  - Tích hợp tốt với Grafana
- Lưu ý:
  - Cần đủ disk space cho việc lưu trữ logs
  - Nên cấu hình retention period phù hợp

#### Promtail
- Port mặc định: 9080
- Chức năng: Agent thu thập logs và gửi đến Loki
- Cấu hình:
  - Đọc logs từ files
  - Thêm labels cho logs
  - Gửi logs đến Loki server
- Tính năng:
  - Tự động phát hiện files logs mới
  - Hỗ trợ nhiều format logs
  - Đảm bảo không mất logs khi có sự cố
- Lưu ý:
  - Cần quyền đọc các file logs
  - Có thể cấu hình pipeline để xử lý logs

#### NVIDIA SMI Exporter
- Port mặc định: 9400
- Chức năng: Thu thập metrics từ GPU NVIDIA sử dụng nvidia-smi
- Metrics path: `/metrics`
- Các metrics quan trọng:
  - `nvidia_smi_gpu_utilization`: GPU utilization
  - `nvidia_smi_memory_used_bytes`: Memory utilization
  - `nvidia_smi_power_draw_watts`: Power consumption
  - `nvidia_smi_temperature_celsius`: GPU temperature
- Lưu ý:
  - Yêu cầu NVIDIA driver đã được cài đặt
  - Cần GPU NVIDIA hỗ trợ nvidia-smi

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
  - NVIDIA SMI Exporter: 9400
- Tất cả các dịch vụ được cấu hình để lắng nghe trên 0.0.0.0 để cho phép truy cập từ bên ngoài
- Bạn có thể chọn nhiều thành phần bằng cách nhập số của chúng cách nhau bởi dấu cách (ví dụ: `2 3 4`)
- Đối với NVIDIA SMI Exporter:
  - Yêu cầu đã cài đặt driver NVIDIA
  - Nếu cài đặt bị lỗi, kiểm tra nvidia-smi:
    ```bash
    # Kiểm tra cài đặt driver NVIDIA
    nvidia-smi

    # Cài đặt NVIDIA SMI Exporter
    wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.1.0/nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
    tar xvf nvidia_gpu_exporter_1.1.0_linux_x86_64.tar.gz
    sudo mv nvidia_gpu_exporter /usr/local/bin/
    sudo chmod +x /usr/local/bin/nvidia_gpu_exporter
    ```

### Hướng dẫn cấu hình thêm target

### Cấu hình Prometheus và Loki

1. Sao lưu cấu hình hiện tại (khuyến nghị):
```bash
sudo cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.backup
```

2. Mở file cấu hình Prometheus:
```bash
sudo nano /etc/prometheus/prometheus.yml
```

3. Ví dụ cấu hình thêm target mới:
```yaml
scrape_configs:
  # Các job hiện tại sẽ ở đây
  # Thêm job mới của bạn bên dưới
  - job_name: 'my_new_target'          # Thay đổi tên job
    static_configs:
      - targets: ['192.168.1.100:9100'] # Thay đổi IP và port
    labels:
      location: 'server_room'           # Tùy chọn
      environment: 'production'         # Tùy chọn
```

4. Lưu file:
   - Nhấn: `Ctrl + X`
   - Nhấn: `Y`
   - Nhấn: `Enter`

5. Kiểm tra cấu hình và khởi động lại:
```bash
# Kiểm tra cú pháp
sudo promtool check config /etc/prometheus/prometheus.yml

# Khởi động lại nếu cú pháp đúng
sudo systemctl restart prometheus
```

### Lưu ý quan trọng

1. Trước khi thêm target:
```bash
# Mở port trong firewall
sudo ufw allow target_port/tcp

# Kiểm tra kết nối
telnet target_ip target_port
```

2. Sau khi thêm target:
- Kiểm tra giao diện Prometheus:
  - http://your_server:9090/targets
- Kiểm tra Grafana:
  - http://your_server:3000

3. Nếu có lỗi:
```bash
# Xem log Prometheus
sudo journalctl -u prometheus -f

# Xem metrics của target
curl http://target_ip:target_port/metrics

# Khôi phục cấu hình backup nếu cần
sudo cp /etc/prometheus/prometheus.yml.backup /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus
```