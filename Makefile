
BINDIR=bin
SRCDIR=src

protc:
	mkdir -p $(BINDIR)
	xcrun -sdk macosx swiftc $(SRCDIR)/*.swift -o $(BINDIR)/protc

.PHONY: clean
clean:
	rm $(BINDIR)/*

