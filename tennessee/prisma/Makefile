CLOUD := jody
GROUP := k1-us-east-2-eksctl-io
TENANT := 806775361903163392
KUBEDNS := 10.100.0.10

build:
	cat src/secops-rule.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > secops-rule.yaml
	cat src/kubedns-rule.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > kubedns-rule.yaml
	cat src/kubedns-net.yaml | sed 's/{{.Values.kubeDns}}/$(KUBEDNS)/g' > kubedns-net.yaml
	cat src/nashville-rule.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > nashville-rule.yaml
	cat src/memphis-rule.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > memphis-rule.yaml
	cat src/knoxville-rule.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > knoxville-rule.yaml
	echo "#!/bin/sh -xe" > create-ns.sh
	echo "#!/bin/sh -xe" > create-policy.sh
	chmod +x create-ns.sh create-policy.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"nashville\"}'" >> create-ns.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"memphis\"}'" >> create-ns.sh
	echo "apoctl api create namespace --namespace /$(TENANT)/$(CLOUD)/$(GROUP) --data '{\"name\": \"knoxville\"}'" >> create-ns.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP) import --file kubedns-net.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP) import --file kubedns-rule.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP) import --file secops-rule.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/nashville import --file nashville-rule.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/memphis import --file memphis-rule.yaml" >> create-policy.sh
	echo "apoctl api -n /$(TENANT)/$(CLOUD)/$(GROUP)/knoxville import --file knoxville-rule.yaml" >> create-policy.sh

clean:
	$(RM) create-ns.sh create-policy.sh secops-rule.yaml kubedns-rule.yaml kubedns-net.yaml
	$(RM) nashville-rule.yaml memphis-rule.yaml knoxville-rule.yaml 
