
BINDIR=bin
CLANG_FLAGS=-Wall -gmodules

.PHONY: build clean test build-protc build-tests run-tests generate-tests

build: build-protc build-tests

create-output-dir:
	mkdir -p $(BINDIR)

build-protc: create-output-dir
	clang $(CLANG_FLAGS) protc/protc.c -o $(BINDIR)/protc

build-tests: create-output-dir
	clang $(CLANG_FLAGS) $(BINDIR)/generated/tests.c -o $(BINDIR)/protc_tests

run-tests:
	$(BINDIR)/protc_tests

generate-tests:
	mkdir -p $(BINDIR)/generated 
	python ./scripts/generate-tests.py -p ../../ --test-dir tests -o $(BINDIR)/generated/tests.c -i protc/libs.h -i protc/lexer.c -i tests/testlib.h

test: generate-tests build-tests run-tests

clean:
	rm $(BINDIR)/*

