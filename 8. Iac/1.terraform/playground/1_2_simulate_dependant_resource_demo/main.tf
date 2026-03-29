resource "null_resource" "setup" {
  depends_on = [null_resource.provision]
  provisioner "local-exec" {
    command = "echo 2.Setting up"
  }
}

resource "null_resource" "provision" {
  provisioner "local-exec" {
    command = "echo 1.Provisioning Infrastructure"
  }
}

resource "null_resource" "app_start" {
  depends_on = [null_resource.setup]
  provisioner "local-exec" {
    command = "echo 3.Starting app"
  }
}
