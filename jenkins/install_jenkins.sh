#bin/bash
sudo apt update
sudo apt install fontconfig openjdk-21-jre -y
sudo apt install -y wget
 sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
echo "Jenkins has been installed and started successfully."
echo "You can access Jenkins at http://localhost:8080"
echo "Please run 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' to get the initial admin password."
echo "After that, you can set up Jenkins through the web interface."
echo "For more information, visit https://www.jenkins.io/doc/book/installing/."
echo "To stop Jenkins, use 'sudo systemctl stop jenkins'."
echo "To restart Jenkins, use 'sudo systemctl restart jenkins'."
echo "To check the status of Jenkins, use 'sudo systemctl status jenkins'."
echo "To uninstall Jenkins, use 'sudo apt-get remove jenkins -y'."
echo "To remove Jenkins and its configuration files, use 'sudo apt-get purge jenkins -y'."
echo "To remove Jenkins and its dependencies, use 'sudo apt-get autoremove -y'."
echo "To remove the Jenkins repository, use 'sudo rm /etc/apt/sources.list.d/jenkins.list'."
echo "To remove the Jenkins keyring, use 'sudo rm /etc/apt/keyrings/jenkins-keyring.asc'."
echo "To clean up the package cache, use 'sudo apt-get clean'."
echo "To update the package list