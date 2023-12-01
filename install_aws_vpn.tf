provider "aws"{
	region		= "us-east-1"
}



resource "aws_instance" "openvpn_server"{
	ami			= "ami-053b0d53c279acc90"
	instance_type	= "t2.micro"
	vpc_security_group_ids	= [aws_security_group.my_webserver.id]
	
    key_name	= "id_rsa"
	user_data	= file("user_data.sh")
	tags		= {
		Name	= "Openvpn Server for CTF"
		Owner	= "Daniel"
		Project	= "Terraform lessons"
	}
}



resource "aws_security_group" "my_webserver"{
	name		= "WebServer Sucurity Group"
	description	= "My First Security Group"

	ingress{
		from_port	= 80
		to_port		= 80
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress{
		from_port	= 443
		to_port		= 443
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress{
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	egress{
		from_port	= 0		# 0 - any traffic
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]

	}

	tags	= {
		Name	= "open_vpn_server"
		Owner	= "Daniel"
	}
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "sleep 60 && scp -i 'id_rsa.pem' -o StrictHostKeyChecking=no ubuntu@${aws_instance.openvpn_server.public_ip}:/home/ubuntu/client.ovpn ."
  }
  provisioner "local-exec"{
  	when = destroy
  	command = "rm client.ovpn"
  }
}

output "name" {
	value = aws_instance.openvpn_server.public_ip
}