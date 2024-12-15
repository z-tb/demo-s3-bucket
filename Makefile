TF="tofu"
# ANSI color codes
GREEN = \033[32m
RED = \033[31m
RESET = \033[0m

# Set the environment variable (default is "prod")
ENV ?= dev

# info block
HEADER := Provisioning environment: $(ENV)

# for docker login, etc
AWS_ACCT   := $(shell aws sts get-caller-identity --query "Account" --output text)
AWS_REGION := $(shell aws configure get region)
AWS_ARN    := $(AWS_ACCT).dkr.ecr.$(AWS_REGION).amazonaws.com

dlogin:
	@echo "Logging into ECR: $(AWS_ARN)"
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ARN}

dbuild:
	@echo "Building Docker image..."
	docker build -t my-app .

dtag: dbuild
	@echo "Tagging Docker image..."
	docker tag my-app:latest $(AWS_ARN)/my-app:latest

dpush: dlogin dtag
	@echo "Pushing Docker image to ECR..."
	docker push $(AWS_ARN)/my-app:latest

# reconfigure for prod/dev
reconfig:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) init -reconfigure -var-file=$(ENV).tfvars

# Target: init
init:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) init -var-file=$(ENV).tfvars

plan:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) plan -var-file=$(ENV).tfvars

apply:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) apply -var-file=$(ENV).tfvars

destroy:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) destroy -var-file=$(ENV).tfvars
# Vim modeline
# vim: syntax=make ts=8 sw=8 noet
