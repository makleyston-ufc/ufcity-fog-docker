#!/bin/bash

# Author Danne M. G. Pereira
# Date: January 25, 2024

# Define the current installed version
version="1.0"
local_ip=""
cloud_ip=""

if [[ -f .env ]]; then
  source .env
fi

validate_ip() {
    local ip="$1"
    local valid_ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ $ip =~ $valid_ip_pattern ]]; then
        return 0 # Endereço IP válido
    else
        return 1 # Endereço IP inválido
    fi
}

function line_print() {
    local p_static="$1"
    local total_length=39
    local variable="$2"
    local static_length=${#p_static}+5

    spaces_to_fill=$((total_length - static_length - ${#variable}))
    printf "|${p_static} (${variable})%*s|\n" $spaces_to_fill
}

function print() {
    printf "
 _    _  ______   _____  _  _          
| |  | ||  ____| / ____|(_)| |         
| |  | || |__   | |      _ | |_  _   _ 
| |  | ||  __|  | |     | || __|| | | |
| |__| || |     | |____ | || |_ | |_| |
 \____/ |_|      \_____||_| \__| \__, |
                                 __/ |
                                |___/ \n"
    printf "Ｆｏｇ  ｃｏｍｐｕｔｉｎｇ\n"
    printf "+-------------------------------------+\n"
    printf "|Deployed containers:                 |\n"
    printf "+-------------------------------------+\n"
    line_print "Fog Handler" ${UFCITY_HANDLER_VERSION}
    line_print "Fog Semantic" ${UFCITY_SEMANTIC_VERSION}
    line_print "Fog CEP" ${UFCITY_CEP_VERSION}
    line_print "MongoDB" ${MONGO_VERSION}
    line_print "Mongo Express" ${MONGO_EXPRESS_VERSION}
    line_print "Mosquito" ${MOSQUITTO_VERSION}
    line_print "Fluend" ${FLUENTD_VERSION}
    line_print "Fuseki" "stain/jena-fuseki"
    line_print "Elasticsearch" ${ELASTICSEARCH_VERSION}
    line_print "Kibana" ${KIBANA_VERSION}
    printf "+-------------------------------------+\n"
    printf "\n"
    printf "+-------------------------------------+\n"
    printf "|Installed tools:                     |\n"
    printf "+-------------------------------------+\n"
    printf "|Docker                               |\n"
    printf "|Docker compose                       |\n"
    printf "+-------------------------------------+\n"
    printf "\n"
    printf "+-------------------------------------+\n"
    printf "|Configs:                             |\n"
    printf "+-------------------------------------+\n"
    line_print "Local IP:" $local_ip
    line_print "Cloud computing IP:" $cloud_ip
    printf "+-------------------------------------+"
    printf "\n\n"
    printf "Finish.\n"
}

function perform_installation() {

  # Update repositories
  sudo apt update

  # Install Docker
  sudo apt install docker

  # Install Docker Compose
  sudo apt install docker-compose

  # Creating folders
   mkdir -p ./volume/fog-webpage
   mkdir -p ./volume/fluentd/conf
   mkdir -p ./volume/ufcity-semantic
   mkdir -p ./volume/ufcity-semantic/ontology
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

# Ontology
wget -O ./volume/ufcity-semantic/ontology/iot-stream.rdf http://iot.ee.surrey.ac.uk/iot-crawler/ontology/iot-stream/ontology.xml

# Deploy handler, cep, and semantic software
sudo wget -v -O ./volume/ufcity-cep/ufcity-fog-cep-${UFCITY_CEP_VERSION}.jar https://github.com/makleyston-ufc/ufcity-fog-cep/raw/master/build/libs/ufcity-fog-cep-${UFCITY_CEP_VERSION}.jar
echo "fog-computing:
  - address: $local_ip
  - port: 1883
cloud-computing:
  - address: $cloud_ip
  - port: 1883
database:
  - address: mongo
  - port: 27017
  - username: ${MONGO_USERNAME}
  - password: ${MONGO_PASSWORD}" | sudo tee -a  ./volume/ufcity-cep/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-handler/ufcity-fog-handler-${UFCITY_HANDLER_VERSION}.jar https://github.com/makleyston-ufc/ufcity-fog-handler/raw/master/build/libs/ufcity-fog-handler-${UFCITY_HANDLER_VERSION}.jar
echo "fog-computing:
 - address: $local_ip
 - port: 1883
cloud-computing:
 - address: $cloud_ip
 - port: 1883
database:
 - address: $local_ip
 - port: 27017
 - username: ${MONGO_USERNAME}
 - password: ${MONGO_PASSWORD}
data-grouping:
 # - method: HAPPENS_FIRST_GROUPING
 # - method: AT_LEAST_TIME_GROUPING
 # - method: AT_LEAST_TIME_AND_SIZE_GROUPING
 # - method: FIXED_SIZE_GROUPING
 - method: ${DATA_GROUPING_METHOD}
 - size: ${DATA_GROUPING_SIZE}
missing-data:
 # - method: MEDIAN_MISSING_DATA_METHOD
 # - method: LOCF_MISSING_DATA_METHOD
 # - method: INTERPOLATION_MISSING_DATA_METHOD
 # - method: NOCB_MISSING_DATA_METHOD
 # - method: MODE_MISSING_DATA_METHOD
 # - method: MEAN_MISSING_DATA_METHOD
 - method: ${MISSING_DATA_METHOD}
removing-outliers:
 # - method: IQR_REMOVE_OUTLIERS_METHOD
 # - method: PERCENTILE_REMOVE_OUTLIERS_METHOD
 # - method: TUKEY_REMOVE_OUTLIERS_METHOD
 # - method: Z_SCORE_REMOVE_OUTLIERS_METHOD
 - method: ${REMOVING_OUTLIERS_METHOD}
 - threshold: ${REMOVING_OUTLIERS_THRESHOLD}
aggregating-data:
 # - method: MEDIAN_AGGREGATION_METHOD
 # - method: MAX_AGGREGATION_METHOD
 # - method: MIN_AGGREGATION_METHOD
 # - method: MEAN_AGGREGATION_METHOD
 - method: ${AGGREGATION_DATA_METHOD}" | sudo tee -a  ./volume/ufcity-handler/config.yaml > /dev/null

sudo wget -v -O ./volume/ufcity-semantic/ufcity-fog-semantic-${UFCITY_SEMANTIC_VERSION}.jar https://github.com/makleyston-ufc/ufcity-fog-semantic/raw/master/build/libs/ufcity-fog-semantic-${UFCITY_SEMANTIC_VERSION}.jar
echo "fog-computing:
 - address: $local_ip
 - port: 1883
semantic:
 - address: $local_ip
 - port: 3030
 - username: ${FUSEKI_ADMIN_USERNAME}
 - password: ${FUSEKI_ADMIN_PASSWORD}" | sudo tee -a  ./volume/ufcity-semantic/config.yaml > /dev/null

echo "<!DOCTYPE html>
<html lang='en'>
<head> 
    <meta charset='UTF-8'> 
    <meta name='viewport' content='width=device-width, initial-scale=1.0'> 
    <title>UFCity - Fog Computing</title>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css'>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            margin: 20px;
            background-color: #f8f8f8;
            color: #333;
        }

        ul {
            list-style-type: none;
            padding: 0;
        }

        li {
            margin-bottom: 10px;
        }

        a {
            color: #0077cc;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .service-icon {
            margin-right: 10px;
        }

        p {
            margin-top: 20px;
        }

        footer {
            margin-top: 30px;
            font-size: 0.8em;
            color: #555;
        }

    </style>
</head>
<body>
    <h1>Welcome to UFCity - Fog Computing</h1>
    <p>Available services:</p>
    <ul> 
        <li><i class='fas fa-database service-icon'></i><a href='http://$local_ip:8081'>MongoDB</a></li> 
        <li><i class='fas fa-server service-icon'></i><a href='http://$local_ip:3030'>Fuseki server</a></li> 
        <li><i class='fas fa-chart-line service-icon'></i><a href='http://$local_ip:5601'>Kibana</a></li> 
        <li><i class='fas fa-search service-icon'></i><a href='http://$local_ip:9200'>Elasticsearch (status check only)</a></li> 
        <!-- <li><i class='fas fa-code service-icon'></i><a href='http://$local_ip:81'>FluentD (status check only)</a></li>  -->
    </ul>
    <p>
        View UFCity project on <a href='https://github.com/makleyston-ufc'><i class='fab fa-github'></i> GitHub</a>
        <br>
        UFCity webpage: <a href='https://makleyston-ufc.github.io/ufcity/'><i class='fas fa-globe'></i> https://makleyston-ufc.github.io/ufcity/</a>
    </p>
    <footer>
        Developed and maintained by <a href='http://lattes.cnpq.br/2002489019346835'>Danne M. G. Pereira</a>.
        <br> 
        Inst. <a href='https://www.ufc.br/'>UFC</a> and <a href='http://www.mdcc.ufc.br/'>MDCC</a>
    </footer>
</body>
</html>
" | sudo tee -a  ./volume/fog-webpage/index.html > /dev/null

# Creating Dockerfiles
## Fluentd
sudo echo "
# fluentd/Dockerfile

FROM fluent/fluentd:${FLUENTD_VERSION}
USER root
RUN gem install fluent-plugin-elasticsearch --no-document --version ${FLUENT_PLUGIN_ELASTICSEARCH}
USER fluent
" | sudo tee -a  ./dockerfiles/fluentd/Dockerfile > /dev/null

  # Update the version
  mkdir -p ./.version
  echo "{\"version\":\"$version\"}" | tee -a ./.version/data.json > /dev/null

  # Allowing
  sudo touch ./volume/mqtt/mosquitto/log/mosquitto.log
  sudo chmod 777 ./volume/ -R
  sudo chmod 777 ./dockerfiles/ -R

 # Running docker-compose
  read -p "Do you want to execute 'docker-compose up -d'? (Y/N) " choice
 
  if [[ $choice == "y" || $choice == "Y" ]]; then
    sudo docker-compose up -d
  else
    echo "Command execution skipped."
  fi

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
    if [[ $confirmation_local == "y" || $confirmation_local == "Y" ]]; then
        echo "Local IP is OK!"
        break
    elif [[ $confirmation_local == "n" || $confirmation_local == "N" ]]; then
        read -p "Insert the local IP address correctly (e.g., xxx.xxx.xxx.xxx): " local_ip
    else
        echo "Invalid option. Please enter Y for yes or N for no."
    fi
  done

  while true; do
    confirm_cloud_ip
    if [[ $confirmation_cloud == "y" || $confirmation_cloud == "Y" ]]; then
        echo "Cloud computing IP is OK!"
        break
    elif [[ $confirmation_cloud == "N" || $confirmation_cloud == "n" ]]; then
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