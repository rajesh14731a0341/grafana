# 1. Define variables
AWS_REGION=us-east-1
ACCOUNT_ID=736747734611
REPO_NAME=project
IMAGE_NAME=nginx
TAG=latest

# 2. Build image
docker build -t ${IMAGE_NAME}:${TAG} .

# 3. Tag it for ECR
docker tag ${IMAGE_NAME}:${TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_NAME}

# 4. Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 5. Push to ECR
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_NAME}
