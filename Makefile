

all: render deploy ## renders and deploys all templates into the current k8s cluster

render: edge-worker-render main-worker-render app-network-render ## renders all templates
deploy: edge-worker-deploy main-worker-deploy app-network-deploy ## deploys all templates

test: ## test example, e.g. `make test dev/manifests/applications/some-app.yaml`
	@vela dry-run -f $(filter-out $@,$(MAKECMDGOALS))

edge-worker-render: ## renders the edge-worker crd
	@vela def vet ./cue/components/edge-worker.cue
	vela def render ./cue/components/edge-worker.cue -o manifests/vela-caps/components/edge-worker.yaml

edge-worker-deploy: ## deploys the edge-worker crd into the current k8s cluster
	@vela def apply ./cue/components/edge-worker.cue

main-worker-render: ## renders the main-worker crd
	@vela def vet ./cue/components/main-worker.cue
	vela def render ./cue/components/main-worker.cue -o manifests/vela-caps/components/main-worker.yaml

main-worker-deploy: ## deploys the main-worker crd into the current k8s cluster
	@vela def apply ./cue/components/main-worker.cue

app-network-render: ## renders the app-network crd
	@vela def vet ./cue/components/application-network.cue
	vela def render  cue/components/application-network.cue -o manifests/vela-caps/components/application-network.yaml 

app-network-deploy: ## deploys the app-network crd into the current k8s cluster
	@vela def apply ./cue/components/application-network.cue

install-vela: ## install kubevela
	@VELA_VERSION=v1.2.2
	@curl -fsSl https://kubevela.io/script/install.sh | bash -s ${VELA_VERSION}

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make [target]\033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m\t %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	
.PHONY: all test deploy edge-worker-render main-worker-render app-network-render edge-worker-deploy main-worker-deploy app-network-deploy install-vela help