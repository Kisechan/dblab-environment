# 数据库实验环境 (DBLab)

本项目提供了两个数据库实验环境的 Docker 配置，无需使用 Linux 虚拟机即可快速搭建实验环境：

1. **Hadoop & HBase 分布式环境** - 大数据存储与处理平台
2. **MongoDB 环境** - NoSQL 文档数据库（包含单机版和副本集集群）

通过 Docker 容器化技术可以在本地快速部署这些实验环境，避免了复杂的系统配置和虚拟机管理。

## 项目结构

```
dblab/
├── README.md                      # 本文件（项目总说明）
├── README-mongodb.md              # MongoDB 实验详细说明
├── hadoop_and_hbase/              # Hadoop & HBase 实验环境
│   ├── docker-compose.yml         # Docker Compose 配置
│   ├── Dockerfile                 # 容器镜像构建文件
│   ├── config/                    # Hadoop 和 HBase 配置文件
│   ├── scripts/                   # 启动脚本
│   ├── data/                      # 数据持久化目录
│   ├── logs/                      # 日志目录
│   └── hbase-test/                # HBase Java 测试项目
└── mongodb/                       # MongoDB 实验环境
    ├── docker-compose.yml         # 单机 MongoDB 配置
    ├── docker-compose-replica.yml # MongoDB 副本集配置
    ├── experiment.sh              # 基础实验脚本
    ├── data/                      # 数据持久化目录
    └── logs/                      # 日志目录
```

## 实验环境架构

### Hadoop & HBase

```mermaid
graph TB
    subgraph "Docker Container"
        A[Hadoop HDFS<br/>NameNode: 9870] 
        B[Hadoop YARN<br/>ResourceManager: 8088]
        C[HBase Master<br/>Web UI: 16010]
        D[HBase RegionServer<br/>Web UI: 16030]
        E[ZooKeeper<br/>Port: 2181]
        
        A --> E
        C --> E
        D --> C
        B --> A
    end
    
    F[Local Machine<br/>浏览器访问] --> A
    F --> B
    F --> C
    G[HBase Client<br/>Java/Shell] --> C
    G --> D
```

### MongoDB 副本集架构

```mermaid
graph LR
    subgraph "MongoDB Replica Set (rs0)"
        A[Primary<br/>mongodb-rs0<br/>Port: 27017]
        B[Secondary<br/>mongodb-rs1<br/>Port: 27018]
        C[Secondary<br/>mongodb-rs2<br/>Port: 27019]
        
        A -.同步.-> B
        A -.同步.-> C
        B -.心跳.-> A
        C -.心跳.-> A
    end
    
    D[MongoDB Client] --> A
    D --> B
    D --> C
```

## 环境要求

