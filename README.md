# UFCity Fog Computing - Docker

### Requirements
* Docker engine
* Docker compose

### How to use:

Clone the UFCity repo:
```
git clone https://github.com/makleyston-ufc/ufcity-fog-docker.git
cd ufcity-fog-docker
```

Configuring the environment:
```
sudo ./ufcity-fog.sh
```

Initializing the *containers*: 
```
sudo docker-compose up -d
```

This release (version 1.0) contains the following *services*:
* fuseki
* ufcity-handler
* ufcity-cep
* ufcity-semantic
* mqtt
* elasticsearch
* fluentd
* kibana
* mongo database

Go to `http://<host_ip>:80` to access the services present on the node.

### Outline structure used between *containers*:
```
## MQTT Topics ##
Edge Module:
	Publish:
		- resource_data/[uuid_device]/[uuid_resource]			-> resource_json
		- removed_resource/[uuid_device]/[uuid_resource] 		-> uuid_resource
		- registered_resource/[uuid_device]/[uuid_resource] 	-> resource_json
		- device/[uuid_device] 									-> device_json
	Subscribe:
		- commands_fog_to_edge/[uuid_device]/[uuid_resource]	-> resource_json
			- Ex.: commands_fog_to_edge/[uuid_device]/+			-> resource_json
		- resend/[uuid_device]									-> uuid_device
			- Ex.: resend/[uuid_device]							-> uuid_device
		- resend/[uuid_device]/[uuid_resource]					-> uuid_resxource
			- Ex.: resend/[uuid_device]/+						-> uuid_resource
Fog Computing:
	Edge MQTT Broker:
		Publish:
			- commands_fog_to_edge/uuid_device/uuid_resource	-> resource_json 
			- resend/device										-> uuid_device
			- resend/device/resource							-> uuid_resource
		Subscribe:
			- resource_data/[uuid_device]/[uuid_resource]	-> resource_json
				- Ex.: resource_data/+/+					-> resource_json
			- removed_resource/[uuid_device] 				-> uuid_resource
				- Ex.: removed_resource/+					-> uuid_resource
			- registered_resource/[uuid_device] 			-> resource_json
				- Ex.: registered_resource/+ 				-> resource_json
			- device/[uuid_device]	 						-> device_json
				- Ex.: device/+		 						-> device_json
	Fog computing MQTT Broker:
		Publish:
			- cep/uuid_device/uuid_resource		-> resource_json (CEP consume this data)
			- combined_services/uuid_device/uuid_resource	-> resource_json
		Subscribe:
			- resource_data/[uuid_device]			-> resource_json (Ex.: combined service)
				- Ex.: resource_data/uuid_fog_node 	-> virtual_resource_json
Cloud Computing:
	Fog Computing:
		Publish:
			- resource_data/uuid_fog/uuid_device/uuid_resource	-> resource_json
```