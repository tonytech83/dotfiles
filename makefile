.PHONY: all bashism typos shellcheck help

PACKAGE	    = zsh-setup
ROOT_DIR 	= .
LOG_DIR 	= logging

# -------------------------------------------------------
# Output
# -------------------------------------------------------
OUTPUT_DIR		=${ROOT_DIR}/${LOG_DIR}
OUTPUT_OUT	 	=$(OUTPUT_DIR)/$(PHASE).out
OUTPUT_ERR	 	=$(OUTPUT_DIR)/$(PHASE).err
OUTPUT 			= 1>$(OUTPUT_OUT) 2>$(OUTPUT_ERR)

# Ensure output dir exists
$(OUTPUT_DIR): 
	@mkdir -p $@

# target: all - Run bashism, typos and shellcheck checks
all: bashism typos shellcheck


# Display targets by searching this file
help:
	@grep -E "^# target:" [Mm]akefile || true

# target: bashism - Check for bashisms in shell scripts
bashism: PHASE = bashism
bashism: $(OUTPUT_DIR)
	@echo "*** Checking for bashism"
	@sh_files=$$(find ${ROOT_DIR} -type f -name "*.sh"); \
	if [ -n "$$sh_files" ]; then \
		while read -r file; do \
			msg=$$(checkbashisms "$$file" 2>&1); exit_code=$$?; \
			if [[ "$$exit_code" -ne 0 && "$$exit_code" -ne 4 ]]; then \
				echo "$$file: $$msg" >> $(OUTPUT_ERR); \
			else \
				echo "$$file: $$msg" >> $(OUTPUT_OUT); \
			fi; \
		done <<< "$$sh_files"; \
	fi

# target: shellcheck - Check for shellcheck errors
shellcheck: PHASE = shellcheck
shellcheck: $(OUTPUT_DIR)
	@echo "*** Checking for shellcheck errors"
	@# -S warning: only show warnings and errors
	@find ${ROOT_DIR} -type f -name "*.sh" -exec shellcheck -S warning {} + $(OUTPUT) || true

# target: typos - Check for typos
typos: PHASE = typos
typos: $(OUTPUT_DIR)
	@echo "*** Checking for typos"
	@typos ${ROOT_DIR} $(OUTPUT)


