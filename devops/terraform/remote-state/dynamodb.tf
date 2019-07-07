resource "aws_dynamodb_table" "rst-test-dynamodb" {
    name = "rst-test-dynamodb"
    hash_key = "LockID"
    read_capacity = 20
    write_capacity = 20
    
    attribute {
        name = "LockID"
        type = "S"
    }

    tags {
        Name = "rst-test-dynamodb"
    }
}
