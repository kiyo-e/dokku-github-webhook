dokku-github-webhook
====================
pull request(or git push) trigger create staging each branch

** Require **  
[dokku](https://github.com/progrium/dokku)  
ruby 2.1   
sinatra

## Getting Started  
### how to install
```
cd /home/dokku  
sudo -u dokku git clone https://github.com/kiyo-e/dokku-github-webhook.git  
cd dokku-github-webhook
```

### Setting
fix servername on nginx.conf

### Run
```
cd /home/dokku/dokku-github-webhook
sudo ./bootstrap.sh
```