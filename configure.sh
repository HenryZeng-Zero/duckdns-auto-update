#!/bin/sh

TRUE=1
FALSE=0

LINE_IS_VALID_ANNOTATION=0
LINE_IS_INVALID_ANNOTATION=1
LINE_IS_TARGET=2
LINE_NOT_TARGET=3

function help() {
    echo "configure.sh [options]"
    echo "   -h, --help                           Show this help message"
    echo "   -i, --init                           Init config file"
    echo "   -l, --list                           List all tags in config file"
    echo
    echo "   -a, --add                            Add config file"
    echo "-> -a [tag] [domains] [token]"
    echo "-> eg) -i duck-test duck-test.duckdns.org 5a6b4e33-2e82-431b-9684-1c76d03f3af1"
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

function annotation_syntax_tip_error_header(){
    # $1 : line data
    # $2 : line count

    echo -e "\e[31m[syntaxError]\e[0m at line \e[100m$2\e[0m"
    echo -e "\e[93m<example>\e[0m annotation:"
    echo "# annotation"
    echo "    # annotation"
    echo -e "\e[93m<mistake line>\e[0m"
    echo -e "\e[44m$1\e[0m"
}

function is_target() {
    sub=$1

    if [[ $sub =~ ":" ]]; then
        sub=${line%:*} # 提取 ':' 左侧内容

        if [[ "$sub" =~ "#" ]]; then
            return $LINE_NOT_TARGET
        fi

        # 如果左侧非空表示Target结构
        if [ -n "$sub" ]; then
            return $LINE_IS_TARGET
        fi
    fi

    return $LINE_NOT_TARGET
}

function annotation_syntax_check(){
    # $1 : line data
    # $2 : line count

    sub=$1

    is_target $sub

    if [ $? -eq $LINE_IS_TARGET ]; then
        return $LINE_IS_TARGET
    fi

    if [[ "$sub" =~ "#" ]]; then
        sub=${line%#*} # 提取 '#' 左侧内容
        sub=$(echo $sub | grep -o -P '[a-zA-Z:]*')

        # 如果 '#' 左侧符合 target: xxx 模式，则依然表示vz
        if [[ $sub =~ ":" ]]; then
            return $LINE_IS_TARGET
        fi
        
        if [ -z "$sub" ]; then
            return $LINE_IS_VALID_ANNOTATION
        else
            annotation_syntax_tip_error_header $1 $2
            echo -e "\e[93m<repair>\e[0m"
            echo -e "\e[96m1. Shoud not add letters in front of symbol '#'.\e[0m"
            echo -e "\e[96m2. Or fogot add ':' before Target name.\e[0m"
            exit 1
        fi
    fi

    

    # it also represents the line is not a annotation
    return $LINE_IS_INVALID_ANNOTATION
}
function config_tags_list(){
    IFS=''
    separate_count=1

    while IFS= read -r line
    do
        annotation_syntax_check $line $separate_count
        echo "OK: $?"
        # if [ $? -eq $FALSE ]; then

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