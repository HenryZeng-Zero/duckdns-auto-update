#!/bin/sh

TRUE=1
FALSE=0
RETURN_DATA=''

function help() {
    echo "configure.sh [options]"
    echo "   -h, --help                           Show this help message"
    echo "   -i, --init                           Init config file"
    echo "   -d, --depend                         Install dependencies with apt"
    echo "   -l, --list                           List all tags in config file"
    echo "   -m, --more [tag]                     List more info about specific tag"
    echo
    echo "   -a, --add [tag] [domains] [token]    Add config file"
    echo "-> eg) -a duck-test duck-test.duckdns.org 5a6b4e33-2e82-431b-9684-1c76d03f3af1"
    echo
    echo "   -c, --clean                          Remove config file"
}


function init_config_file() {
cat > config << EOF
# [Help]
#
# {Target}:
#     enable: {true|false}
#     domains: {domains}
#     token: {token}
#
# Target: The tag name of the target.
# domains: The domain can be a single domain - or a comma separated list of domains.
# token: your duckdns account token
EOF
}

function config_get_tag(){
    tag=$(echo $1 | grep -o -P '.*?:.*?#*.*')
    echo $tag
}

function config_tags_list(){
    IFS=''
    separate_count=1

    while IFS= read -r line
    do
        config_get_tag $line

        separate_count=$(( $separate_count + 1 ))
    done < config
}

function config_add() {
cat >> config << EOF
$1:
    enable: true
    domains: $2
    token: $3
EOF
}


case $1 in
    -i|--init)
        init_config_file
    ;;
    -l|--list)
        config_tags_list
    ;;
    -d|--depend)
        apt install -y yq
    ;;
    -c|--clean)
        rm config
    ;;
    -h|--help)
        help
    ;;
    *)
        echo "[Invalid option]"
        help
    ;;
esac