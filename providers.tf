terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA4WCCWFHITN4OLNPF"
  secret_key = "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"
}