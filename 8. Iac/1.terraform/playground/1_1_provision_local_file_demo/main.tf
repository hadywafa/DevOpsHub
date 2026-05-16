resource "local_file" "file1" {
  filename = "./file1.txt"
  content  = "Hello from Terraform!"
}

resource "local_sensitive_file" "file2" {
  filename = "./file2.txt"
  content  = "this is very secure content!"
}

resource "local_file" "file3" {
  filename = "./file3.txt"
  content  = var.env_prefix == "prod" ? "this is production" : "this is development"
}
