
BINDIR=bin
CLANG_FLAGS=-Wall -gmodules

.PHONY: build clean test build-protc build-tests run-tests

build: build-protc build-tests

create-output-dir:
	mkdir -p $(BINDIR)

build-protc: create-output-dir
	clang $(CLANG_FLAGS) protc/protc.c -o $(BINDIR)/protc

build-tests: create-output-dir
	clang $(CLANG_FLAGS) tests/tests.c -o $(BINDIR)/protc_tests

run-tests:
	$(BINDIR)/protc_tests

test: build-tests run-tests

clean:
	rm $(BINDIR)/*

