#!/bin/bash
set -eux

sudo apt-get update -y
sudo apt-get install -y curl unzip git ca-certificates

############################
# Secure SSH configuration
############################
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

sudo systemctl restart ssh

chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

######################################
# Install Docker + Docker Compose v2
######################################
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

#############################################
# Insert deploy SSH key for the ubuntu user
#############################################
touch /home/ubuntu/.ssh/authorized_keys

%{ for key in client_public_ssh_keys ~}
echo "${key}" >> /home/ubuntu/.ssh/authorized_keys
%{ endfor }

chmod 600 /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

#######################################
# Secure SSH configuration + port 443
#######################################
cat <<EOF > /home/ubuntu/.ssh/config
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile /home/ubuntu/.ssh/deploy_key
  StrictHostKeyChecking accept-new
EOF

chmod 600 /home/ubuntu/.ssh/config
chown ubuntu:ubuntu /home/ubuntu/.ssh/config

##########################################################################
# Clone private repository with submodules (using GitHub token from SSM)
##########################################################################

echo "=== Cloning Docker Compose repository with GitHub token ==="

# Create .netrc in the Ubuntu user's home directory
sudo -u ubuntu -H bash -c "printf 'machine github.com\n login token\n password ${github_token}\n' > /home/ubuntu/.netrc"
chmod 600 /home/ubuntu/.netrc
chown ubuntu:ubuntu /home/ubuntu/.netrc

# Clone repo with submodules as ubuntu
sudo -u ubuntu -H bash -c "
  cd /home/ubuntu/ &&
  git clone --recurse-submodules https://github.com/resilmesh2/Docker-Compose.git
"

######################
# Final verification
######################
echo ""
echo "==================================="
echo "FINAL VERIFICATION"
echo "==================================="
echo "Docker info:"
sudo docker info | grep "Docker Root Dir" || echo "Docker no configurado"
echo ""
echo "Script completado: $(date)"