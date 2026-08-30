resource "local_file" "project_docs" {
  filename = "./${var.project_name}.txt"
  content  = "${var.project_name}: \n is an awesome project"
}

resource "local_file" "file1" {
  filename = "./file1.txt"
  content  = "1. Hello from Terraform!"
}

resource "local_sensitive_file" "file2" {
  filename = "./file2.txt"
  content  = "2. this is very secure content!"
}

resource "local_file" "file3" {
  filename = "./file3.txt"
  content  = var.env_prefix == "prod" ? "this is production" : "this is development"
}
