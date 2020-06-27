yum install -y vim unzip git zip
yum install -y wget
wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip
unzip terraform_0.12.26_linux_amd64.zip
mv terraform /usr/local/bin
yum install -y aws-cli
mkdir -p ~/.aws
cp -v config ~/.aws
cd ecr-repo
terraform init
ecr_url=`terraform apply -auto-approve -parallelism=50 | grep "opstree =" | cut -d'=' -f2`
ecr_repo=`echo ${ecr_url} | cut -d/ -f1`
cd -
docker build -t opstree/spring3hibernate:latest -f Dockerfile .
docker tag opstree/spring3hibernate ${ecr_repo}/opstree:latest
$(aws ecr get-login --no-include-email)
docker push ${ecr_repo}/opstree:latest
cd ecs-alb-rds
sed -i "s|opstree|${ecr_repo}/opstree:latest|g" variables.tf
terraform init
terraform apply -auto-approve -parallelism=50
rds_endpoint=`terraform output | grep db_instance_address | cut -d'=' -f2 | sed -e 's/^[ \t]*//'`
cd -
sed -i "s|mysql.okts.tk|${rds_endpoint}|g" src/main/resources/database.properties
docker build -t opstree/spring3hibernate:latest -f Dockerfile .
docker tag opstree/spring3hibernate ${ecr_repo}/opstree:latest
$(aws ecr get-login --no-include-email)
docker push ${ecr_repo}/opstree:latest
cd ecs-alb-rds
terraform apply -auto-approve -parallelism=50
