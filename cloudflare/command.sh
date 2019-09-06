#!/bin/bash

myip(){
    IP_API_1="http://ip-api.com/json"
    IP_API_2="https://ipapi.co/json/"

    IP_API_RESULT_1=$(curl -s -X GET "${IP_API_1}" | jq -r .query)

    if [ -z IP_API_RESULT_1 ]
    then
        # Alternate query native IP address
        IP_API_RESULT_2=$(curl -s -X GET "$IP_API_2" | jq -r .ip)
        echo -n "$IP_API_RESULT_2"
    else
        echo -n "$IP_API_RESULT_1"
    fi
}

checkEnv(){
    if [ -z $CF_API_TOKEN ]
    then
        echo 'Environment variable(CF_API_TOKEN) is required to specify API Token'
        exit 1
    fi

    if [ -z $CF_DOMAIN ]
    then
        echo 'Environment variable(CF_DOMAIN) is required to specify Domain, eg: example.com'
        exit 2
    fi

    if [ -z $CF_DNS_DOMAIN ]
    then
        echo 'Environment variable(CF_DNS_DOMAIN) is required to specify DNS Domain, eg: my-nas.example.com'
        exit 3
    fi

    if [ -z $CHECK_CYCLE ]
    then
        export CHECK_CYCLE=2m
    fi
}

doWork(){
    echo "Check cycle:$CHECK_CYCLE"
    CF_API_BASE="https://api.cloudflare.com/client/v4"
    CF_API_STATUS=$(curl -s -X GET "${CF_API_BASE}/user/tokens/verify" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type:application/json" | jq -r .result.status)

    if [ "$CF_API_STATUS" == 'active' ]
    then
        CF_ZONE_LIST=$(curl -s -X GET "${CF_API_BASE}/zones?name=$CF_DOMAIN&status=active&page=1&per_page=20&order=status&match=all" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type:application/json")
        echo -n "$CF_ZONE_LIST" > zone_list.txt
        CF_ZONE_CHECK_RESULT=$(echo -n "$CF_ZONE_LIST" | jq .success)

        if [ 'true' == "$CF_ZONE_CHECK_RESULT" ]
        then
            CF_DOMAIN_ID=$(echo -n $CF_ZONE_LIST | jq -r .result[0].id)
            echo "Found Zone ID: $CF_DOMAIN_ID for $CF_DOMAIN"
            CF_ZONE_DNS_REQUEST="${CF_API_BASE}/zones/${CF_DOMAIN_ID}/dns_records"
            CF_ZONE_DNS_LIST=$(curl -s -X GET "${CF_ZONE_DNS_REQUEST}" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type:application/json")
            echo "$CF_ZONE_DNS_LIST" > dns_list.txt

            CF_ZONE_DNS_CHECK_RESULT=$(echo -n "$CF_ZONE_DNS_LIST" | jq .success)

            if [ 'true' == "$CF_ZONE_DNS_CHECK_RESULT" ]
            then
                CF_ZONE_DNS_TARGET=$(echo "$CF_ZONE_DNS_LIST" | jq -r -e ".result[] | select(.name == \"$CF_DNS_DOMAIN\")")
                MY_IP=$(myip)
                echo "Current My IP:$MY_IP"
                if [ -z "$CF_ZONE_DNS_TARGET" ]
                then
                    echo "Cannot found dns id by $CF_DNS_DOMAIN, create an new record"
                    CF_ZONE_DNS_CREATE_RESULT=$(curl -s -X POST "${CF_API_BASE}/zones/${CF_DOMAIN_ID}/dns_records" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type:application/json" --data "{\"type\":\"A\",\"name\":\"${CF_DNS_DOMAIN}\",\"content\":\"${MY_IP}\",\"ttl\":120,\"priority\":10,\"proxied\":false}")
                    if [ 'true' == $(echo "$CF_ZONE_DNS_CREATE_RESULT" | jq -r .success) ]
                    then
                        echo 'Create IP succeeded, please wait patiently for DNS to take effect.'
                    else
                        echo 'Failed to create IP record, please check the return value:'
                        echo "$CF_ZONE_DNS_CREATE_RESULT" | jq .
                    fi
                else
                    CF_ZONE_DNS_ID=$(echo "$CF_ZONE_DNS_TARGET" | jq -r -e ".id")
                    CF_ZONE_DNS_CONTENT=$(echo "$CF_ZONE_DNS_TARGET" | jq -r -e ".content")
                    echo "Found DNS ID:$CF_ZONE_DNS_ID for domain $CF_DNS_DOMAIN"

                    if [ "$MY_IP" == "$CF_ZONE_DNS_CONTENT" ]
                    then
                        echo "The IP address has not changed and there is no need to update the record."
                    else
                        echo "Current DNS IP:$CF_ZONE_DNS_CONTENT Current My IP:$MY_IP"
                        CF_ZONE_DNS_UPDATE_RESULT=$(curl -s -X PUT "${CF_API_BASE}/zones/${CF_DOMAIN_ID}/dns_records/$CF_ZONE_DNS_ID" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type:application/json" --data "{\"type\":\"A\",\"name\":\"${CF_DNS_DOMAIN}\",\"content\":\"${MY_IP}\",\"ttl\":120,\"proxied\":false}")
                        echo "$CF_ZONE_DNS_UPDATE_RESULT" > update_result.txt
                        if [ 'true' == $(echo "$CF_ZONE_DNS_UPDATE_RESULT" | jq -r .success) ]
                        then
                            echo 'Update IP succeeded, please wait patiently for DNS to take effect.'
                        else
                            echo 'Failed to update IP, please check the return value:'
                            echo "$CF_ZONE_DNS_UPDATE_RESULT" | jq .
                        fi
                    fi
                fi
            else
                echo 'Query DNS Record Fails'
            fi
        else
            echo 'Not a valid domain'
        fi
    else
        echo 'Not a valid API token'
    fi
}

while :
do
    checkEnv
    doWork
    `sleep $CHECK_CYCLE`
done
