
# training-bigdata-002

This repository is intended for the second practical assignment for the class INF356 at the Federico Santa María Technical University.

The tools enclosed in this repo will allow you to easily create, log into, and destroy a Spark-based cluster that uses AWS S3 as permanent storage, in order to develop and test distributed software developments intended for big data.

## Installation

To use this repo, download it into a Linux environment (developed on Ubuntu 24.04). You will need Flintrock (https://github.com/nchammas/flintrock) and an AWS account (the AWS Academy account is sufficient).

Flintrock depends on several libraries typically present in modern Linux environments. However, it is recommended that you install **aws-cli** and **boto3** manually.

### Clone Repository

Clone this repo using your preferred method.

### AWS CLI

AWS CLI is the Amazon Web Services Command Line Interface. It allows you to manage AWS services from your command line.

Installation instructions can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). In summary:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Boto3

**Boto3** is a Python library for accessing AWS services programmatically.

```bash
sudo apt install python3-boto3
```

### Flintrock

Install Flintrock using pipx:

```bash
pipx install flintrock
```

Install pipx on Ubuntu (24.04 or above):

```bash
sudo apt update
sudo apt install pipx
pipx ensurepath
```

More information: https://pipx.pypa.io/stable/.

## Configuration

> ⚠️ **Important:** This tool is intended for use in the **us-east-1** AWS region.

### EC2 Key Pair

1. Go to the [EC2 Key Pairs console](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#KeyPairs:) and create a new key pair named **flintrock-sa-east-1**.
2. The key should be of **.pem** type. Save the private key in a `key` folder inside the `credentials` directory.

> ❗ **Security Warning:** Never store `.pem` or credential files in a public repository. The `.gitignore` is configured to ignore any `.pem` files.

### AWS User Credentials

1. Go to the [IAM Users console](https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/users) and create a new programmatic user (e.g., **flintrock**).
2. Assign the **AdministratorAccess** policy directly.
3. After creation, go to the **Security credentials** tab → **Access keys** → Create a new access key.
4. In `credentials/aws/`, copy `credentials.sh.template` to `credentials.sh` and add the generated key ID and secret.

### AWS Role for EC2

1. Navigate to the [IAM Roles console](https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/roles).
2. Create a new role:
   - **Trusted entity type**: AWS service
   - **Use case**: EC2
3. Attach the **AmazonS3FullAccess** permission.
4. Name the role **flintrock** (or update scripts accordingly if using another name).

### S3 Bucket

1. Go to the [S3 console](https://us-east-1.console.aws.amazon.com/s3/buckets?region=us-east-1&bucketType=general).
2. Create a bucket named `XXXXXXXXXX-inf356` where `XXXXXXXXXX` is your student ID (no dots or dashes).
3. Use default settings.

Update the `bucket` variable in `scripts/test-001.py` with your bucket name.

## Usage on User Host

Scripts provided:

- `launch.sh` — Deploys the cluster
- `login.sh` — SSH into the master node
- `destroy.sh` — Destroys the cluster

### launch.sh

Uses `config/`, `credentials/`, and `scripts/` to deploy and configure your cluster.

You may need to edit `config/flintrock/config.yaml` if:

- Changing instance type (default: `t2.micro`)
- Updating the AMI ID (subject to change)
- Modifying number of workers (default: 2)

If deployment fails, the script will prompt you about keeping or deleting the created machines.

Expected runtime: 2–4 minutes.

### login.sh

Connects you to the master machine via SSH.

### destroy.sh

Destroys EC2 instances but leaves other configurations (S3 bucket, keys, etc.) intact.

You may see residual EC2 security groups named `flintrock` or `flintrock-spark-cluster`. These can be deleted manually.

## Usage on Master Host

The `~/scripts/` directory contains the following commands:

### clean.sh

Cleans the `~/spark/work` directory on each worker to free disk space.

### get_usage.sh

Reports CPU and memory usage for each machine. The first column is the master, followed by workers.

The script uses a default interval of 5 seconds.

```bash
./get_usage.sh
```

You can use an integer parameter to change the refresh interval:

```bash
./get_usage.sh 10  # every 10 seconds
```

### submit.sh

Wrapper for `spark-submit`. Accepts one parameter: the script to submit.

## Testing

Run these tests after deployment to verify setup.

### test-000.sh

A simple distributed map-reduce script.

Output: terminal log and `scripts/test-000.log`.

Example:
```
Sum of squares: 333332833333500000
```

### test-001.sh

Tests S3 integration and PySpark SQL features.

Output: `scripts/test-001.log`.

Example:
```
Reading file vlt_observations_000.csv from utfsm-inf356-datasets bucket
Writting file as vlt_observations_000.parsed.parquet into XXXXXXXXXX-inf356 bucket
```

Check your S3 bucket for:

- `vlt_observations_000.parquet`
- `vlt_observations_000.parsed.csv`
- `vlt_observations_000.parsed.parquet`
