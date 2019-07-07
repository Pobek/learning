resource "aws_s3_bucket" "rst-test-s3" {
    bucket = "rst-test-s3"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }

    tags {
        Name = "rst-test-s3"
    }
}
