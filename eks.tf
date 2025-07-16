resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-cluster-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-cluster-sg"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  vpc_id          = aws_vpc.main.id
  cluster_security_group_id = aws_security_group.eks_cluster_sg.id
}
