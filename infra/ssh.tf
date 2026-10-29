resource "aws_key_pair" "admin" {
  key_name_prefix = "${var.project_name}-admin-"
  public_key      = file(pathexpand("~/.ssh/id_ed25519.pub"))

  tags = {
    Name = "${var.project_name}-admin"
  }
}
