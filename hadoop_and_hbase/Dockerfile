FROM ubuntu:22.04

# 设置非交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 设置环境变量
ENV HADOOP_VERSION=3.3.6
ENV HBASE_VERSION=2.4.17
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
ENV HADOOP_HOME=/opt/hadoop
ENV HBASE_HOME=/opt/hbase
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ssh \
    openssh-server \
    openjdk-8-jdk-headless \
    vim \
    net-tools \
    iputils-ping \
    dnsutils \
    python3 \
    python3-pip \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置SSH
RUN rm -f /etc/ssh/ssh_host_*_key* && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''

# 创建hadoop用户
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop:hadoop" | chpasswd && \
    echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-aarch64.tar.gz -O /tmp/hadoop.tar.gz && \
    tar -xzf /tmp/hadoop.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop.tar.gz

# HBase
RUN wget https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz -O /tmp/hbase.tar.gz && \
    tar -xzf /tmp/hbase.tar.gz -C /opt && \
    mv /opt/hbase-${HBASE_VERSION} ${HBASE_HOME} && \
    rm /tmp/hbase.tar.gz

# 配置文件
COPY config/hadoop/ ${HADOOP_HOME}/etc/hadoop/
COPY config/hbase/ ${HBASE_HOME}/conf/
COPY scripts/ /scripts/

# 设置权限
RUN chown -R hadoop:hadoop /opt/hadoop /opt/hbase /scripts && \
    chmod +x /scripts/*.sh

# 数据目录
RUN mkdir -p /data/hadoop /data/hbase /data/zookeeper && \
    chown -R hadoop:hadoop /data

# SSH
USER hadoop
WORKDIR /home/hadoop
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> ~/.ssh/config && \
    echo "UserKnownHostsFile /dev/null" >> ~/.ssh/config

# 配置 hadoop 用户的环境变量
RUN echo '' >> ~/.bashrc && \
    echo '# Hadoop & HBase Configuration' >> ~/.bashrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64' >> ~/.bashrc && \
    echo 'export HADOOP_HOME=/opt/hadoop' >> ~/.bashrc && \
    echo 'export HBASE_HOME=/opt/hbase' >> ~/.bashrc && \
    echo 'export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HBASE_HOME/bin:$PATH' >> ~/.bashrc

USER root

# 暴露端口
# Hadoop NameNode
EXPOSE 9870
# Hadoop ResourceManager
EXPOSE 8088
# Hadoop HistoryServer
EXPOSE 19888
# HBase Master Web UI
EXPOSE 16010
# HBase Regionserver Web UI
EXPOSE 16030
# ZooKeeper
EXPOSE 2181
# SSH
EXPOSE 22

# 启动脚本
ENTRYPOINT ["/scripts/startup.sh"]