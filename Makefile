.PHONY: help build test lint fmt hub relay gui proto dev down clean

help:
	@echo "LanConnector — make targets"
	@echo "  build   cargo build --release --workspace"
	@echo "  test    cargo test + go test"
	@echo "  lint    clippy + go vet + buf lint"
	@echo "  dev     docker compose up -d (hub + relay)"
	@echo "  gui     cd gui && npm run tauri dev"
	@echo "  down    docker compose down"

build:
	cargo build --release --workspace

test:
	cargo test --workspace
	cd hub && go test ./...
	cd relay && go test ./...

lint:
	cargo fmt --all -- --check
	cargo clippy --workspace --all-targets -- -D warnings
	cd hub && go vet ./...
	cd relay && go vet ./...
	cd proto && buf lint

fmt:
	cargo fmt --all
	cd hub && gofmt -w .
	cd relay && gofmt -w .

hub:
	cd hub && go run ./cmd/lanhub

relay:
	cd relay && go run ./cmd/lanrelay

gui:
	cd gui && npm run tauri dev

proto:
	cd proto && buf generate

dev:
	docker compose up -d --build

down:
	docker compose down

clean:
	cargo clean
	rm -rf gui/node_modules gui/dist console/node_modules
