output "jenkins_instance_profile_arn" {
  description = "ARN of the Jenkins instance profile"
  value       = aws_iam_instance_profile.jenkins_instance_profile.arn
}
