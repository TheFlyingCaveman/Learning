# Rolling deployments with ECS and Fargate

## Helpful Articles

* [Subnet per availability zone](https://medium.com/@maneetkum/create-subnet-per-availability-zone-in-aws-through-terraform-ea81d1ec1883)
* [Terraform ECS and Fargate](https://dev.to/txheo/a-guide-to-provisioning-aws-ecs-fargate-using-terraform-1joo)
* [Networks for Amazon ECS and Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-configure-network.html)
    * Or, how to keep containers private while still leveraging Docker Hub (at the time of writing, item #5)
    * > For Auto-assign Public IP, choose whether to have your tasks receive a public IP address. If you are using Fargate tasks, in order for the task to pull the container image it must either use a public subnet and be assigned a public IP address or a private subnet that has a route to the internet or a NAT gateway that can route requests to the internet.
* [ECS with Private ECR](https://www.easydeploy.cloud/blog/how-to-create-private-link-for-ecr-to-ecs-containers-to-save-nat-gatewayec2-other-charges/)
    * [Amazon ECS interface VPC endpoints (AWS PrivateLink)](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html)

## TODOS

- [ ] Apply policies to Private Links [to further restrict access](https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html)