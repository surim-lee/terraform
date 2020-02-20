provider "aws" {
    profile = "aws_provider"
    region  = var.my_region
    access_key = var.my_access_key
    secret_key = var.my_secret_key
}

resource "aws_vpc" "landingProject_DevOps" {
   cidr_block = "10.10.0.0/16"
   enable_dns_hostnames = "true"
   tags =  { Name = "landingProject_DevOps"}
}

resource "aws_internet_gateway" "landingProject_DevOps" {
    vpc_id = aws_vpc.landingProject_DevOps.id
    tags = { Name = "landingProject_DevOps"}
}

resource "aws_subnet" "Dev_public1" {
    vpc_id = aws_vpc.landingProject_DevOps.id
    cidr_block = ""
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true
    tags = { Name = "Dev_public1"}
}

resource "aws_subnet" "Dev_public2" {
    vpc_id = aws_vpc.landingProject_DevOps.id
    cidr_block = ""
    availability_zone = "ap-northeast-2c"
    map_public_ip_on_launch = true
    tags = { Name = "Dev_public2"}
}

resource "aws_subnet" "Dev_private1" {
    vpc_id = aws_vpc.landingProject_DevOps.id
    cidr_block = ""
    availability_zone = "ap-northeast-2a"
    tags = { Name = "Dev_private1"}
}

resource "aws_subnet" "Dev_private2" {
    vpc_id = aws_vpc.landingProject_DevOps.id
    cidr_block = ""
    availability_zone = "ap-northeast-2c"
    tags = { Name = "Dev_private2"}
}

resource "aws_eip" "Dev_nat_ip" {
   vpc = true
   depends_on  = [aws_internet_gateway.landingProject_DevOps]
   tags = { Name = "Dev_nat_ip"}
}

resource "aws_nat_gateway" "Dev_natgw" {
  allocation_id = aws_eip.Dev_nat_ip.id
  subnet_id     = aws_subnet.Dev_public1.id
  tags = { Name = "Dev_natgw"}
}

resource "aws_route_table" "Dev_public" {
  vpc_id = aws_vpc.landingProject_DevOps.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.landingProject_DevOps.id
  }
  tags = { Name = "Dev_public" }
}

resource "aws_route_table" "Dev_private" {
  vpc_id = aws_vpc.landingProject_DevOps.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id =  aws_nat_gateway.Dev_natgw.id
  }
  tags = { Name = "Dev_private" }
}

resource "aws_route_table_association" "Dev_public1" {
  subnet_id      = aws_subnet.Dev_public1.id
  route_table_id = aws_route_table.Dev_public.id
}

resource "aws_route_table_association" "Dev_public2" {
  subnet_id      = aws_subnet.Dev_public2.id
  route_table_id = aws_route_table.Dev_public.id
}

resource "aws_route_table_association" "Dev_private1" {
  subnet_id      = aws_subnet.Dev_private1.id
  route_table_id = aws_route_table.Dev_private.id
}

resource "aws_route_table_association" "Dev_private2" {
  subnet_id      = aws_subnet.Dev_private2.id
  route_table_id = aws_route_table.Dev_private.id
}


resource "aws_security_group" "Dev_sg1" {
    name        = "Dev_sg1"
    vpc_id      = aws_vpc.landingProject_DevOps.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "Dev_sg2" {
    name        = "Dev_sg2"
    vpc_id      = aws_vpc.landingProject_DevOps.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.10.11.0/24"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "Dev_sg3" {
    name        = "Dev_sg3"
    vpc_id      = aws_vpc.landingProject_DevOps.id

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.10.11.0/24"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "Dev_sg_db" {
    name        = "Dev_sg_db"
    vpc_id      = aws_vpc.landingProject_DevOps.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.10.0.0/16"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "Dev_Front1" {
    instance_type           = "t2.micro"
    ami                     = var.image_id_front
    key_name                = var.key_name
    vpc_security_group_ids  = [aws_security_group.Dev_sg2.id]
    subnet_id               = aws_subnet.Dev_private1.id
    associate_public_ip_address = false
    tags = { Name = "Dev_Front1"}
}

resource "aws_instance" "Dev_Front2" {
    instance_type           = "t2.micro"
    ami                     = var.image_id_front
    key_name                = var.key_name
    vpc_security_group_ids  = [aws_security_group.Dev_sg2.id]
    subnet_id               = aws_subnet.Dev_private2.id
    associate_public_ip_address = false
    tags = { Name = "Dev_Front2"  }
}

resource "aws_instance" "Dev_Back1" {
    instance_type           = "t2.micro"
    ami                     = var.image_id_back
    key_name                = var.key_name
    vpc_security_group_ids  = [aws_security_group.Dev_sg3.id]
    subnet_id               = aws_subnet.Dev_private1.id
    tags = {  Name = "Dev_Back1"  }
}

resource "aws_instance" "Dev_Back2" {
    instance_type           = "t2.micro"
    ami                     = var.image_id_back
    key_name                = var.key_name
    vpc_security_group_ids  = [aws_security_group.Dev_sg3.id]
    subnet_id               = aws_subnet.Dev_private2.id
    tags = { Name = "Dev_Back2"}
}

resource "aws_alb_target_group" "Dev_Front" {
  name     = "Dev-Front"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.landingProject_DevOps.id

 health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    path                = var.target_group_path
    interval            = 30
    port                = 80
  }
  tags = { Name   = "Dev_Front" }
}

