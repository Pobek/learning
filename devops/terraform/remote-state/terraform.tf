terraform {
    backend "s3" {
        encrypt = true
        bucket = "rst-test-s3"
        dynamodb_table = "rst-test-dynamodb"
        region = "us-east-1"
        key = "./terraform.tfstate"
    }
}
