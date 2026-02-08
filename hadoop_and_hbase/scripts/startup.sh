#!/bin/bash

echo "Starting Hadoop + HBase container"

# 创建必要的目录
mkdir -p /data/hadoop/namenode /data/hadoop/datanode /data/hadoop/tmp /data/hbase /data/zookeeper
chown -R hadoop:hadoop /data

# SSH 服务
echo "Starting SSH service..."
service ssh start || true

# 设置环境变量
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
export HADOOP_HOME=/opt/hadoop
export HBASE_HOME=/opt/hbase
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin:$PATH

echo "Root environment variables set:"
echo "JAVA_HOME: $JAVA_HOME"
echo "HADOOP_HOME: $HADOOP_HOME"
echo "HBASE_HOME: $HBASE_HOME"
echo ""

# 以 hadoop 用户运行启动脚本
echo "Switching to hadoop user and starting services..."
su - hadoop -c "bash /scripts/start-services.sh"