#!/bin/bash

firstString="I love Suzi and Marry"
secondString="Sara"
result=$(echo "$firstString" | sed "s/Suzi/$secondString/")
result=$(echo "$firstString" | sed "s/Suzi/$secondString/")
echo $result

ARG_HOME="/c/Users/vnijs"
#result=$(echo "$ARG_HOME" | sed "s/^\/\[A-z]{1}\//C:\//")
#result=$(echo "$ARG_HOME" | sed "s/^\/[A-z]{1}\//C:\//")
# result=$(echo "$ARG_HOME" | sed -E "s|^/[A-z]{1}/|C:/|")
result=$(echo "$ARG_HOME" | sed -E "s|^/([A-z]{1})/|\1:/|")
echo $result

