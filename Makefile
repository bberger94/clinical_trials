# Stata wrapper used to throw any errors
stata = statamp 

%.log: %.do $(CLEAN_DATA)  ## General rule for running Stata do files.
	cd $(dir $<); $(stata) -b do $(notdir $<)

DO_FILES = $(shell find . -name "*.do")
LOG_FILES = $(patsubst %.do, %.log, $(DO_FILES))

figures: $(LOG_FILES)  ## Run all Stata do files

todos:
	find . -type f -size -1M -exec grep -Hn TODO "{}" \; | sed "/Binary file/d" | sed "/.log/d"

reports/graphs.docx: reports/graphs.md figures
	cd reports ; pandoc graphs.md -o graphs.docx
