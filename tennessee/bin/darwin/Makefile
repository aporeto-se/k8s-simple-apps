KUBE_VER := $(shell curl -L -s https://dl.k8s.io/release/stable.txt)

build:
	mkdir -p x86_64
	cd x86_64 && curl -L -o yq "https://github.com/mikefarah/yq/releases/download/v4.8.0/yq_darwin_amd64"
	cd x86_64 && curl -L -o real-apoctl "https://download.aporeto.com/prismacloud/app2/apoctl/darwin/apoctl"
	cd x86_64 && curl -L -o jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
	cd x86_64 && chmod +x yq real-apoctl jq

