#!/bin/bash

AUTH="solr:SolrRocks"

docker-compose down
docker-compose up -d

sleep 10

docker exec -it --user=root solr-old chown -R solr:solr /opt/solr/
docker exec -it --user=root solr-new chown -R solr:solr /opt/solr/

docker exec -it solr-old cp -R /opt/solr/server/solr/configsets/_default /opt/solr/server/solr/configsets/mockdata
docker exec -it solr-new cp -R /opt/solr/server/solr/configsets/_default /opt/solr/server/solr/configsets/mockdata

docker cp managed-schema.xml solr-old:/opt/solr/server/solr/configsets/mockdata/conf/managed-schema
docker cp managed-schema.xml solr-new:/opt/solr/server/solr/configsets/mockdata/conf/managed-schema

docker restart solr-old
docker restart solr-new

sleep 20

docker exec -it solr-old bin/solr create -c mockdata -d /opt/solr/server/solr/configsets/mockdata/
docker exec -it solr-new bin/solr create -c mockdata -d /opt/solr/server/solr/configsets/mockdata/

docker cp mock_data.csv solr-old:/opt/solr/mock_data.csv
docker cp mock_data.csv solr-new:/opt/solr/mock_data.csv

docker exec -it solr-old bin/post -u $AUTH -c mockdata /opt/solr/mock_data.csv -p 8984
docker exec -it solr-new bin/post -u $AUTH -c mockdata /opt/solr/mock_data.csv -p 8985

echo "Solr 8.11.0 (OLD):"
curl "http://localhost:8984/solr/mockdata/query" -d "q=*&omitHeader=true&rows=0&wt=json&json.facet={\"Gender\":{field:gender_s,limit:10,sort:\"count desc\",type:terms,facet:{\"age\":\"avg(age_i)\"}}}"
echo "Solr 8.11.1 (NEW):"
curl "http://localhost:8985/solr/mockdata/query" -d "q=*&omitHeader=true&rows=0&wt=json&json.facet={\"Gender\":{field:gender_s,limit:10,sort:\"count desc\",type:terms,facet:{\"age\":\"avg(age_i)\"}}}"