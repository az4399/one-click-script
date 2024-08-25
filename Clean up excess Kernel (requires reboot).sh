apt -y remove --purge $(dpkg -l | grep linux-image | awk '{print$2}' | grep -v $(uname -r))
