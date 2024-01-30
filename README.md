<div class="view">
<img src="https://makleyston-ufc.github.io/ufcity/assets/img/ufcity-logo.png" alt="UFCity" width="200"/>
<p><b>Building smart cities smartly.</b></p>
</div>

<div class="view">
  <a href="https://makleyston-ufc.github.io/ufcity"> <img src="https://img.shields.io/badge/UFCity_webpage-0076D6?style=for-the-badge&logo=internetexplorer&logoColor=white"> </a>

  <a href="https://github.com/makleyston-ufc/ufcity-fog-docker"> <img src="https://img.shields.io/badge/View_on_GitHub-181717?style=for-the-badge&logo=github&logoColor=white"> </a>
</div>

# UFCity - Fog computing

## Abstract
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


## About <a id="anchor_about"></a>
The Fog computing - Docker is a set of software components that integrates with the UFCity smart city solution. This set component operates in the UFCity network between edge and cloud computing, offering services like semantic annotation, data processing, and complex events processing. This set of software components works transparently in each fog computing node of UFCity. So, all the communication protocols and message structures are ready inside. See the last topic in the README for more info about the message structure.

Some services in fog computing nodes enable the data views in operation. So, this software set has a service data monitor. Visit the http://<fog_computing_ip>:80.

See the project webpage and repositories on GitHub for more info.

## Contributions <a id="anchor_contributions"></a>
This set of software components, along with the other software elements present throughout the UFCity project, is the result of research carried out within the framework of the Computer Science course of the [Master's and Doctorate in Computer Science (MDCC)](http://www.mdcc.ufc.br/) program at the [Federal University of Ceará (UFC)](https://www.ufc.br/).

**Collaborators**: <a id="anchor_colab"></a>

* [Danne Makleyston Gomes Pereira](http://lattes.cnpq.br/2002489019346835), UFC.
* [Angelo Roncalli Alencar Brayner](http://lattes.cnpq.br/3895469714548887), UFC.

## Software Specifications <a id="anchor_especifications"></a>
### Version <a id="anchor_version"></a>
Current version: `v0.1`.

### Requirements <a id="anchor_requirements"></a>

* Docker engine
* Docker compose

### How to use <a id="anchor_usage"></a>

#### Clone the UFCity repository <a id="anchor_clone"></a>
```
git clone https://github.com/makleyston-ufc/ufcity-fog-docker.git
cd ufcity-fog-docker
```

#### Running the installation script locally <a id="anchor_init_locally"></a>

```
sudo chmod +x ./ufcity-fog.sh
sudo ./ufcity-fog.sh
```

* When prompted, provide the fog computing (local IP) and cloud computing IP addresses.

#### Running the installation script on the Virtual Machine (VM) via Vagrant <a id="anchor_init_vagrant"></a>

In the `Vagrantfile`, change the following line with the settings for your execution environment.

```
config.vm.network "[network_type]", bridge: "[interface]"
```
For example: `public_network` and `wlp3s0` respectively.

Running the `Vagrantfile`:
```
vagrant up
```

#### Initializing the Docker containers <a id="anchor_initializing_docker_containers"></a> 
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

#### Outline structure used between Docker containers <a id="anchor_outline_structure"></a> 
##### Edge computing

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


##### Fog computing
 
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
