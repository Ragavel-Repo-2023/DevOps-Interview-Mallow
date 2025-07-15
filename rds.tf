resource "aws_db_subnet_group" "main" {
  name       = "eks-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "eks-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "eks-rds-sg"
  description = "Allow database access from EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Postgres access from EKS worker nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-rds-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "rails-postgres-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  tags = {
    Name = "rails-postgres-db"
  }
}
