resource "local_file" "pet" {
  filename = "./pets.txt"
  content = "we love pets!"
  file_permission = "0700"
}
