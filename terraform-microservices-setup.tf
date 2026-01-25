provider "aws" {
  // Specify the AWS region to deploy resources in
  region = "us-west-2"
}

resource "aws_ecs_cluster" "microservices_cluster" {
  // Define an ECS cluster to run the microservices
  name = "microservices-cluster"
}

resource "aws_ecs_task_definition" "microservice_task" {
  // Define the ECS task definition for the microservice
  family                = "microservice"
  network_mode           = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  // Define the container settings for the microservice
  container_definitions = jsonencode([
    {
      name      = "my-microservice"
      image     = "my-docker-repo/my-microservice:latest" // Docker image for the microservice
      cpu       = 256
      memory    = 512
      essential = true
      port_mappings = [
        {
          containerPort = 80 // Port on which the container listens
          hostPort      = 80 // Port on the host
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "microservice_service" {
  // Define the ECS service to run the microservice tasks
  name            = "microservice-service"
  cluster         = aws_ecs_cluster.microservices_cluster.id
  task_definition = aws_ecs_task_definition.microservice_task.arn
  desired_count   = 3 // Number of instances of the microservice to run

  launch_type = "FARGATE" // Use Fargate for serverless compute

  network_configuration {
    // Define the network settings for the service
    subnets         = ["subnet-your-subnet-id"] // Replace with your subnet IDs
    assign_public_ip = true
  }
}
