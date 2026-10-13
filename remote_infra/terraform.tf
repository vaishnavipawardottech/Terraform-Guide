terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.68.0"
    }
  }

  backend "s3" {
  bucket = "my-remote-s3-bucket"
  key    = "terraform.tfstate"
  region = "us-west-2"
  dynamodb_table = "state-table"
}


}

