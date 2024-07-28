### Steps for EC2 Monitoring using Prometheus Service Discovery

Why we need service discovery?
Suppose we have 100 EC2 instances then we will not add each instance manually to prometheus.yaml instead we want something that automatically discovers EC2 instances and starts scraping metrics from them. This is called Service discovery.

1. Create a Prometheus Server(EC2 running prometheus)
2. Allow port 9090 in security group of this prometheus server.
3. Create an IAM role having EC2 describe instances permission or EC2 Read Permissions and attach to this Prometheus Server
4. Next, Configure prometheus.yaml file
5. Next, start deploying EC2 instances which have Node Exporter running.
6. Allow port 9100 in security group of EC2 instances having node exporter running.