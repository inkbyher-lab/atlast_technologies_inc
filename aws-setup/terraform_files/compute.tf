resource "aws_ecs_cluster" "web_cluster"{
    name = "web-cluster"
}

resource "aws_ecs_task_definition" "web_task"{
    family = "web-task"
    network_mode =  "awsvpc"
    memory = "512"
    cpu = "256"
    requires_compatibilities = ["FARGATE"]

    container_definitions = jsonencode([
    {
      name      = "web-container"
      essential = true
      image     = "ubuntu:latest"
      memory    = 512
      cpu       = 256 
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    } 
    ,
  ])
}

resource "aws_ecs_service" "web_service"{
    name = "web-service"
    desired_count = 2
    task_definition = aws_ecs_task_definition.web_task.id 
    # iam role necessary as we will be using a load balancer with ecs.  will be defined later. 
    cluster = aws_ecs_cluster.web_cluster.id 
    launch_type = "FARGATE"

    network_configuration {
        security_groups = [aws_security_group.web_sg.id]
        subnets = [aws_subnet.private_subnet.id]
        assign_public_ip = false
    }
}