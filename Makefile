CLUSTER  ?= skillpulse
NAMESPACE ?= skillpulse

DOCKER_USER ?= abdullah404

BACKEND_IMAGE  ?= $(DOCKER_USER)/skillpulse-backend:latest
FRONTEND_IMAGE ?= $(DOCKER_USER)/skillpulse-frontend:latest

.PHONY: up down build load apply status logs mysql restart clean

up:
	$(MAKE) build
	kind create cluster --config k8s/kind-config.yaml --name $(CLUSTER)
	$(MAKE) load
	$(MAKE) apply

	@echo ""
	@echo "SkillPulse is live at http://localhost:8888"
	@echo ""

build:
	docker build -t $(BACKEND_IMAGE) ./backend
	docker build -t $(FRONTEND_IMAGE) ./frontend

push:
	docker push $(BACKEND_IMAGE)
	docker push $(FRONTEND_IMAGE)

load:
	kind load docker-image $(BACKEND_IMAGE) --name $(CLUSTER)
	kind load docker-image $(FRONTEND_IMAGE) --name $(CLUSTER)

apply:
	kubectl apply -f k8s/00-namespace.yaml
	kubectl apply -f k8s/10-mysql.yaml
	kubectl apply -f k8s/20-backend.yaml
	kubectl apply -f k8s/30-frontend.yaml

	kubectl rollout status statefulset/mysql -n $(NAMESPACE) --timeout=180s
	kubectl rollout status deployment/backend -n $(NAMESPACE) --timeout=120s
	kubectl rollout status deployment/frontend -n $(NAMESPACE) --timeout=60s

status:
	kubectl get pods,svc,endpoints -n $(NAMESPACE)

logs:
	kubectl logs -n $(NAMESPACE) -l 'app in (mysql,backend,frontend)' \
	--all-containers --tail=50 -f --max-log-requests=10

mysql:
	kubectl exec -it -n $(NAMESPACE) mysql-0 -- \
	mysql -uskillpulse -pskillpulse123 skillpulse

restart:
	$(MAKE) build
	$(MAKE) load

	kubectl rollout restart deployment/backend -n $(NAMESPACE)
	kubectl rollout restart deployment/frontend -n $(NAMESPACE)

	kubectl rollout status deployment/backend -n $(NAMESPACE) --timeout=120s
	kubectl rollout status deployment/frontend -n $(NAMESPACE) --timeout=60s

down:
	kind delete cluster --name $(CLUSTER)

clean:
	docker system prune -f
