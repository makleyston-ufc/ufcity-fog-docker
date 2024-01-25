#!/bin/bash

# Author Danne M. G. Pereira
# Date: January 25, 2024

# Define the current installed version
version="1.0"
local_ip=""
cloud_ip=""

# Função para validar um endereço IP
validate_ip() {
    local ip="$1"
    local valid_ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ $ip =~ $valid_ip_pattern ]]; then
        return 0 # Endereço IP válido
    else
        return 1 # Endereço IP inválido
    fi
}

function print() {
    local_ip_size=${#local_ip}
    cloud_ip_size=${#cloud_ip}
    local_ip_spaces=$((15 - local_ip_size))
    cloud_ip_spaces=$((15 - cloud_ip_size))

    echo "
 _    _  ______  _____  _  _          
| |  | ||  ____|/ ____|(_)| |         
| |  | || |__  | |      _ | |_  _   _ 
| |  | ||  __| | |     | || __|| | | |
| |__| || |    | |____ | || |_ | |_| |
 \____/ |_|     \_____||_| \__| \__, |
                                 __/ |
                                |___/ "
    echo "Ｆｏｇ  ｃｏｍｐｕｔｉｎｇ"
    echo "+-------------------------------------+"
    echo "|Installed components:                |"
    echo "+-------------------------------------+"
    echo "|Fog Handler (data processing)        |"
    echo "|Fog Semantic (semantic annotation)   |"
    echo "|Fog CEP (complex events processing)  |"
    echo "|MongoDB (storage)                    |"
    echo "|Mongo Express (storage view)         |"
    echo "|Mosquito (gateway MQTT)              |"
    echo "|Fluend (logs)                        |"
    echo "|Fuseki (semantic server)             |"
    echo "|Elasticsearch (data analysis)        |"
    echo "|Kibana (data analysis view)          |"
    echo "+-------------------------------------+"
    echo ""
    echo "+-------------------------------------+"
    echo "|Installed tools:                     |"
    echo "+-------------------------------------+"
    echo "|Docker                               |"
    echo "|Docker components                    |"
    echo "+-------------------------------------+"
    echo ""
    echo "+-------------------------------------+"
    echo "|Configs:                             |"
    echo "+-------------------------------------+"
    echo "|Local IP: $local_ip$(printf "%${local_ip_spaces}s")            |"
    echo "|Cloud computing IP: $cloud_ip$(printf "%${cloud_ip_spaces}s")  |"
    echo "+-------------------------------------+"
    echo ""
    echo "Finish."
}


function perform_installation() {

  # Update repositories
  sudo apt update

  # Install Docker
  sudo apt install docker

  # Install Docker Compose
  sudo apt install docker-compose

  # Creating folders
   mkdir -p ./volume/home
   mkdir -p ./volume/fluentd/conf
   mkdir -p ./volume/ufcity-semantic
   mkdir -p ./volume/ufcity-handler
   mkdir -p ./volume/ufcity-cep
   mkdir -p ./volume/fuseki-server/data
   mkdir -p ./volume/mqtt/mosquitto/config
   mkdir -p ./volume/mqtt/mosquitto/data
   mkdir -p ./volume/mqtt/mosquitto/log
   mkdir -p ./dockerfiles/fluentd

# Creating files
## MQTT
sudo tee ./volume/mqtt/mosquitto/config/mosquitto.conf > /dev/null <<EOF
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

## Authentication ##
allow_anonymous true
listener 1883 0.0.0.0
user mosquitto
EOF

## Fluentd
sudo tee ./volume/fluentd/conf/fluent.conf > /dev/null <<EOF
# fluentd/conf/fluent.conf

<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.**>
  @type copy

  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>

  <store>
    @type stdout
  </store>
</match>
EOF

wget -O iot-stream.rdf http://iot.ee.surrey.ac.uk/iot-crawler/ontology/iot-stream/ontology.xml

# Deploy handler, cep, and semantic software
sudo wget -v -O ./volume/ufcity-cep/ufcity-fog-cep-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-cep/raw/master/build/libs/ufcity-fog-cep-1.0-SNAPSHOT.jar
echo "fog-computing:
  - address: $local_ip
  - port: 1883
cloud-computing:
  - address: $cloud_ip
  - port: 1883
database:
  - address: mongo
  - port: 27017
  - username: root
  - password: example" | sudo tee -a  ./volume/ufcity-cep/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-handler/ufcity-fog-handler-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-handler/raw/master/build/libs/ufcity-fog-handler-1.0-SNAPSHOT.jar
echo "fog-computing:
 - address: $local_ip
 - port: 1883
cloud-computing:
 - address: $cloud_ip
 - port: 1883
database:
 - address: $local_ip
 - port: 27017
 - username: root
 - password: example
data-grouping:
 - method: FIXED_SIZE_GROUPING
 - size: 2 
missing-data:
 - method: MEAN_MISSING_DATA_METHOD
removing-outliers:
 - method: Z_SCORE_REMOVE_OUTLIERS_METHOD
 - threshold: 3.0
aggregating-data:
 - method: MEAN_AGGREGATION_METHOD" | sudo tee -a  ./volume/ufcity-handler/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-semantic/ufcity-fog-semantic-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-semantic/raw/master/build/libs/ufcity-fog-semantic-1.0-SNAPSHOT.jar
echo "fog-computing:
 - address: $local_ip
 - port: 1883
semantic:
 - address: $local_ip
 - port: 3030
 - username: admin
 - password: admin" | sudo tee -a  ./volume/ufcity-semantic/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-semantic/ufcity-fog-semantic-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-semantic/raw/master/build/libs/ufcity-fog-semantic-1.0-SNAPSHOT.jar
echo "<!DOCTYPE html><html lang='en'><head> <meta charset='UTF-8'> <meta name='viewport' content='width=device-width, initial-scale=1.0'> <title>UFCity - Fog Computing</title></head><body> Available services: <ul> <li> <a href='http://$local_ip:8081'>MongoDB</a> </li> <li> <a href='http://$local_ip:3030'>Fuseki server</a> </li> <li> <a href='http://$local_ip:5601'>Kibana</a> </li> <li> <a href='http://$local_ip:9200'>Elasticsearch (this link only verify status)</a> </li> <li> <a href='http://$local_ip:81'>FluentD (this link only verify status)</a> </li> </ul> UFCity Project: <a href='https://github.com/makleyston-ufc'>GitHub</a><br> Developed and maintained by <a href='http://lattes.cnpq.br/2002489019346835'>Danne M. G. Pereira</a>.<br> Inst. <a href='https://www.ufc.br/'>UFC</a> and <a href='http://www.mdcc.ufc.br/'>MDCC</a></body></html>" | sudo tee -a  ./volume/home/index.html > /dev/null

# Creating Dockerfiles
## Fluentd
sudo echo '
# fluentd/Dockerfile

FROM fluent/fluentd:v1.12.0-debian-1.0
USER root
RUN ["gem", "install", "elasticsearch", "--no-document", "--version", "< 8"]
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.2.2"]
USER fluent
' | sudo tee -a  ./dockerfiles/fluentd/Dockerfile > /dev/null

  # Update the version
  mkdir -p ./.version
  echo "{\"version\":\"$version\"}" | tee -a ./.version/data.json > /dev/null

  # Allowing
  sudo touch ./volume/mqtt/mosquitto/log/mosquitto.log
  sudo chmod 777 ./volume/ -R
  sudo chmod 777 ./dockerfiles/ -R

 # Running docker-compose
  # read -p "Do you want to execute 'docker compose up -d'? (y/n) " choice

  # if [[ $choice == "y" || $choice == "Y" ]]; then
  #   docker compose up -d
  # else
  #   echo "Command execution skipped."
  # fi

  print
}

# Função para obter o IP local
get_ip() {
    local_ip=$(hostname -I | awk '{print $1}')
    cloud_ip=""
}

# Função para exibir o IP e solicitar confirmação
confirm_local_ip() {
    echo "Local IP address: $local_ip"
    read -p "Is the local IP address correct? (Y/N) " confirmation_local
}

# Função para exibir o IP e solicitar confirmação
confirm_cloud_ip() {
    if [ -n "$cloud_ip" ]; then
      echo "Cloud computing IP address: $cloud_ip"
      read -p "Is the cloud computing IP address correct? (Y/N) " confirmation_cloud
    else
      confirmation_cloud="N"
    fi
}

function config_IP_address() {

  get_ip

  while true; do
    confirm_local_ip
    if [ "$confirmation_local" == "Y" ]; then
        echo "Local IP is OK!"
        break
    elif [ "$confirmation_local" == "N" ]; then
        read -p "Insert the local IP address correctly (e.g., xxx.xxx.xxx.xxx): " local_ip
    else
        echo "Invalid option. Please enter Y for yes or N for no."
    fi
  done

  while true; do
    confirm_cloud_ip
    if [ "$confirmation_cloud" == "Y" ]; then
        echo "Cloud computing IP is OK!"
        break
    elif [ "$confirmation_cloud" == "N" ]; then
        read -p "Insert the cloud computing IP address correctly (e.g., xxx.xxx.xxx.xxx): " cloud_ip
    else
        echo "Invalid option. Please enter Y for yes or N for no."
    fi
  done

  perform_installation

}

# Check if the .version directory exists
if [ -f "./.version/data.json" ]; then
    # Extract the version number from data.json
    version_number=$(cat ./.version/data.json | jq -r '.version')

    # Compare the desired version with the current version
    if [[ $version == $version_number ]]; then
        echo "The current version $version_number is equal to or newer than the version you're trying to execute, $version. No action required."
    else
        echo "The version $version is newer than the current version $version_number. Starting the installation..."
        config_IP_address
        echo "Installation completed. Run 'docker-compose up -d' to initialize the containers."
    fi
else
    echo "The .version/data.json file does not exist. Starting the installation..."
    config_IP_address
    echo "Installation completed. Run 'docker-compose up -d' to initialize the containers."
    echo "Visit http://$local_ip to access the installed services."
fi