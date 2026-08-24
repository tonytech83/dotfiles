.PHONY: all bashism shellcheck typos

ROOT_DIR = .
LOG_DIR = logging
OUTPUT_PATH = $(ROOT_DIR)/$(LOG_DIR)
OUTPUT_OUT = $(OUTPUT_PATH)/$(PHASE).out
OUTPUT_ERR = $(OUTPUT_PATH)/$(PHASE).err
OUTPUT = 1>$(OUTPUT_OUT) 2>$(OUTPUT_ERR)

SHELL_SCRIPTS := $(shell find $(ROOT_DIR) -type f -name '*.sh' \
	-not -path '*/.git/*' \
	-not -path '*/.config/*')

all: bashism shellchek typos ## Do all checks

help:     ## Show this help.
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'\

$(OUTPUT_PATH):
	@mkdir -p $(OUTPUT_PATH)

bashism: PHASE = bashism ## Check for bashism
bashism: $(OUTPUT_PATH)
	@echo "***Checking for bashism..."
	@fail=0; \
	for file in $(SHELL_SCRIPTS); do \
		out=$$(checkbashisms "$$file" 2>&1); \
		status=$$?; \
		if [[ $$status -ne 0 && $$status -ne 4 ]]; then \
			echo "$$out" >> $(OUTPUT_ERR); \
			fail=1; \
		else \
			echo "$$out" >> $(OUTPUT_OUT); \
		fi; \
	done; \
	if [ $$fail -ne 0 ]; then \
		echo "bashism check failed, see $(OUTPUT_ERR)"; \
	fi

shellchek: PHASE = shellchek ## Check for shell issues
shellchek: $(OUTPUT_PATH)
	@echo "***Checking for shell issues..."
	@shellcheck $(SHELL_SCRIPTS) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "shellcheck failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi

typos: PHASE = typos ## Chek for typos
typos: $(OUTPUT_PATH)
	@echo "***Checking for typos..."
	@typos $(ROOT_DIR) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "typos check failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi
