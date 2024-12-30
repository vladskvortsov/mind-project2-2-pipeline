module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.frontend_bucket_name
  
  versioning = {
    enabled = true
  }

}

module "s3-bucket_object" {
  depends_on = [module.s3_bucket]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"

  bucket       = var.frontend_bucket_name
  file_source  = "../frontend/index.html"
  key          = "index.html"
  content_type = "html"
  force_destroy = true
}

resource "local_file" "config_json" {
  filename = "../frontend/config.json"
  content  = <<EOF
    {
    "BACKEND_RDS_URL": "http://${module.alb.dns_name}:8001/test_connection/",
    "BACKEND_REDIS_URL": "http://${module.alb.dns_name}:8002/test_connection/"
    }
  EOF
}

module "s3-bucket_object-2" {
  depends_on = [resource.local_file.config_json, module.s3_bucket]
  source     = "terraform-aws-modules/s3-bucket/aws//modules/object"

  bucket       = var.frontend_bucket_name
  file_source  = "../frontend/config.json"
  key          = "config.json"
  content_type = "json"
  force_destroy = true

}