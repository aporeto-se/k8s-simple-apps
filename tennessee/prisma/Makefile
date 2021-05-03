CLOUD := jody
GROUP := k1-us-east-2-eksctl-io
TENANT := 806775361903163392

build:
	cat src/cluster.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > cluster.yaml
	cat src/nashville.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > nashville.yaml
	cat src/memphis.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > memphis.yaml
	cat src/knoxville.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > knoxville.yaml
	echo "#!/bin/sh -xe" > deploy.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"nashville\"}'" >> deploy.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"memphis\"}'" >> deploy.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"knoxville\"}'" >> deploy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP) import --file config.yaml" >> deploy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/nashville import --file nashville.yaml" >> deploy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/memphis import --file memphis.yaml" >> deploy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/knoxville import --file knoxville.yaml" >> deploy.sh
	chmod +x deploy.sh

clean:
	$(RM) -rf cluster.yaml nashville.yaml memphis.yaml knoxville.yaml deploys.sh
