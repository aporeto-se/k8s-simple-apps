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
	echo "#!/bin/sh -xe" > create-ns.sh
	echo "#!/bin/sh -xe" > create-policy.sh
	chmod +x create-ns.sh create-policy.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"nashville\"}'" >> create-ns.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"memphis\"}'" >> create-ns.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"knoxville\"}'" >> create-ns.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP) import --file config.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/nashville import --file nashville.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/memphis import --file memphis.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/knoxville import --file knoxville.yaml" >> create-policy.sh

clean:
	$(RM) -rf cluster.yaml nashville.yaml memphis.yaml knoxville.yaml create-ns.sh create-policy.sh
