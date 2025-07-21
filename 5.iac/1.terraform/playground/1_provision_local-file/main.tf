resource "local_file" "file1" {
  filename = "./file1.txt"
  content  = "Hello from Terraform!"
}