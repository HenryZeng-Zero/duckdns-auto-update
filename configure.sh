#!/bin/sh




function help() {
    echo "configure.sh [options]"
    echo "   -h, --help                           Show this help message"
    echo "   -i, --init                           Init config file"
    echo
    echo "   -a, --add                            Add config file"
    echo "-> -a [tag] [domains] [token]"
    echo "-> eg) -i duck-test duck-test.duckdns.org 5a6b4e33-2e82-431b-9684-1c76d03f3af1"
    echo
    echo "   -c, --clean                          Remove config file"
}


function init_config_file() {
cat > config << EOF
# Help
# domains: The domain can be a single domain - or a comma separated list of domains.
# token: your duckdns account token
EOF
}

function add_config_file() {
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