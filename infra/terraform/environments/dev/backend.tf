terraform {
  backend "s3" {
    bucket         = "gagos"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "bootcamp-tfstate-lock"
    profile        = "gagos"

  }
}
