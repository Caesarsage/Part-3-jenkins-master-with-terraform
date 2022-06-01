output "jenkins-master-alb" {
  value = aws_lb.jenkins_alb.dns_name
}
