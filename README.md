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
You should be enable pull from github.
fix servername on nginx.conf  
set github webhook to servername  
push or Pull Request event  
 
### Run
```
cd /home/dokku/dokku-github-webhook
sudo ./bootstrap.sh
```


### etc.
if you need default env(RAILS_ENV or DATABASE_URL, etc...), you use [dokku-default-env plugin](https://github.com/kiyo-e/dokku-default-env).

