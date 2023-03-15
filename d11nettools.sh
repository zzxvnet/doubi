#!/bin/bash
# 在 Debian 11 上检查并安装 curl, iperf3, mtr, ifconfig 和 bbr

# 检查并安装缺失的软件包
install_package() {
  package=$1
  if ! dpkg -l | grep -q "^ii.*$package"; then
    echo "正在安装 $package ..."
    sudo apt-get update
    sudo apt-get install -y "$package"
  else
    echo "$package 已经安装。"
  fi
}

# 安装 bbr
install_bbr() {
  if ! lsmod | grep -q "tcp_bbr"; then
    echo "正在启用 bbr ..."
    sudo bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
    sudo bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
    sudo sysctl -p
  else
    echo "bbr 已经启用。"
  fi
}

# 检查 ifconfig
if ! command -v ifconfig &>/dev/null; then
  install_package net-tools
else
  echo "ifconfig 已经安装。"
fi

# 检查并安装其他软件包
for package in curl iperf3 mtr; do
  install_package "$package"
done

# 安装 bbr
install_bbr

# 检查安装情况
echo "检查安装情况："
for package in curl iperf3 mtr ifconfig; do
  if command -v "$package" &>/dev/null; then
    echo "$package 安装成功。"
  else
    echo "错误：$package 未能成功安装。"
  fi
done

if lsmod | grep -q "tcp_bbr"; then
  echo "bbr 安装成功。"
else
  echo "错误：bbr 未能成功安装。"
fi
