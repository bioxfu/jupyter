sudo docker kill jupyter
sudo docker rm jupyter
sudo docker run -p 8000:8000 -d --name jupyter -v $PWD:/srv/jupyterhub/xfu bioxfu/jupyter
