#!/bin/bash
nmcli con mod "System eth0" ipv4.dns "8.8.8.8 8.8.4.4"
systemctl restart NetworkManager
