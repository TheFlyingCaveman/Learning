codedeploy_user_iam_object = {
    groupName = "Testing_CodeDeploy_Access"
    userName = "AzureDevOps_CodeDeploy_Service_Connection"
    path = "/testing_codedeploy/"
}

pretty_domain = {
    aws_route53_zone_name = "experiments.joshuamiller.net"
    aws_route53_record_name = "codedeploy.experiments.joshuamiller.net"
}

force_destroy_items = true