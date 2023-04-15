# UFCity Fog Computing Docker

### Comandos para utilização:

Baixar o repositório:
```
git clone git@github.com:makleyston-ufc/ufcity_fog_computing_docker.git
cd ufcity_fog_computing_docker
```

Inicializar os *containers*: 
```
docker-compose up -d
```

Esta versão (version 0.1) contém os seguintes *containers*:
* fuseki
* ufcity-handler
* edge-com
* inner-com
* mongo
* mongo-express


### Estrutura de tópicos utilizada entre os *containers*:
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