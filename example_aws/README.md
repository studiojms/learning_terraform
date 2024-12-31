## Running terraform with AWS and localstack

This example shows how to run terraform with AWS and localstack.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Python](https://www.python.org/downloads/)

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