resource "aws_alb_target_group" "Dev_Back" {
  name     = "Dev-Back"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.landingProject_DevOps.id

 health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    path                = var.target_group_path
    interval            = 30
    port                = 8080
  }
  tags = { Name  = "Dev_Back"}
}

resource "aws_alb_target_group_attachment" "Dev_Front1" {
  target_group_arn = aws_alb_target_group.Dev_Front.arn
  target_id        = aws_instance.Dev_Front1.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "Dev_Front2" {
  target_group_arn = aws_alb_target_group.Dev_Front.arn
  target_id        = aws_instance.Dev_Front2.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "Dev_Back1" {
  target_group_arn = aws_alb_target_group.Dev_Back.arn
  target_id        = aws_instance.Dev_Back1.id
  port             = 8080
}

resource "aws_alb_target_group_attachment" "Dev_Back2" {
  target_group_arn = aws_alb_target_group.Dev_Back.arn
  target_id        = aws_instance.Dev_Back2.id
  port             = 8080
}

resource "aws_alb" "Dev_external" {
    name     = "Dev-external"
    subnets         = [aws_subnet.Dev_public1.id, aws_subnet.Dev_public2.id]
    security_groups = [aws_security_group.Dev_sg1.id]
    instances       = [aws_instance.Dev_Front1.id, aws_instance.Dev_Front2.id]

    listener {
        instance_port       = 80
        instance_protocol   = "http"
        lb_port             = 80
        lb_protocol         = "http"
    }
}

resource "aws_alb" "Dev_internal" {
    name            = "Dev-internal"
    internal        = true
    subnets         = [aws_subnet.Dev_private1.id, aws_subnet.Dev_private2.id]
    security_groups = [aws_security_group.Dev_sg3.id]
    instances       = [aws_instance.Dev_Back1.id, aws_instance.Dev_Back2.id]

    listener {
        instance_port       = 8080
        instance_protocol   = "http"
        lb_port             = 8080
        lb_protocol         = "http"
    }
}

resource "aws_db_instance" "Dev_db" {
    allocated_storage    = 20
    engine               = "mysql"
    engine_version       = "5.7.26"
    instance_class       = "db.t2.micro"
    username             = var.db_username
    password             = var.db_password
    port                 = var.db_port
    vpc_security_group_ids = [aws_security_group.Dev_sg_db.id]
    skip_final_snapshot    = true
    multi_az               = true
}


resource "aws_launch_template" "Front-end" {
  name                 = "Front-end"
  image_id             = var.image_id_front
  instance_type        = "t2.micro"

  placement {
    availability_zones          = ["ap-northeast-2a", "ap-northeast-2c"]
  }
}

resource "aws_autoscaling_group" "front_auto" {
  name                        = "front_auto"
  desired_capacity            = 4
  max_size                    = 2
  min_size                    = 1
  health_check_grace_period   = 300
  health_check_type           = "ELB"
  availability_zones          = ["ap-northeast-2a", "ap-northeast-2c"]

  launch_template {
    id         = aws_launch_template.Front-end.id
    version    = "latest"
  }
}

resource "aws_launch_template" "Back-end" {
  name                 = "Back-end"
  image_id             = var.image_id_back
  instance_type        = "t2.micro"

  placement {
    availability_zones          = ["ap-northeast-2a", "ap-northeast-2c"]
  }
}

resource "aws_autoscaling_group" "back_auto" {
  name                        = "back_auto"
  desired_capacity            = 4
  max_size                    = 2
  min_size                    = 1
  health_check_grace_period   = 300
  health_check_type           = "ELB"
  availability_zones          = ["ap-northeast-2a", "ap-northeast-2c"]

  launch_template {
    id         = aws_launch_template.Back-end.id
    version    = "latest"
  }
}
