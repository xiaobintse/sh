#!/bin/bash

# 设置内核参数
sudo sysctl -w vm.overcommit_memory=1

# 启动 nockchain 节点
RUST_LOG="info,nockchain=info,nockchain_libp2p_io=info,libp2p=info,libp2p_quic=info" \
MINIMAL_LOG_FORMAT=true \
nockchain --mine \
  --mining-pubkey 3PCqXVqupFH9JBXPGSAXD5ErXLzEFD8hG38NBDXchwHbGYHM4RXmTbdQw3M6VLk4Bp7Y45XK28HQNRBo5GuZg4HnmtAypm5QBnKocnyYE6ULyiaNM5wKfqnRCZZ4mqzsi6qN \
  --peer /ip4/95.216.102.60/udp/3006/quic-v1 \
  --peer /ip4/65.108.123.225/udp/3006/quic-v1 \
  --peer /ip4/65.109.156.108/udp/3006/quic-v1 \
  --peer /ip4/65.21.67.175/udp/3006/quic-v1 \
  --peer /ip4/65.109.156.172/udp/3006/quic-v1 \
  --peer /ip4/34.174.22.166/udp/3006/quic-v1 \
  --peer /ip4/34.95.155.151/udp/30000/quic-v1 \
  --peer /ip4/34.18.98.38/udp/30000/quic-v1 \
  --peer /ip4/96.230.252.205/udp/3006/quic-v1 \
  --peer /ip4/94.205.40.29/udp/3006/quic-v1 \
  --peer /ip4/159.112.204.186/udp/3006/quic-v1 \
  --peer /ip4/217.14.223.78/udp/3006/quic-v1 \
  --bind /ip4/0.0.0.0/udp/6001/quic-v1
