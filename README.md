# training-bigdata-002

This repository is intended for the second practical assignment for the class INF356 at the Federico Santa María Technical University.

The tools enclosed in this repo will allow you to easily create, login into and destroy a Spark based cluster that uses AWS S3 as permanent storage, in order to develop and test distributed software developments intended for big-data.

## Installation

To use this repo you just need to download it into a linux environment (this has been developed in Ubuntu 24.04). In order for this tool to work you need to have available in your system the tool Flintrock (https://github.com/nchammas/flintrock) and an AWS account.

Flintrock depends on the availability of several other libraries, typically present in any up to date linux environment; nevertheless, it is recommened that you install independently **aws-cli** and **boto3**.

### training-bigdata-002

You just need to clone this repo with your preferred method.

### AWS-CLI

AWS-CLI is the Amazon Web Services Command Line Interface. It allows to control the different aws services from your command line.

To install **aws-cli** you can follow the tutorial available here: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html. In summary, you could install this tool with:
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Boto3

**Boto3** is a Python library that allows you to access the AWS services directly from Python, in the same way that the AWS-CLI allows you to do it from the command line.

To install **boto3** you can simply use:
```
sudo apt install python3-boto3
```

### Flintrock

Flintrock can be directly installed with:
```
pipx install flintrock
```
You should be able to get **pipx** on ubuntu systems (23.04 or above) with:
```
sudo apt update
sudo apt install pipx
pipx ensurepath
```
More info in https://pipx.pypa.io/stable/.

## Configuration

In order to use this tool you need to configure some services and grant some permissions to your AWS account. This tools is intended to be used in the **sa-east-1** AWS region.

### EC2 Key

Go to the keys section on your EC2 console (https://sa-east-1.console.aws.amazon.com/ec2/home?region=sa-east-1#KeyPairs:) and create a new key pair. This key pair must be named **flintrock-sa-east-1**. You can use whatever name you got for this key, but if you use another name you must update the scripts accordingly.

The key needs to be of **pem** type, and you need to save the private key in a **key** folder in de **credentials** folder of this repo. Be aware of **never** to store credentials in your repos. This is why the **.gitignore** file is set to ignore any **.pem** file.

### AWS User Credentials

In order to use the AWS services you will need a **programatic user** in your AWS account and to create credentials for this user.

Go to https://us-east-1.console.aws.amazon.com/iam/home?region=sa-east-1#/users and create a new user. The name of the user is no relevant, but you could use **flintrock** to keep the names alligned.

When setting the permissions, you need to select **Attach policies directly** and assign the **AdministratorAccess** policy. Once the user has been created, you must access to its details and go to the **Security credentials** section. There you need to go to the **Access keys** and create a new access key.

When creating the new access key you will get a **key id** and a **key secret**. In the folder **credentials/aws** you will find a file named **credentials.sh.template**. Copy this file in the same folder and name it just **credentials.sh**. Edit the file to provide the access key values you just generated.

### AWS Role

In order to allow the machines in the cluster to freely access S3 and use it as permanent storage for your cluster, you must create a **permissions role** that you can assign to the machines.

You must go to https://us-east-1.console.aws.amazon.com/iam/home?region=sa-east-1#/roles and create a new role. As **Trusted entity type** you must choose **AWS service** and then in **Use case** select **EC2** (there might be many options, select the one that just says EC2). In the next window add the permissión **AmazonS3FullAccess** and finally assign **flintrock** as **Role name**.

You might want to use a name different from the one specified in this instructions. If you do, you will need to update the scripts accordingly.

### S3 Bucket

To store the different files that you will use as part of this assignment, you will need to create a s3 bucket. To do this, go to https://sa-east-1.console.aws.amazon.com/s3/buckets?region=sa-east-1&bucketType=general and click on **create-bucket**. You must name your bucket from your student id number in the form **XXXXXXXXXX-inf356** where **XXXXXXXXXX** corresponds to your student id number without dots or dash (123.456.789-0 corresponds to 1234567890). You must use all the default settings when creating the bucket.

While a bucket can be named in any form, it will be assumed that you will use the specified name when grading this assignment. By S3 restriction, the S3 bucket names need to be unique across the whole AWS infrastructure; therefore, if your bucket name for some reason is not available please mention this when preparing your report.

You will need to edit the file **scripts/test-001.py** to assign the variable **bucket** to the right value.

## Usage in user host

This tool works in base to 3 commands to be used in the student computer: **launch.sh**, **login.sh** and **destroy.sh**.

### launch.sh

This command uses the configurations available in the **config** folder, the credentials that you set in the **credentials** folder and the scripts from **scripts** folder to fully deploy and configure your cluster.

You will typically do not need to do any change, but there are 3 cases that will require you to edit the **config/flintrock/config.yaml** file:

* **Change of instante type**: The cluster by default will be launched with **t2.micro** machines that are part of the aws-free-tier in order to prevent infrastructure charges. You might want to moddify the machine type in order to vertically scale your cluster.
* **Change of AMI**: The config file has been hardcoded with the latest available *Amazon Linux 2* AMI available for the **sa-east-1** region at the time of commit. Be aware that this AMI could change because of periodical upgrades and also because the AMIs have regional scope, therefore, the AMI id will change for the same AMI for each region.
* **Size of the cluster**: By default the cluster will be deployed with 8 workers. If you want to horizontally upscale or downscale your cluster you must change the **num-slaves** configuration line to the desired number.

The **launch.sh** command will first use flintrock to deploy the cluster. If it is not successfull it will ask you if you want to keep or not the created machines and then it will terminate. If everything goes ok with the cluster deployment, then the script will transfer some files to the master cluster, will configure the master node and finally configure the worker nodes, all in a single pass.

After the script has run correctly you will have a cluster ready to use. It should take between 2 to 4 minutes for the whole command to finish.

### login.sh

To login to the cluster master machine you just need to run **login.sh** and it will provide you a bash console in the master machine.

### destroy.sh

This command destroys the cluster that has been created by the **launch.sh** command. This ''destruction'' corresponds to deleting all the machines that were created on the launching procedure, but it does not affect any of the configurations you have previously created (bucket, user, keys, etc.).

I could be possible that after the cluster is destroyed certain ec2 security groups are still available. You can identify these groups by their names **flintrock** and **flintrock-sparl-cluster**. There is no problem in deleting these security groups after you are done with the cluster.

## Usage in master host

This tool provides the commands **submit.sh**, **clean.sh** and **get_usage.sh** to be used in the cluster master machine. These commands are stored in the **~/scripts** folder and are available directly at any path given that the scripts folder has been added to the environment path.

### clean.sh

With the executin of spark, the workers start to accumulate the history of previous executions in **~/spark/work**. This could lead to an exhaustion of disk that prevents new executions.

This command goes through each worker and empty the work folder. In the process shows the initial and final disk use in the machine.

### get_usage.sh

This command will print the current CPU and Memory usage for each machine in the cluster. The first column will be the master machine and the following columns will correspond to each worker (sorted in the same order than in the file **~/spark/conf/slaves**).

By default the reporting will be each 5 seconds. If you want another peridiocity you can pass to the command an integer as first parameter. This parameter should represent the desired period in seconds.

### submit.sh

The **submit.sh** command is a wrapper for the **spark-submit** command to easily include some required configurations. This command receives a single parameter that corresponds to the script that you want to process with the cluster.

## Testing

This tool provides 2 scripts for testing the cluster that can be run directly on the user home directory (these tests are stored in the scripts folder).

It is recommended that once you have completed the cluster deployment you run these commands in order to test that everything is working as expected.

### test-000.sh

This command runs a simple distributed application that sums squares of numbers in a map-reduce approach. As result you will get a log on the terminal and you will find a **test-000.log** file in the scripts folder.

The log file should look something like this:
```
:: loading settings :: url = jar:file:/home/ec2-user/spark/jars/ivy-2.5.1.jar!/org/apache/ivy/core/settings/ivysettings.xml
Sum of squares: 333332833333500000
```

### test-001.sh

This test is intended to test the read-write S3 capabilities and the basic pyspark.sql funcionalities. Once ran you will find a file **test-001.log** in the scripts folder that should look something like this:
```
:: loading settings :: url = jar:file:/home/ec2-user/spark/jars/ivy-2.5.1.jar!/org/apache/ivy/core/settings/ivysettings.xml
Reading file vlt_observations_000.csv from utfsm-inf356-datasets bucket
    - 1000000 rows read
    - Creating row number column
Writting file as vlt_observations_000.parquet into XXXXXXXXXX-inf356 bucket
Reading file vlt_observations_000.parquet from XXXXXXXXXX-inf356 bucket
    - 1000000 rows read
    - Parsing float columns
Writting file as vlt_observations_000.parsed.csv into XXXXXXXXXX-inf356 bucket
Writting file as vlt_observations_000.parsed.parquet into XXXXXXXXXX-inf356 bucket
```
In your bucket you should be able to find 3 folders named:
* ```vlt_observations_000.parquet```
* ```vlt_observations_000.parsed.csv```
* ```vlt_observations_000.parsed.parquet```
