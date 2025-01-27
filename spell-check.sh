#!/bin/bash

# Function to check if Aspell is installed
check_aspell() {
    if command -v aspell > /dev/null; then
        return 1
    else
        echo "Aspell is not installed. Automatically installing"
        return 0
    fi
}

# Function to install Aspell on Debian-based systems
install_aspell_debian() {
    echo "Attempting to install Aspell on Debian-based system..."
    sudo apt-get update && sudo apt-get install -y aspell
}

# Function to install Aspell on macOS
install_aspell_mac() {
    echo "Attempting to install Aspell on macOS..."
    brew install aspell
}

# Main logic
if check_aspell; then
    # Identify the platform
    case "$(uname -s)" in
        Linux)
            if [ -f /etc/debian_version ]; then
                install_aspell_debian
            else
                echo "Unsupported Linux distribution."
            fi
            ;;
        Darwin)
            install_aspell_mac
            ;;
        *)
            echo "Unsupported operating system."
            ;;
    esac
fi


read -r -d '' dictionary <<'EOF'
personal_ws-1.1 en 2
anteraja
argocd
artajasa
bersama
bigquery
brankas
brankass
cardmember
checkly
checkov
ci
cloudkms
confluentinc
coreapi
deadletter
deadletters
decrypter
ekyc
encrypter
finexus
freshchat
goka
golang
hnst
honestbank
honestcard
jq
json
kafdrop
menubook
mst
nonk8s
noti
opentracing
perf
perso
pushgateway
rclone
resc
roleset
rolesets
rtrw
rudderstack
schemaregistry
snyk
strimzi
terratest
ulid
usecase
waitlist
waitlisted
yaml
EOF

echo "$dictionary" > dictionary.text

# Your string to check
string=$(cat "$1")

echo "$string"

# Check spelling
misspelled=$(echo "$string" | aspell --personal ./dictionary.text list)

rm dictionary.text

# If the misspelled variable is not empty, there are spelling errors
if [ -n "$misspelled" ]; then
  echo "Spelling errors found:"
  echo "$misspelled"
  exit 1
else
  exit 0
fi
