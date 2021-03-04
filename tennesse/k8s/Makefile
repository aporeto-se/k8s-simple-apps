build:
	cat _memphis.yaml > memphis.yaml
	echo "---" >> memphis.yaml
	kubectl create configmap -n memphis run --dry-run=client -o yaml --from-file=memphis.sh >> memphis.yaml
	cat _nashville.yaml > nashville.yaml
	echo "---" >> nashville.yaml
	kubectl create configmap -n nashville run --dry-run=client -o yaml --from-file=nashville.sh >> nashville.yaml
