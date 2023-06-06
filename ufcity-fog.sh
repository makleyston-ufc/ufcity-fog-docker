#!/bin/bash

# Define the current installed version
version="1.0"

function perform_installation() {
  # Update repositories
  # sudo apt update

  # Install Docker
  # sudo apt install docker

  # Install Docker Compose
  # sudo apt install docker-compose

  # Creating folders
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

# Deploy handler, cep, and semantic software
sudo wget -v -O ./volume/ufcity-cep/ufcity-fog-cep-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-cep/raw/master/build/libs/ufcity-fog-cep-1.0-SNAPSHOT.jar
echo 'fog-computing:
 - address: mqtt
   port: 1883
cloud-computing:
 - address: 200.137.134.98
   port: 1889
database:
 - address: mongo
   port: 27017' | sudo tee -a  ./volume/ufcity-cep/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-handler/ufcity-fog-handler-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-handler/raw/master/build/libs/ufcity-fog-handler-1.0-SNAPSHOT.jar
echo 'fog-computing:
 - address: mqtt
   port: 1883
cloud-computing:
 - address: 200.137.134.98
   port: 1889
database:
 - address: mongo
   port: 27017
data-grouping:
 - method: FIXED_SIZE_GROUPING
   size: 5
missing-data:
 - method: MEAN_MISSING_DATA_METHOD
removing-outliers:
 - method: Z_SCORE_REMOVE_OUTLIERS_METHOD
   threshold: 3
aggregating-data:
 - method: MEAN_AGGREGATION_METHOD' | sudo tee -a  ./volume/ufcity-handler/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-semantic/ufcity-fog-semantic-1.0-SNAPSHOT.jar https://github.com/makleyston-ufc/ufcity-fog-semantic/raw/master/build/libs/ufcity-fog-semantic-1.0-SNAPSHOT.jar
echo 'fog-computing:
  - address: 172.100.100.2
    port: 1883
semantic:
 - address: 172.100.100.5
   port: 3030
   username: admin
   password: admin' | sudo tee -a  ./volume/ufcity-semantic/config.yaml > /dev/null

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
  # sudo chmod o+w ./volume/mqtt/mosquitto/log/mosquitto.log
  # sudo chown 1883:1883 ./volume/mqtt/mosquitto/ -R
  sudo chmod 777 ./volume/ -R
  sudo chmod 777 ./dockerfiles/ -R

 # Running docker-compose
  read -p "Do you want to execute 'docker compose up -d'? (y/n) " choice

  if [[ $choice == "y" || $choice == "Y" ]]; then
    docker compose up -d
  else
    echo "Command execution skipped."
  fi
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
        perform_installation
        echo "Installation completed. Run 'docker-compose up -d' to initialize the containers."
    fi
else
    echo "The .version/data.json file does not exist. Starting the installation..."
    perform_installation
    echo "Installation completed. Run 'docker-compose up -d' to initialize the containers."
fi

