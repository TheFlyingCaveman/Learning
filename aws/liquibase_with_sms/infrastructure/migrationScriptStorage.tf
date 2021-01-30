# resource "aws_kms_key" "mykey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

resource "aws_s3_bucket" "b" {
  bucket = "liquibbasescriptstorage"
  acl    = "public-read"

#   versioning {
#     enabled = true
#   }

  tags = {
    Name        = "LiquibaseMigrationScriptStorage"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = aws_kms_key.mykey.arn
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }
}
