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

all: bashism shellchek typos

$(OUTPUT_PATH):
	@mkdir -p $(OUTPUT_PATH)

bashism: PHASE = bashism
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

shellchek: PHASE = shellchek
shellchek: $(OUTPUT_PATH)
	@echo "***Checking for shell issues..."
	@shellcheck $(SHELL_SCRIPTS) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "shellcheck failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi

typos: PHASE = typos
typos: $(OUTPUT_PATH)
	@echo "***Checking for typos..."
	@typos $(ROOT_DIR) $(OUTPUT); \
	status=$$?; \
	if [ $$status -ne 0 ]; then \
		echo "typos check failed, see $(OUTPUT_ERR)"; \
		exit $$status; \
	fi