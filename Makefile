NAMESPACE?=edgefarm-applications
all: render deploy helm ## renders and deploys all templates into the current k8s cluster
render: traits-render components-render ## renders all templates
apply: traits-apply components-apply ## applies all templates
deploy: traits-deploy components-deploy ## deploys all templates

test: ## test example, e.g. `make test examples/pure.yaml`
	@vela dry-run -f $(filter-out $@,$(MAKECMDGOALS))

traits-render: ## renders all traits
	@vela def vet cue/traits/edgefarm-network-trait.cue
	@vela def render cue/traits/edgefarm-network-trait.cue -o manifests/vela-caps/traits/edgefarm-network-trait.yaml
	@vela def vet cue/traits/edgefarm-storage-trait.cue
	@vela def render cue/traits/edgefarm-storage-trait.cue -o manifests/vela-caps/traits/edgefarm-storage-trait.yaml

traits-apply: ## applies all traits using vela cli
	@vela def apply cue/traits/edgefarm-network-trait.cue
	@vela def apply cue/traits/edgefarm-storage-trait.cue

traits-deploy: ## deploys all traits using kubectl
	kubectl apply -n $(NAMESPACE) -f manifests/vela-caps/traits/edgefarm-network-trait.yaml
	kubectl apply -n $(NAMESPACE) -f manifests/vela-caps/traits/edgefarm-storage-trait.yaml

components-render: ## renders all components
	@vela def vet cue/components/edgefarm-applications.cue
	@vela def render cue/components/edgefarm-applications.cue -o manifests/vela-caps/components/edgefarm-applications.yaml
components-apply: ## applies all components using vela cli
	@vela def apply cue/components/edgefarm-applications.cue
components-deploy: ## deploys all components using kubectl
	kubectl apply -n $(NAMESPACE) -f manifests/vela-caps/components/edgefarm-applications.yaml

helm: ## generate helm chart. Version is incremented using semantic-release and github actions
	$(eval TEMPD := $(shell mktemp -d))
	$(eval ROOTPWD := $(shell pwd))
	@cd $(TEMPD)
	@helmify -f $(ROOTPWD)/manifests/vela-caps/components/edgefarm-applications.yaml -f $(ROOTPWD)/manifests/vela-caps/traits/edgefarm-storage-trait.yaml -f $(ROOTPWD)/manifests/vela-caps/traits/edgefarm-network-trait.yaml $(TEMPD)/edgefarm-applications
	@sed -i 's/name: {{ include "edgefarm-applications.fullname" . }}-applications/name: edgefarm-applications/g' $(TEMPD)/edgefarm-applications/templates/edgefarm-applications.yaml
	@sed -i 's/name: {{ include "edgefarm-applications.fullname" . }}-network/name: edgefarm-network/g' $(TEMPD)/edgefarm-applications/templates/edgefarm-network-trait.yaml
	@sed -i 's/name: {{ include "edgefarm-applications.fullname" . }}-storage/name: edgefarm-storage/g' $(TEMPD)/edgefarm-applications/templates/edgefarm-storage-trait.yaml
	@cp -r $(TEMPD)/edgefarm-applications/templates/* $(ROOTPWD)/charts/edgefarm-applications/templates
	@rm -r $(TEMPD)
	@cd $(ROOTPWD)
	@helm dependency update charts/edgefarm-applications

install-vela: ## install kubevela
	# Make sure to also modify the version of vela-core in charts/edgefarm-applications/Chart.yaml
	@curl -fsSl https://kubevela.io/script/install.sh | bash -s v1.8.0
	@vela install

install-helmify: ## install helmify
	$(eval TEMPD := $(shell mktemp -d))
	@curl -L https://github.com/arttor/helmify/releases/download/v0.4.5/helmify_Linux_x86_64.tar.gz -o $(TEMPD)/helmify.tar.gz && \
		tar -xzf $(TEMPD)/helmify.tar.gz -C /$(TEMPD) && \
		mv $(TEMPD)/helmify /usr/local/bin/helmify && \
		chmod +x /usr/local/bin/helmify
	@rm -r $(TEMPD)

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make [target]\033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m\t %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all render apply deploy traits-render traits-apply traits-deploy components-render components-apply components-deploy install-vela help test
