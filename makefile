.PHONY: all bashism shellcheck typos

SCRIPT_VERSION=v1.0
SCRIPT_AUTHOR=tonytech

ROOT_DIR = .
LOG_DIR = log
OUTPUT_PATH = $(ROOT_DIR)/$(LOG_DIR)
OUTPUT_OUT = $(OUTPUT_PATH)/$(strip $(PHASE)).out
OUTPUT_ERR = $(OUTPUT_PATH)/$(strip $(PHASE)).err
OUTPUT = 1>$(OUTPUT_OUT) 2>$(OUTPUT_ERR)

SHELL_SCRIPTS := $(shell find $(ROOT_DIR) -type f -name '*.sh' \
	-not -path '*/.git/*' \
	-not -path '*/.config/*')

all: bashism shellchek typos ## Do all checks

help:     ## Show this help.
	@echo -e "\nUsage: make [target] ...\n"
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
	@echo -e "\nWritten by $(SCRIPT_AUTHOR), version $(SCRIPT_VERSION)"
	@echo -e "Please report any bug or error to the author."

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

shellchek: PHASE = shellcheck ## Check for shell issues
shellchek: $(OUTPUT_PATH)
	@echo "***Checking for shell issues..."
	@shellcheck $(SHELL_SCRIPTS) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "shellcheck failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi

typos: PHASE = typos ## Check for typos
typos: $(OUTPUT_PATH)
	@echo "***Checking for typos..."
	@typos $(ROOT_DIR) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "typos check failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi

clean: PHASE = clean ## Clean all logs
clean: $(OUTPUT_PATH)
	@echo "*** Clean all logs from previous executions..."
	@rm -rf $(OUTPUT_PATH)
