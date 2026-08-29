# Pre-creating this log group lets us set retention. If we let
# enabled_cluster_log_types on the cluster create it implicitly, it gets
# "never expire" retention and quietly accumulates cost forever.
resource "aws_cloudwatch_log_group" "eks_control_plane" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
  tags              = var.tags
}
