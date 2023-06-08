# UFCity Fog Computing - Docker

### Requirements
* Docker engine
* Docker compose

### How to use:

#### Clone the UFCity repository:
```
git clone https://github.com/makleyston-ufc/ufcity-fog-docker.git
cd ufcity-fog-docker
```

#### Define the <HOST_IP> and run the configuration:
* Insert the host's IP address in the `ip_host` attribute and the cloud's IP address in the `ip_cloud` in the ufcity-fog.sh file:
```
# HOST_IP
ip_host="<HOST_IP>"

# CLOUD_IP
ip_cloud="<CLOUD_IP>"
```
* Make sure to replace `<HOST_IP>` with the actual IP address of the host and `<CLOUD_IP>` with IP address of the cloud.
* Run the following command with administrator privileges to execute the script:
```
sudo ./ufcity-fog.sh
```

Initializing the *containers*: 
```
sudo docker-compose up -d
```

This release (version 1.0) contains the following *services*:
* [fuseki](https://hub.docker.com/r/stain/jena-fuseki)
* [ufcity-handler](https://github.com/makleyston-ufc/ufcity-fog-handler)
* [ufcity-cep](https://github.com/makleyston-ufc/ufcity-fog-cep)
* [ufcity-semantic](https://github.com/makleyston-ufc/ufcity-fog-semantic)
* [mqtt](https://hub.docker.com/_/eclipse-mosquitto)
* [elasticsearch](https://hub.docker.com/_/elasticsearch/)
* [fluentd](https://hub.docker.com/_/fluentd)
* [kibana](https://hub.docker.com/_/kibana/)
* [mongo database](https://hub.docker.com/_/mongo)

Go to `http://<host_ip>:80` to access the services present on the node.

### Outline structure used between *containers*:
#### Edge computing

| _MQTT Topics_                                      | _Example_                            | _Message_     |
|----------------------------------------------------|--------------------------------------|---------------|
| **Edge Module: Publish**                           |                                      |               |
| resource_data/[uuid_device]/[uuid_resource]        |                                      | resource_json |
| removed_resource/[uuid_device]/[uuid_resource]     |                                      | uuid_resource |
| registered_resource/[uuid_device]/[uuid_resource]  |                                      | resource_json |
| device/[uuid_device]                               |                                      | device_json   |
|                                                    |                                      |               |
| **Edge Module: Subscribe**                         |                                      |               |
| commands_fog_to_edge/[uuid_device]/[uuid_resource] | commands_fog_to_edge/[uuid_device]/+ | resource_json |
| resend/[uuid_device]                               | resend/[uuid_device]                 | uuid_device   |
| resend/[uuid_device]/[uuid_resource]               | resend/[uuid_device]/+               | uuid_resource |


#### Fog computing
 
| _MQTT Topics_                                          | _Example_             | _Message_     |
|--------------------------------------------------------|-----------------------|---------------|
| **Fog computing <> Edge Module: Publish**              |                       |               |
| commands_fog_to_edge/[uuid_device]/[uuid_resource]     |                       | resource_json |
| resend/device                                          |                       | uuid_device   |
| resend/device/resource                                 |                       | uuid_resource |
|                                                        |                       |               |
| **Fog computing <> Edge Module: Subscribe**            |                       |               |
| resource_data/[uuid_device]/[uuid_resource]            | resource_data/+/+     | resource_json |
| removed_resource/[uuid_device]                         | removed_resource/+    | uuid_resource |
| registered_resource/[uuid_device]                      | registered_resource/+ | resource_json |
| device/[uuid_device]                                   | device/+              | device_json   |
|                                                        |                       |               |
| **Fog computing <> Cloud computing: Publish**          |                       |               |
| resource_data/[uuid_fog]/[uuid_device]/[uuid_resource] |                       | resource_json |
