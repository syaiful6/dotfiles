extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.tar.xz)    tar xvJf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *.xz)        unxz $1        ;;
            *.exe)       cabextract $1  ;;
            *)           echo "\`$1': unrecognized file compression" ;;
        esac
    else
        echo "\`$1' is not a valid file"
    fi
}

# Read text from stdin, and echo a version of the same text, just better suited
# for a filename.
sanitise-filename() {
    echo -n "$1" | tr -c -s 'a-zA-Z0-9.-' '-'
}

trim-file-prefix() {
    echo -n "$1" | cut -c18-
}

trim-files-prefix() {
    local exitcode=0
    local sanitised
    for file in $*; do
        sanitised=$(trim-file-prefix "$file")

        [ "$sanitised" = "$file" ] && continue

        if [ -f "$sanitised" ]; then
            echo >&2 "$0: can't rename $file, $sanitised already exists"
            exitcode=1
        else
            mv -- "$file" "$sanitised"
        fi
    done
}

# Wrapper around sanitise-filename which takes a list of files and renames them
# for you. Example use:
#
#   sanitise-rename-files *
#   sanitise-rename-files *.doc
#
sanitise-rename-files() {
    local exitcode=0
    local sanitised

    for file in $*; do
        sanitised=$(sanitise-filename "$file")

        [ "$sanitised" = "$file" ] && continue

        if [ -f "$sanitised" ]; then
            echo >&2 "$0: can't rename $file, $sanitised already exists"
            exitcode=1
        else
            mv -- "$file" "$sanitised"
        fi
    done

    return $exitcode
}

dotfile-has() {
  type "${1-}" > /dev/null 2>&1
}

# generate random password/key
gen-pswd() {
    if dotfile-has "pwgen"; then
        # we have pwgen use it
        command pwgen -ysB $1
    else
        # use system random
            </dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c $1  ; echo
    fi
}

# function for adding dirs to $PATH
# silently does nothing if an argument isn't a directory
add-path() {
    local PREPEND="false"

    # basic arg parsing
    if [ "$1" = "--prepend" ]; then
        PREPEND="true"
        shift
    fi

    for ARG in $*; do
        if [ -d $ARG ]; then
            if [ "$PREPEND" = "true" ]; then
                export PATH="$ARG:$PATH"
            else
                export PATH="$PATH:$ARG"
            fi
        fi
    done
}

se_download_html() {
    command curl http://95.217.135.107/media/serp_html/${1}.html -L --output ${1}.html
}

lambda-rust-deploy-all-regions() {
    declare -a regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "eu-north-1" "sa-east-1" "eu-south-1")
    for i in "${regions[@]}"
    do
        echo "deploy to $i"
        aws lambda create-function --function-name ${1} --runtime provided.al2 --handler hello --role 'arn:aws:iam::749323766402:role/awslambdaproxy-role' --zip-file ${2} --region ${i} --timeout 120 >> /dev/null 2>&1
    done
}

lambda-rust-deploy-arm64-all-regions() {
    declare -a regions=("us-east-1" "us-east-2" "us-west-2" "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "eu-central-1" "eu-west-1" "eu-west-2")
    for i in "${regions[@]}"
    do
        echo "deploy to $i"
        aws lambda create-function --function-name ${1} --runtime provided.al2 --handler hello --architectures arm64 --role 'arn:aws:iam::749323766402:role/awslambdaproxy-role' --zip-file ${2} --region ${i} --timeout 120 >> /dev/null 2>&1
    done
}

gcloud-go-deploy-tier1() {
    declare -a regions=("us-west1" "us-central1" "us-east1" "us-east4" "europe-west1" "europe-west2" "asia-east1" "asia-east2" "asia-northeast1" "asia-northeast2")
    for i in "${regions[@]}"
    do
        echo "deploy to $i"
        gcloud functions deploy ${1} --entry-point=KanakFnHTTP --runtime go116 --trigger-http --allow-unauthenticated --region ${i} >> /dev/null 2>&1
    done
}

gcloud-go-deploy-tier2() {
    declare -a regions=("us-west2" "us-west3" "us-west4" "northamerica-northeast1" "southamerica-east1" "europe-west3" "europe-west6" "europe-central2" "australia-southeast1" "asia-south1" "asia-southeast1" "asia-southeast2" "asia-northeast3")
    for i in "${regions[@]}"
    do
        echo "deploy to $i"
        gcloud functions deploy ${1} --entry-point=KanakFnHTTP --runtime go116 --trigger-http --allow-unauthenticated --region ${i} >> /dev/null 2>&1
    done
}
