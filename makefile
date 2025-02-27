# 通过执行shell脚本，从workspace工程配置文件Cargo.toml中，获取version的信息
VERSION:=$(shell grep "version =" Cargo.toml | awk -F'"' '{print $2}' | head -n 1 | sed 's/version = //g')

##@ Build 执行编译脚本
.PHONY: build
build: ## 编译本地版本
	sh scripts/build-release.sh local $(VERSION)

.PHONY: build-mac-release
build-mac-release: ## 编译MacOS版本
	sh scripts/build-release.sh mac $(VERSION)

.PHONY: build-linux-release
build-linux-release: ## 编译Linux版本
	sh scripts/build-release.sh linux $(VERSION)

.PHONY: build-win-release
build-win-release: ## 编译Windows版本
	sh scripts/build-release.sh win $(VERSION)


##@ Test 执行测试脚本
.PHONY: unit-test
unit-test:  ## 运行单元测试脚本
	sh ./scripts/run-unittest.sh dev

.PHONY: unit-test-ci
unit-test-ci:
	sh ./scripts/run-unittest.sh ci

.PHONY: integration-test
integration-test:  ## 运行集成测试脚本
	sh ./scripts/run-integrationtest.sh dev

.PHONY: integration-test-ci
integration-test-ci:
	sh ./scripts/run-integrationtest.sh ci


##@ Other 执行其他脚本
.PHONY: clean
clean:  ## 清理项目.
	cargo clean
	rm -rf build

.PHONY: help
help: ## 显示帮助信息.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage 使用说明:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
