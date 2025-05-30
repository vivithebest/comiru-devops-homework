module "alb_sg_80_http" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.project_name}-alb-sg-80-http"
  description = "Security group for web-server with HTTP ports open"
  vpc_id      = aws_vpc.main.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
}

module "alb_sg_443_https" {
  source = "terraform-aws-modules/security-group/aws//modules/https-443"

  name        = "${var.project_name}-alb-sg-80-https"
  description = "Security group for web-server with HTTPS ports open"
  vpc_id      = aws_vpc.main.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

}
