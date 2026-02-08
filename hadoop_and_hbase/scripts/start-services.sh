#!/bin/bash

# 此脚本以 hadoop 用户身份运行，启动所有服务

# 直接设置环境变量（不依赖 .bashrc）
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
export HADOOP_HOME=/opt/hadoop
export HBASE_HOME=/opt/hbase
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin:$PATH

echo "Environment loaded in hadoop user:"
echo "JAVA_HOME: $JAVA_HOME"
echo "HADOOP_HOME: $HADOOP_HOME"
echo "HBASE_HOME: $HBASE_HOME"
echo ""

# 验证 Java 安装
echo "Checking Java installation..."
if ! java -version 2>&1 | head -1; then
    echo "ERROR: Java not found!"
    exit 1
fi

# 验证 Hadoop 安装
echo "Checking Hadoop installation..."
if [ ! -f "$HADOOP_HOME/bin/hadoop" ]; then
    echo "ERROR: Hadoop binary not found at $HADOOP_HOME/bin/hadoop"
    ls -la $HADOOP_HOME/ 2>/dev/null || echo "$HADOOP_HOME directory not found"
    exit 1
fi

echo "Hadoop found: $(hadoop version | head -1)"
echo ""

# 格式化HDFS（只在第一次运行时执行）
if [ ! -d /data/hadoop/namenode/current ]; then
    echo "Formatting HDFS NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# 启动Hadoop集群
echo "Starting Hadoop services..."
$HADOOP_HOME/sbin/start-dfs.sh
sleep 5
$HADOOP_HOME/sbin/start-yarn.sh
sleep 5
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

# 等待HDFS启动
echo "Waiting for HDFS to be ready..."
sleep 10

# 创建HBase需要的HDFS目录
echo "Creating HBase directories in HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /hbase || true
$HADOOP_HOME/bin/hdfs dfs -chown hadoop:hadoop /hbase || true

# 启动HBase
echo "Starting HBase..."
$HBASE_HOME/bin/start-hbase.sh

# 等待HBase启动
echo "Waiting for HBase to start..."
sleep 15

# 检查服务状态
echo ""
echo "====== Waiting for services to stabilize ======"
sleep 5

echo "====== Service Status (jps) ======"
jps

echo ""
echo "====== HDFS Status ======"
$HADOOP_HOME/bin/hdfs dfsadmin -report 2>&1 | head -30 || true

echo ""
echo "====== HBase Status ======"
echo "status" | $HBASE_HOME/bin/hbase shell 2>&1 | grep -A 5 "version" || echo "HBase initializing..."

echo ""
echo "=========================================="
echo "✓ Hadoop and HBase startup completed!"
echo "=========================================="
echo "Web Interfaces:"
echo "  - Hadoop NameNode:       http://localhost:9870"
echo "  - Hadoop ResourceManager: http://localhost:8088"
echo "  - HBase Master:          http://localhost:16010"
echo ""
echo "Quick Commands:"
echo "  - View logs:      docker-compose logs -f"
echo "  - Enter container: docker exec -it hadoop-hbase bash"
echo "  - Run as hadoop:   docker exec -it hadoop-hbase su - hadoop"
echo "  - HBase shell:    docker exec -it hadoop-hbase su - hadoop -c 'hbase shell'"
echo "=========================================="
echo ""

# 保持脚本运行，让容器不退出
while true; do
    sleep 3600
done
