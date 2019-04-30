#!/bin/bash
set -x

currently_running=$(docker container ls | grep -Eo 'plume-pr-[0-9]+' | cut -c10- | tr '\n' ',')
cat Caddyfile.base *.caddy > Caddyfile
[ -z "$currently_running" ] &&\
	echo '[]' > static/up.json ||\
	echo '['"${currently_running::-1}"']' > static/up.json

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
	    log_dir=$(pwd)/logs

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
        docker container stop $cont || true
        docker run -td --name $cont --rm -p 127.0.0.1:$port:7878 --mount type=bind,src=$(pwd),dst=/app plumeorg/plume-buildenv:v0.0.5
        docker exec -w /app $cont ls -al > $log_dir/$id
        docker exec -t -w /app $cont /app/bin/plm migration run >> $log_dir/$id
        docker exec -t -w /app $cont /app/bin/plm instance new -n "PR #$id" >> $log_dir/$id
        docker exec -t -w /app $cont /app/bin/plm users new -a -n admin -p admin123 -N "Admin #$id" -e "admin@$domain" >> $log_dir/$id
        docker exec -t -w /app $cont /app/bin/plm search init >> $log_dir/$id
        docker exec -t -e ROCKET_ENV=dev -w /app $cont /app/bin/plume >> $log_dir/$id &

        popd

        #get comma separated list of running containers
        currently_running=$(docker container ls | grep -Eo 'plume-pr-[0-9]+' | cut -c10- | tr '\n' ',' | sort -r)

        #remove trailing ',' and convert to json
        echo '['"${currently_running::-1}"']' > static/up.json

        sed -e "s;%BASE_URL%;$domain;g" -e "s;%PORT%;$port;g" Caddyfile.template > $id.caddy
        cat Caddyfile.base *.caddy > Caddyfile
        kill $caddy_pid
        caddy &
        caddy_pid=$!
    done

