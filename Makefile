HW1_SUBDIR := $(wildcard ./hw1/*/.)
HW2_SUBDIR := $(wildcard ./hw2/*/.)
HW3_SUBDIR := $(wildcard ./hw3/*/.)
HW4_SUBDIR := $(wildcard ./hw4/*/.)

SUBDIRS := $(HW1_SUBDIR) $(HW@_SUBDIR) $(HW3_SUBDIR) $(HW4_SUBDIR)

.PHONY: default clean_all

default:
	$(info Run "make clean_all" to clean ALL subdirectories in $(SUBDIRS) )
	$(info Run "make tar" to compress this directory)
	$(info Run "make format" to format *.sv *.svh *.v verilog code)

tar:
	FILE_NAME=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$FILE_NAME.tar $$FILE_NAME

format:
	find . -type f -name "*.sv" -or -name "*.svh" -or -name "*.v" | xargs -I '{}' verible-verilog-format --inplace '{}' --column_limit 80

clean_all:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	find -type d -name "syn" -or -name "pr" | xargs rm -rf
