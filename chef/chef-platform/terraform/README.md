# Instructions

To utilize this terraform it will require you create a tfvars file (example below). You will also have to authenticate against AWS and specify a specific AWS CLI profile for the script to utilize


Example psc-aws-chef-arch.tfvars
```
aws_cli_profile     = "AWSAdministratorAccess-927707335858" #what is the AWS profile you are using
region              = "us-east-1"           #What region
enviornment         = "dev"                 #what enviornment
production          = false                 #deploy a production env
cluster_version     = "1.28"                #EKS version
```

then you run terraform apply -var-file="psc-aws-chef-arch.tfvars"



Please note this is a work in progress and will change as completed. The target deployment looks like this https://miro.com/app/board/uXjVN-yIDhw=/?share_link_id=491082695143


### TODO:
- [x] Deploy VPC with proper CIDR
- [x] Deploy EKS in VPC
- [ ] Deploy CoreDNS
- [x] Deploy kube-proxy
- [ ] Deploy EBS CSI Driver
- [ ] Deploy external secrets
- [ ] Deploy EKS pod identity
- [ ] Deploy cloud watch agent
- [ ] Deploy Guard Duty agent (if required)

- [ ] Enable the WAF
- [ ] Fix the node groups to have labels
- [ ] Add the storage tier node group (DB stuff)
- [ ] Add fargate profiles
- [ ] link EKS roles to SSO roles
- [ ] Configure and Deploy ARGO (to manage the auto deployments)
- [ ] Test 
- [ ] Ensure all labels/selectors match what we are deploying with Replicated