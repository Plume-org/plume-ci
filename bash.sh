#!/bin/bash
set -x

caddy &
caddy_pid=$!

inotifywait -m ./ -e create -e moved_to |
    while read path action file; do
    	if [[ ! $file =~ ^[0-9]*\.tar\.gz$ ]]; then
    		continue
    	fi;

        id=$(basename -s .tar.gz $file)
        if [ -d ../plume_deploy/$id ]; then
        	rm -rf ../plume_deploy/$id
        fi;
        mkdir ../plume_deploy/$id
        tar -C ../plume_deploy/$id -xvzf $file
        env_temp=$(pwd)/.env.template

        pushd ../plume_deploy/$id

        secret=$(openssl rand -base64 32)
        domain=pr-$id.joinplu.me
        found=0
        port=8000
        while [ $found -ne 1 ]; do
        	if [ $(netstat -tlnu | grep :$port | wc -l) == "0" ]; then
        		found=1
        	else
        		port=$((port + 1))
        	fi;
        done;
		sed -e "s;%BASE_URL%;$domain;g" -e "s;%SECRET%;$secret;g" $env_temp | tee .env

        # Kill old instance, if there are more than 5 running
        if [ $(sudo docker ps | grep plume-pr | wc -l) -ge 5 ]; then
            to_kill=$(sudo docker ps | grep plume-pr | tail -n 1 | awk 'NF>1{print $NF}')
            docker stop $to_kill
        fi;

        cont=plume-pr-$id
        docker run -td --name $cont --rm -p 127.0.0.1:$port:7878 --mount type=bind,src=$(pwd),dst=/app plumeorg/plume-buildenv:v0.0.5
        docker exec -w /app $cont ls -al
        docker exec -w /app $cont /app/bin/diesel migration run
        docker exec -w /app $cont /app/bin/plm instance new -n "PR #$id"
        docker exec -w /app $cont /app/bin/plm users new -a -n admin -p admin123 -N "Admin #$id" -e "admin@$domain"
        docker exec -w /app $cont /app/bin/plm search init
        docker exec -w /app -d $cont /app/bin/plume

        popd

        sed -e "s;%BASE_URL%;$domain;g" -e "s;%PORT%;$port;g" Caddyfile.template | tee Caddyfile.$id
        cat Caddyfile.$id Caddyfile | tee Caddyfile
        kill $caddy_pid
        caddy &
        caddy_pid=$!
    done

