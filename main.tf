provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft-server"
  description = "Security group for Minecraft server"

  ingress {
    from_port   = 25565  # Minecraft default port
    to_port     = 25565  # Minecraft default port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port  = 22  # SSH port
    to_port    = 22  # SSH port
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  
  }

resource "tls_private_key" "minecraft_terra" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "minecraft_terra" {
  key_name   = "minecraft_terra"
  public_key = tls_private_key.minecraft_terra.public_key_openssh

  provisioner "local-exec" {
  command = "echo '${tls_private_key.minecraft_terra.private_key_pem}' > minecraft.pem"
}

}


  


resource "aws_instance" "minecraft"{
    ami = "ami-076bca9dd71a9a578"
    instance_type = "t2.medium"
    key_name = aws_key_pair.minecraft_terra.key_name

    tags = {
        Name = "minecraft_terra"
    }

    vpc_security_group_ids = [aws_security_group.minecraft.id]


    user_data_base64 = base64encode(file("./userdata.sh"))


}



output "public_ip" {
    value = aws_instance.minecraft.public_ip
}

output "public_dns" {
    value = aws_instance.minecraft.public_dns
}


output "port" {
    value = "25565"
}





