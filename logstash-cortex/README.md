logstash container configuration
========

The repository is used to deploy **logstash configuration** for ECS fargate.
The logstash server will get forwarded **syslogs** from **Cortex Data Lake** and uploads the logs to **S3** bucket. 

* This should be used with terraform-fargate-logstash as a helper tool for a Docker image for the logstash.
* The terraform apply will trigger the image creation and the configuration in this repo will be used to create the Docker images and eventually pushed to ECR.
* The logstash configuration : the input plugin processes the syslog as a message per syslog, the filter plugin constructs prefix with 'logtype' using inline Ruby, and the S3 output plugin uses 'line' to set 'return' at the end of each syslog.
* (Note 1) The logstash input is actually comma separated (csv) format but the input gets the syslog as a plain text (one message per syslog) and S3 output is specified as a 'line' codec to add a newline per message.  
* (Note 2) Becase this repo is not using any Maven, the 'pom.xml' is not used.
