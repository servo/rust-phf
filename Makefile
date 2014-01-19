RUSTC = rustc
BUILDDIR = build
RUSTFLAGS = -O -Z extra-debug-info

PHF_LIB = phf.rs
PHF = $(BUILDDIR)/$(shell $(RUSTC) --crate-file-name $(PHF_LIB))
PHF_MAC_LIB = phf_mac.rs
PHF_MAC = $(BUILDDIR)/$(shell $(RUSTC) --crate-file-name $(PHF_MAC_LIB))
PHF_TEST_MAIN = test.rs
PHF_TEST = $(BUILDDIR)/$(shell $(RUSTC) --crate-file-name $(PHF_TEST_MAIN))

all: $(PHF) $(PHF_MAC)

-include $(BUILDDIR)/phf.d
-include $(BUILDDIR)/phf_mac.d
-include $(BUILDDIR)/phf_test.d

$(BUILDDIR):
	mkdir -p $@

$(PHF): $(PHF_LIB) | $(BUILDDIR)
	$(RUSTC) $(RUSTFLAGS) --dep-info $(BUILDDIR)/phf.d --out-dir $(@D) $<

$(PHF_MAC): $(PHF_MAC_LIB) $(PHF) | $(BUILDDIR)
	$(RUSTC) $(RUSTFLAGS) --dep-info $(BUILDDIR)/phf_mac.d --out-dir $(@D) \
		-L $(BUILDDIR) $<

$(PHF_TEST): $(PHF_TEST_MAIN) $(PHF) $(PHF_MAC) | $(BUILDDIR)
	$(RUSTC) --test $(RUSTFLAGS) -L $(BUILDDIR) \
		--dep-info $(BUILDDIR)/phf_test.d --out-dir $(@D) $<

check: $(PHF_TEST)
	$(PHF_TEST)

doc: $(PHF)
	rustdoc $(PHF_LIB)
	rustdoc $(PHF_MAC_LIB)

clean:
	rm -rf $(BUILDDIR)

print-targets:
	@echo $(PHF_MAC) $(PHF)

.PHONY: all clean check