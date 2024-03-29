resource "aws_security_group" "ecs_alb_sg" {
  name        = "ecs-alb-sg"
  description = "ecs-alb-sg"
  vpc_id      = var.vpc_main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-alb-sg"
  }
}