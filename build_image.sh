git clone https://github.com/jupyterhub/jupyterhub
cp Dockerfile jupyterhub
cd jupyterhub
sudo docker build --rm=true -t bioxfu/jupyter .
