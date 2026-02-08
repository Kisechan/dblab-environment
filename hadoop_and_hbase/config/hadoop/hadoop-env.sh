#!/usr/bin/env bash

# Hadoop 环境变量配置

# Java Home - 必须设置
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64

# Hadoop 配置目录
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# Hadoop 进程的用户
export HDFS_NAMENODE_USER=hadoop
export HDFS_DATANODE_USER=hadoop
export HDFS_SECONDARYNAMENODE_USER=hadoop
export YARN_RESOURCEMANAGER_USER=hadoop
export YARN_NODEMANAGER_USER=hadoop

# 日志目录
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# PID 目录
export HADOOP_PID_DIR=/tmp/hadoop

# 堆大小设置（可选）
export HADOOP_HEAPSIZE_MAX=1g
export HADOOP_HEAPSIZE_MIN=512m
