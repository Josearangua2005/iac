[todoing_servers]
${server_ip}

[todoing_servers:vars]
ansible_user=${ssh_user}
ansible_ssh_private_key_file=${private_key}
ansible_python_interpreter=/usr/bin/python3