## Running terraform with AWS and localstack

This example shows how to run terraform with AWS and localstack.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Python](https://www.python.org/downloads/)

#### Configure AWS profile

```bash
aws configure --profile localstack
```

#### Create the secret manager data

```bash
aws --endpoint http://localhost:4566 --profile localstack secretsmanager create-secret --name prod/terraform/db --description "Prod DB data" --secret-string "{\"Host\":\"localhost\",\"Username\":\"admin\",\"Password\":\"0ea6be79e04ac1b0400d65ffc11088f9\",\"DB\":\"db\"}"
```

### Setting up localstack with python

1. Activate a virtual environment

```bash
source venv/bin/activate
```

2. Install the required packages

```bash
pip install -r requirements.txt
```

### Running the example

1. Start localstack

```bash
docker-compose up -d
```

2. Run terraform

```bash
terraform init
terraform apply
```

3. Destroy the resources

```bash
terraform destroy
```

4. Stop localstack

```bash
docker-compose down
```
