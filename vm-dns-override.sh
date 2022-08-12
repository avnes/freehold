#!/bin/bash
echo "Updating nameservers"
nmcli con mod "System eth0" ipv4.dns "10.0.1.74 10.0.0.1 8.8.8.8"
