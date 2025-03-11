# Grafana Monitoring Stack Installation Script

# Script Cài đặt Stack Giám sát Grafana

## Description / Mô tả

This script automates the installation process of Grafana monitoring stack including Grafana, Prometheus, Node Exporter, Promtail, Loki, and NVIDIA Prometheus Exporter on Ubuntu/Debian systems. It provides a user-friendly interface with colored output, automatic system updates, and verification steps to ensure successful installation. The script includes features like port configuration, component selection, and optional system reboot.

Script này tự động hóa quá trình cài đặt stack giám sát Grafana bao gồm Grafana, Prometheus, Node Exporter, Promtail, Loki và NVIDIA Prometheus Exporter trên các hệ thống Ubuntu/Debian. Cung cấp giao diện thân thiện với người dùng thông qua các thông báo màu sắc, tự động cập nhật hệ thống và các bước xác minh để đảm bảo cài đặt thành công. Script bao gồm các tính năng như cấu hình port, lựa chọn thành phần và tùy chọn khởi động lại hệ thống.

## Table of Contents / Mục lục

* English  
   * Features  
   * Installation  
   * Usage  
   * Notes
* Tiếng Việt  
   * Tính năng  
   * Cài đặt  
   * Sử dụng  
   * Lưu ý

## English

### Features

* Automatic system updates before installation
* Installation verification for each component
* Colored output for better progress tracking
* Customizable ports for all components
* Multiple component selection
* Auto-update functionality for the script itself
* Option to remove all components
* External access support (0.0.0.0)

### Installation

Download script from GitHub:
```bash
wget https://raw.githubusercontent.com/fat-beo/script-monitoring-grafana/main/script-monitoring-grafana.sh
```

Make script executable:
```bash
chmod +x script-monitoring-grafana.sh
```

### Usage

1. Run the script with sudo:
```bash
sudo ./script-monitoring-grafana.sh
```

2. Choose one or more of the following options (space-separated):

Component selection options:
```
1  : Install Grafana
2  : Install Prometheus
3  : Install Node Exporter
4  : Install Promtail
5  : Install Loki
6  : Install NVIDIA Prometheus Exporter
7  : Configure Ports
8  : Remove All Components
```

Example to install multiple components:
```bash
# To install Prometheus, Node Exporter and Promtail:
2 3 4
```

### Notes

Default ports configuration:
```
Grafana          : 3000
Prometheus       : 9090
Node Exporter    : 9100
Promtail         : 9080
Loki            : 3100
NVIDIA Exporter  : 9400
```

* Root privileges are required to run the script
* All components are accessible externally (0.0.0.0)
* NVIDIA Exporter requires NVIDIA drivers to be installed first

## Tiếng Việt

### Tính năng

* Tự động cập nhật hệ thống trước khi cài đặt
* Kiểm tra và xác minh cài đặt cho từng thành phần
* Hiển thị thông báo màu sắc để dễ theo dõi tiến trình
* Tùy chỉnh port cho tất cả các thành phần
* Lựa chọn nhiều thành phần cùng lúc
* Tự động cập nhật script khi có phiên bản mới
* Tùy chọn xóa tất cả các thành phần
* Hỗ trợ truy cập từ bên ngoài (0.0.0.0)

### Cài đặt

Tải script từ GitHub:
```bash
wget https://raw.githubusercontent.com/fat-beo/script-monitoring-grafana/main/script-monitoring-grafana.sh
```

Cấp quyền thực thi cho script:
```bash
chmod +x script-monitoring-grafana.sh
```

### Sử dụng

1. Chạy script với quyền sudo:
```bash
sudo ./script-monitoring-grafana.sh
```

2. Chọn một hoặc nhiều tùy chọn sau (phân cách bằng dấu cách):

Các tùy chọn cài đặt:
```
1  : Cài đặt Grafana
2  : Cài đặt Prometheus
3  : Cài đặt Node Exporter
4  : Cài đặt Promtail
5  : Cài đặt Loki
6  : Cài đặt NVIDIA Prometheus Exporter
7  : Cấu hình Ports
8  : Xóa Tất cả Các Thành phần
```

Ví dụ cài đặt nhiều thành phần:
```bash
# Để cài đặt Prometheus, Node Exporter và Promtail:
2 3 4
```

### Lưu ý

Cấu hình port mặc định:
```
Grafana          : 3000
Prometheus       : 9090
Node Exporter    : 9100
Promtail         : 9080
Loki            : 3100
NVIDIA Exporter  : 9400
```

* Script yêu cầu quyền root để chạy
* Tất cả các thành phần có thể truy cập từ bên ngoài (0.0.0.0)
* NVIDIA Exporter yêu cầu cài đặt driver NVIDIA trước