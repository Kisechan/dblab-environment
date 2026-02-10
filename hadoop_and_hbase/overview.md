# Hadoop & HBase Docker Environment

This repository provides a pre-configured Docker environment for setting up and running Hadoop 3.3.6 and HBase 2.4.17. It simplifies the deployment process, allowing you to quickly start a distributed big data environment without the need for a dedicated Linux virtual machine.

## Features
- **Hadoop 3.3.6**: Includes HDFS, YARN, and MapReduce for distributed storage and processing.
- **HBase 2.4.17**: A NoSQL database for real-time read/write access to large datasets.
- **Pre-configured environment**: All necessary configurations for Hadoop and HBase are included.
- **Easy deployment**: Start the environment with a single `docker-compose up` command.
- **Lightweight**: Built on top of Ubuntu 22.04 for compatibility and performance.

## How to Use

### Pull the Image
Pull the pre-built image from Docker Hub:
```bash
docker pull kisechan/hadoop-hbase:latest
```

### Run the Container
Use the following `docker-compose.yml` file to start the container:

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

Run the following command to start the container:
```bash
docker-compose up -d
```

### Access Services
Once the container is running, you can access the following services:

| Service                | URL                          |
|------------------------|------------------------------|
| Hadoop NameNode        | http://localhost:9870       |
| Hadoop ResourceManager | http://localhost:8088       |
| Hadoop HistoryServer   | http://localhost:19888      |
| HBase Master Web UI    | http://localhost:16010      |
| HBase RegionServer UI  | http://localhost:16030      |

### Stop and Clean Up
To stop and remove the container, run:
```bash
docker-compose down -v
```
To clean up unused Docker resources:
```bash
docker system prune -a --volumes -f
```

## Repository
For more details, configurations, and scripts, visit the GitHub repository:
[https://github.com/Kisechan/dblab-environment](https://github.com/Kisechan/dblab-environment)

---

This image is designed for educational and development purposes. Feel free to contribute or raise issues in the GitHub repository!