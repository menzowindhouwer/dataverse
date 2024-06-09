#!/bin/bash

_PWD=`pwd`

cd /Users/menzowi/Documents/Projects/dataverse-aio/conf/docker-aio

#export JAVA_HOME=`/usr/libexec/java_home`
./1prep.sh && \
docker build -t dv0 -f c8.dockerfile . && \
docker run -d -p 8083:8080 -p 8084:80 -v /Users/menzowi/Documents/Projects/dataverse-aio/conf/docker-aio/cmd/dv_cmdi_conf.xml:/opt/dv/cmdi_config.xml -e DV_CMDI_CONF=/opt/dv/cmdi_config.xml --name dv dv0
while true; do
	docker logs dv
    echo "WAIT FOR: Command start-domain executed successfully."
    read -p "Proceed? [y(es)? or N(o)? or wait]" yn
    case $yn in
        [Yy]* ) break;;
        [N]* ) exit;;
        * ) echo "...";;
    esac
done

docker exec dv /opt/dv/setupIT.bash && \
docker exec dv /usr/local/glassfish4/bin/asadmin create-jvm-options "-Ddataverse.siteUrl=http\://localhost\:8084" && \
curl -X PUT -d FAKE http://localhost:8084/api/admin/settings/:DoiProvider

echo "READY!" && \
tput bel

cd $_PWD

# upload new TSV
#  curl http://localhost:8084/api/admin/datasetfield/load -H "Content-type: text/tab-separated-values" -X POST --upload-file OralHistoryInterviewDANS.tsv
# enable it in the General Information of the Dataverse