[Docker Desktop](https://www.docker.com/).

### Docker 基础使用说明

```bash
# 查看正在运行的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看本地镜像
docker images

# 查看容器日志
docker logs <容器名称或ID>

# 进入容器内部
docker exec -it <容器名称> bash

# 停止容器
docker stop <容器名称>

# 启动已停止的容器
docker start <容器名称>

# 重启容器
docker restart <容器名称>

# 删除容器
docker rm <容器名称>

# 删除镜像
docker rmi <镜像名称或ID>
```

### Docker Compose 常用命令

```bash
# 启动服务（后台运行）
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs

# 停止服务（保留容器）
docker-compose stop

# 启动已停止的服务
docker-compose start

# 停止并删除容器
docker-compose down

# 停止并删除容器、网络、卷
docker-compose down -v

# 使用指定的 compose 文件
docker-compose -f docker-compose-replica.yml up -d
```

## Hadoop & HBase 环境


### 拉取 Docker Hub 镜像

本项目构建的 Hadoop & HBase 镜像已上传到 Docker Hub：[hub.docker.com/repository/docker/kisechan/hadoop-hbase](https://hub.docker.com/repository/docker/kisechan/hadoop-hbase/)，可直接拉取和使用。

### 拉取镜像

```bash
docker pull kisechan/hadoop-hbase:latest
```

### 使用镜像

您可使用以下 `docker-compose.yml` 文件直接运行从 Docker Hub 拉取的镜像：

```yaml
version: '3.8'
services:
  hadoop-hbase:
    image: kisechan/hadoop-hbase:latest
    container_name: hadoop-hbase
    hostname: hadoop-hbase
    ports:
      - "9870:9870"    # Hadoop NameNode Web UI
      - "8088:8088"    # Hadoop ResourceManager Web UI
      - "19888:19888"  # Hadoop HistoryServer
      - "16010:16010"  # HBase Master Web UI
      - "16030:16030"  # HBase RegionServer Web UI
      - "2181:2181"    # ZooKeeper
      - "22:22"        # SSH
    volumes:
      - ./data:/data
      - ./logs:/opt/hadoop/logs
    environment:
      - JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
      - HADOOP_HOME=/opt/hadoop
      - HBASE_HOME=/opt/hbase
    privileged: true
    stdin_open: true
    tty: true
    networks:
      hadoop-network:

networks:
  hadoop-network:
    driver: bridge
```

运行以下命令启动服务：

```bash
docker-compose up -d
```

### 本地构建镜像

> [!NOTE]
> 由于网络问题，直接运行 `docker-compose up` 可能会失败。**建议先手动拉取 Ubuntu 镜像**：
> 
> ```bash
> docker pull ubuntu:22.04
> ```
> 
> **整个构建过程大约需要 10 分钟**。

#### 启动步骤

```bash
# 进入项目目录
cd hadoop_and_hbase

# 【可选】先拉取 Ubuntu 镜像
docker pull ubuntu:22.04

# 构建并启动容器
docker-compose up -d

# 查看启动日志
docker-compose logs -f
# 等待服务完全启动（观察日志，看到 HBase 和 Hadoop 服务都启动后）
```

### 访问服务

容器启动后，可以通过以下地址访问各个服务的 Web UI：

| 服务 | 访问地址 | 说明 |
|-----|---------|------|
| Hadoop NameNode | http://localhost:9870 | HDFS 管理界面 |
| Hadoop ResourceManager | http://localhost:8088 | YARN 资源管理 |
| Hadoop HistoryServer | http://localhost:19888 | 任务历史服务器 |
| HBase Master | http://localhost:16010 | HBase 主节点 |
| HBase RegionServer | http://localhost:16030 | HBase 区域服务器 |

### 使用 HBase Shell

```bash
# 进入容器
docker exec -it hadoop-hbase bash

# 切换到 hadoop 用户
su - hadoop

# 启动 HBase Shell
hbase shell

# HBase 命令示例
hbase> list                                     # 列出所有表
hbase> create 'test', 'cf'                      # 创建表
hbase> put 'test', 'row1', 'cf:name', 'Alice'   # 插入数据
hbase> scan 'test'                              # 扫描表
hbase> get 'test', 'row1'                       # 查询数据
hbase> disable 'test'                           # 禁用表
hbase> drop 'test'                              # 删除表
hbase> exit                                     # 退出
```

### HBase Java 客户端测试

详细说明和项目代码请查看 [hbase-test/README.md](hadoop_and_hbase/hbase-test/README.md)

### 停止和清理

```bash
# 停止服务（保留数据）
docker-compose stop

# 重新启动
docker-compose start

# 停止并删除容器（但保留数据）
docker-compose down

# 完全清理（包括数据卷）
docker-compose down -v
rm -rf data/ logs/
```

## MongoDB 环境

MongoDB 实验环境提供两种配置：

1. **单机版** - 基础 MongoDB 实例
2. **副本集集群** - 3 节点副本集

### 单机版 MongoDB

```bash
# 进入 MongoDB 目录
cd mongodb

# 启动单机 MongoDB
docker-compose up -d

# 查看日志
docker-compose logs -f

# 运行基础实验脚本
chmod +x experiment.sh
./experiment.sh

# 手动连接
mongosh 'mongodb://root:123456@localhost:27017/admin?authSource=admin'
```

### MongoDB 副本集集群

```bash
# 启动副本集（3 个节点）
docker-compose -f docker-compose-replica.yml up -d

# 查看服务状态
docker-compose -f docker-compose-replica.yml ps

# 运行副本集实验脚本
chmod +x replica-experiment.sh
./replica-experiment.sh

# 连接到 Primary 节点
mongosh 'mongodb://root:123456@localhost:27017/admin?authSource=admin'

# 连接到 Secondary 节点
mongosh 'mongodb://root:123456@localhost:27018/admin?authSource=admin'
```

### MongoDB 基本操作示例

```mongosh
// 切换/创建数据库
use testdb

// 插入文档
db.users.insertOne({name: "Alice", age: 25, city: "Beijing"})

// 查询文档
db.users.find()

// 创建索引
db.users.createIndex({name: 1})

// 更新文档
db.users.updateOne({name: "Alice"}, {$set: {age: 26}})

// 删除文档
db.users.deleteOne({name: "Alice"})

// 查看副本集状态（仅副本集环境）
rs.status()
```

### 停止和清理

```bash
# 单机版
docker-compose down
docker-compose down -v  # 包括数据

# 副本集
docker-compose -f docker-compose-replica.yml down
docker-compose -f docker-compose-replica.yml down -v  # 包括数据
```

## 完全清理所有环境

> [!TIP]
> 这部分专为不喜欢让 Docker 在磁盘里制造答辩的人群（比如本人）准备。

### 清理项目相关容器和镜像

```bash
# 停止所有项目容器
cd hadoop_and_hbase && docker-compose down -v
cd ../mongodb && docker-compose down -v
cd ../mongodb && docker-compose -f docker-compose-replica.yml down -v

# 查看所有容器
docker ps -a

# 删除特定容器（如果有残留）
docker rm -f <容器名称>

# 查看镜像
docker images

# 删除项目相关镜像
docker rmi hadoop_and_hbase-hadoop-hbase    # Hadoop/HBase 镜像
docker rmi mongo:8.0.4                      # MongoDB 镜像
docker rmi ubuntu:22.04                     # Ubuntu 基础镜像（如果不再需要）

# 清理未使用的镜像和缓存（可选，会清理所有未使用的资源）
docker system prune -a --volumes

# 删除本地数据目录
# 手动删除本地的 data、logs 等文件夹即可
```

### 清理 Docker 系统资源

```bash
# 查看 Docker 磁盘使用情况
docker system df

# 清理停止的容器
docker container prune

# 清理未使用的镜像
docker image prune -a

# 清理未使用的卷
docker volume prune

# 清理未使用的网络
docker network prune

# 一键清理所有未使用的资源（谨慎使用）
docker system prune -a --volumes
```

## 常见问题

### HBase 连接错误

**问题**: Java 客户端连接失败

**解决方案**:
```bash
# 确保在 docker 网络内或使用正确的主机名
# 如果从宿主机连接，修改 /etc/hosts:
echo "127.0.0.1 hadoop-hbase" >> /etc/hosts
```