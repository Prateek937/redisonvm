terraform {
  backend "s3" {
    bucket         = "redis-vm-state"
    key            = "state"
    region         = "ap-south-1"
    dynamodb_table = "redisvmstate"
  }
}