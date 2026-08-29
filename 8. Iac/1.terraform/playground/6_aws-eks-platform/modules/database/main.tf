resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "db" {
  name_prefix = "${var.name_prefix}-db-"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# Only the EKS cluster's own security group can reach Postgres - no CIDR
# rule, no public endpoint.
resource "aws_security_group_rule" "db_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.eks_cluster_security_group_id
}

resource "aws_db_instance" "this" {
  identifier                = "${var.name_prefix}-postgres"
  engine                    = "postgres"
  engine_version            = "16"
  instance_class            = "db.t3.medium"
  allocated_storage         = 50
  storage_encrypted         = true
  db_name                   = "appdb"
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.db.id]
  username                  = var.admin_username
  password                  = var.admin_password
  multi_az                  = true
  backup_retention_period   = 7
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-postgres-final"

  tags = var.tags
}
