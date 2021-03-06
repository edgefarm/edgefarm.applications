

all: render deploy ## renders and deploys all templates into the current k8s cluster

render: edge-worker-render cloud-worker-render app-network-render traits-render ## renders all templates
deploy: edge-worker-deploy cloud-worker-deploy app-network-deploy traits-deploy ## deploys all templates

test: ## test example, e.g. `make test dev/manifests/applications/some-app.yaml`
	@vela dry-run -f $(filter-out $@,$(MAKECMDGOALS))

traits-render: 
	@vela def vet ./cue/traits/volume-trait.cue
	@vela def render ./cue/traits/volume-trait.cue -o manifests/vela-caps/traits/volume-trait.yaml

traits-deploy: 
	@vela def apply ./cue/traits/volume-trait.cue

edge-worker-render: ## renders the edge-worker crd
	@vela def vet ./cue/components/edge-worker.cue
	vela def render ./cue/components/edge-worker.cue -o manifests/vela-caps/components/edge-worker.yaml

edge-worker-deploy: ## deploys the edge-worker crd into the current k8s cluster
	@vela def apply ./cue/components/edge-worker.cue

cloud-worker-render: ## renders the cloud-worker crd
	@vela def vet ./cue/components/cloud-worker.cue
	vela def render ./cue/components/cloud-worker.cue -o manifests/vela-caps/components/cloud-worker.yaml

cloud-worker-deploy: ## deploys the cloud-worker crd into the current k8s cluster
	@vela def apply ./cue/components/cloud-worker.cue

app-network-render: ## renders the app-network crd
	@vela def vet ./cue/components/application-network.cue
	@vela def vet ./cue/traits/cloud-network-participant-trait.cue
	@vela def vet ./cue/traits/edge-network-participant-trait.cue
	vela def render  cue/components/application-network.cue -o manifests/vela-caps/components/application-network.yaml 
	vela def render  cue/traits/cloud-network-participant-trait.cue -o manifests/vela-caps/traits/cloud-network-participant-trait.yaml
	vela def render  cue/traits/edge-network-participant-trait.cue -o manifests/vela-caps/traits/edge-network-participant-trait.yaml

app-network-deploy: ## deploys the app-network crd into the current k8s cluster
	@vela def apply ./cue/components/application-network.cue
	@vela def apply ./cue/traits/cloud-network-participant-trait.cue
	@vela def apply ./cue/traits/edge-network-participant-trait.cue

install-vela: ## install kubevela
	@VELA_VERSION=v1.2.4
	@curl -fsSl https://kubevela.io/script/install.sh | bash -s ${VELA_VERSION}
	@vela install

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make [target]\033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m\t %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all test deploy edge-worker-render cloud-worker-render app-network-render edge-worker-deploy cloud-worker-deploy app-network-deploy install-vela help
