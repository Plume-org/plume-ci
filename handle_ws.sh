#!/bin/bash
id=$(basename "$REQUEST_URI")
[[ ! $id =~ ^[0-9]+$ ]] && echo bad query && exit 1
[[ ! -f logs/$id ]] && echo no logs available && exit 1
tail -fn+1 logs/$id
