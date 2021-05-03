CLOUD := jody
GROUP := k1-us-east-2-eksctl-io
TENANT := 806775361903163392

dummy:
	$(RM) -rf build
	$(MAKE) build

build:
	rm -rf build
	mkdir -p build/nashville
	mkdir -p build/memphis
	mkdir -p build/knoxville
	cat src/config.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > build/config.yaml
	cat src/nashville/config.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > build/nashville/config.yaml
	cat src/memphis/config.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > build/memphis/config.yaml
	cat src/knoxville/config.yaml | sed 's/{{.Values.org.cloudAccount}}/$(CLOUD)/g' \
		| sed 's/{{.Values.org.group}}/$(GROUP)/g' | sed 's/{{.Values.org.tenant}}/$(TENANT)/g' > build/knoxville/config.yaml

clean:
	$(RM) -rf build
