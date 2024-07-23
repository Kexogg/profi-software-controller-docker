# IP-COM ProFi Software Controller Docker Image
This software is provided as-is without any warranty.
I am not affiliated with IP-COM in any way. This project is not endorsed by IP-COM. This repository does not contain any IP-COM software.
I do not own the IP-COM ProFi software controller. I am not responsible for any consequences and/or damage caused by using this software. Use at your own risk.

This Docker image can be used to launch the IP-COM ProFi software controller in a Docker container, Wine-free.

This image was tested with the ProFi software controller version 1.0.4.0 (2627). I own only one access point, and most of the features were not tested. Online account functionality was not tested.
## Usage
To run controller, you must first extract original files from the ProFi software. You can download the package from the [IP-COM website](https://www.ip-com.com.cn/en/product/download/SoftwareController.html). 

1. Install IP-COM ProFi software controller on Windows Machine
2. Go to the installation directory and launch the controller with the following command:
```Software Controller.exe /create-i4j-log```
3. The controller will create a log file. Open the log file and find the path to the JAR file. It should look like this:
`[3:434] extracting C:\Users\user\AppData\Local\Temp\e4j2AE.tmp_dir1721469895\soft_ac-0.0.1-SNAPSHOT.jar`
4. Locate NGINX files in the installation directory. They should be in the `nginx` folder.
5. 1. If you want to build the Docker image from the Dockerfile, copy the JAR file and the NGINX files to the `files` directory.
   2. If you want to use the pre-built image, mount the JAR file and the NGINX files to the `/ipcom/` directory in the container. Do NOT mount entire folder (e.g. `/ipcom/:/ipcom/`), only the files themselves.

### Deployment
You can deploy the controller using Docker Compose. Here is an example of a `docker-compose.yml` file:
```yaml
services:
   controller:
      build: .
      # Uncomment the following line to use the image from the GitHub Container Registry
      #image: ghcr.io/kexogg/profi-software-controller-docker:master
      depends_on:
         - mongo
         - redis
      volumes:
         # Uncomment the following lines to mount the jar file and nginx folder if you didn't build the image yourself
         #- ./files/soft_ac-0.0.1-SNAPSHOT.jar:/ipcom/soft_ac-0.0.1-SNAPSHOT.jar
         #- ./files/nginx/:/ipcom/nginx/
         - ipcom_data:/ipcom/data/
      networks:
         internal:
         dockervlan:
            ipv4_address: 10.0.70.10 # Change the IP address if needed
   mongo:
      image: mongo:latest
      environment:
         MONGO_INITDB_ROOT_USERNAME: admin # Can be changed
         MONGO_INITDB_ROOT_PASSWORD: admin # Can be changed
         MONGO_INITDB_DATABASE: soft_ac # Do not change
      volumes:
         - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
         - mongo_data:/data/db
      networks:
         internal:
   redis:
      image: redis:latest
      command: /bin/sh -c "redis-server --requirepass fqta,dacb21db" # Do not change the password
      volumes:
         - redis_data:/data
      networks:
         internal:
volumes:
   mongo_data:
   redis_data:
   ipcom_data:
networks:
   internal:
      external: false
   dockervlan:
      name: dockervlan
      driver: macvlan
      driver_opts:
         parent: ens18 # Set the parent interface to your network interface
      ipam:
         config: # Change the IP settings if needed
            - subnet: "10.0.0.0/8"
              ip_range: "10.0.70.0/24"
              gateway: "10.0.0.1"
```
You need to manually set parent interface and IP settings in the `docker-compose.yml` file. You can find the interface name by running `ip a` command.

### Environment Variables
| Variable | Description | Default |
| --- | --- | --- |
| `MONGODB_HOST` | MongoDB host | `mongo` |
| `MONGODB_PORT` | MongoDB port | `27017` |
| `REDIS_HOST` | Redis host | `redis` |
| `REDIS_PORT` | Redis port | `6379` |


### Database
Controller uses MongoDB as a database. You can find credentials in `mongo-init.js` file.