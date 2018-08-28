sudo docker rmi $(sudo docker images -q -f dangling=true)
