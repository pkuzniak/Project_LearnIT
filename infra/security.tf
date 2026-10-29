resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-app-"
  description = "Application, administration, and monitoring access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "Public application access"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the Dell network"
  cidr_ipv4         = var.admin_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_exporter" {
  security_group_id = aws_security_group.app.id
  description       = "Infrastructure metrics for Prometheus on Dell"
  cidr_ipv4         = var.admin_cidr
  from_port         = 9100
  to_port           = 9100
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Outbound access for updates and container images"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
