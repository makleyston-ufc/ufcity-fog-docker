# UFCity Fog Computing - Docker

# Abstract
* [About](#anchor_about)
* [Contributions](#anchor_contributions)
  * [Collaborators](#anchor_colab)
* [Software Specifications](#anchor_especifications)
  * [Version](#anchor_version)
  * [Requirements](#anchor_requirements)
* [How to Use](#anchor_usage)
  * [Clone the UFCity repository](#anchor_clone)
  * [Running the installation script locally](#anchor_init_locally)
  * [Running the installation script on the Virtual Machine (VM) via Vagrant](#anchor_init_vagrant)
  * [Initializing the Docker containers](#anchor_initializing_docker_containers)
  * [Outline structure used between Docker containers](#anchor_outline_structure)


# About <a id="anchor_about"></a>
The Edge Module is a software component that integrates with the UFCity smart city solution. This component operates at the edge of the computer network, offering local services that allow the city's resources to communicate with the services of Fog Computing and Cloud Computing, abstracting the communication protocols and enabling the exchange of data. This includes both sending data from sensors present in intelligent environments and receiving commands to actuate actuators present in physical-cyber spaces.

The Edge Module performs various data processing and treatments to address issues such as data heterogeneity, dirty data, and volume. For more information, please refer to the project website's publications on the advances of this module.

# Contributions <a id="anchor_contributions"></a>
This software module, along with the other software elements present throughout the UFCity project, is the result of research carried out within the framework of the Computer Science course of the [Master's and Doctorate in Computer Science (MDCC)](http://www.mdcc.ufc.br/) program at the [Federal University of Ceará (UFC)](https://www.ufc.br/).

**Collaborators**: <a id="anchor_colab"></a>

* [Danne Makleyston Gomes Pereira](http://lattes.cnpq.br/2002489019346835), UFC.
* [Angelo Roncalli Alencar Brayner](http://lattes.cnpq.br/3895469714548887), UFC.

# Software Specifications <a id="anchor_especifications"></a>
## Version <a id="anchor_version"></a>
Current version: `v0.1`.

## Requirements <a id="anchor_requirements"></a>

* Docker engine
* Docker compose

## How to use <a id="anchor_usage"></a>

### Clone the UFCity repository <a id="anchor_clone"></a>
```
git clone https://github.com/makleyston-ufc/ufcity-fog-docker.git
cd ufcity-fog-docker
```

### Running the installation script locally <a id="anchor_init_locally"></a>

```
sudo chmod +x ./ufcity-fog.sh
sudo ./ufcity-fog.sh
```

* When prompted, provide the fog computing (local IP) and cloud computing IP addresses.

### Running the installation script on the Virtual Machine (VM) via Vagrant <a id="anchor_init_vagrant"></a>

In the `Vagrantfile`, change the following line with the settings for your execution environment.

```
config.vm.network "[network_type]", bridge: "[interface]"
```
For example: `public_network` and `wlp3s0` respectively.

Running the `Vagrantfile`:
```
vagrant up
```

### Initializing the Docker containers <a id="anchor_initializing_docker_containers"></a> 
```
sudo docker-compose up -d
```

This release (version 1.0) contains the following services:
* [fuseki](https://hub.docker.com/r/stain/jena-fuseki)
* [ufcity-handler](https://github.com/makleyston-ufc/ufcity-fog-handler)
* [ufcity-cep](https://github.com/makleyston-ufc/ufcity-fog-cep)
* [ufcity-semantic](https://github.com/makleyston-ufc/ufcity-fog-semantic)
* [mqtt](https://hub.docker.com/_/eclipse-mosquitto)
* [elasticsearch](https://hub.docker.com/_/elasticsearch/)
* [fluentd](https://hub.docker.com/_/fluentd)
* [kibana](https://hub.docker.com/_/kibana/)
* [mongo database](https://hub.docker.com/_/mongo)

Go to `http://<fog_computing_ip>:80` to access the services present on the node.

### Outline structure used between Docker containers <a id="anchor_outline_structure"></a> 
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
