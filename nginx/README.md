# Nginx
- The `etc/nginx/nginx.conf` file contains global configuration of the server, which can be changed. Like: number or worker process, the number of connections a worker process can handle.
- Another configuration file is `etc/nginx/nginx/conf.d/default.conf`
- 

## Commands
 - `nginx -s reload`
   - Reload the nginx configuration (if something changed, to apply these changes)
 - `ps -C nginx -f` 
   - Check the processes running for nginx