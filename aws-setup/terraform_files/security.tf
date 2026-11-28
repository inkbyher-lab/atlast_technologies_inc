resource "aws_network_acl" "acl" {
  subnet_ids = [aws_subnet.public_subnet.id]
  vpc_id     = aws_vpc.mainvpc.id

  egress {
    rule_no    = 100
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "Allow"
    protocol   = -1
  }

  ingress {
    rule_no    = 100
    from_port  = 80
    to_port    = 80
    protocol   = -1
    action     = "Allow"
    cidr_block = "0.0.0.0/0"
  }


}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  # no rules defined, blocking all default traffic
}

resource "aws_security_group" "web_sg" {
  name        = "WEB-SG"
  description = "web security group, allowing HTTP and HTTPS"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl-rate-limiting-rule"
  description = "CloudFront rate limiting statement."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "web-acl-rule-metric-name"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true # for visibility
    metric_name                = "web-acl-metric-name"
    sampled_requests_enabled   = true # helpful for debugging
  }
}