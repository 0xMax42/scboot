# Standard Makefile
# Supports DESTDIR installs and explicit file renames.

.PHONY: all build test clean install uninstall help

BUILD_DIR := build
PREFIX ?= /usr
DESTDIR ?=
SBINDIR := $(PREFIX)/sbin
LIBEXECDIR := $(PREFIX)/libexec
SYSCONFDIR ?= /etc
SYSTEMDDIR := $(PREFIX)/lib/systemd/system
DKMS_CONFDIR := /etc/dkms/framework.conf.d

# Targets (final install paths)
APT_CONFDIR := $(SYSCONFDIR)/apt/apt.conf.d
SCBOOT_CONFDIR := $(SYSCONFDIR)/scboot
SCBOOT_LIBDIR := $(PREFIX)/lib/scboot

# Inputs (source files)
SRC_VERSION_FILE := VERSION
SRC_GRUB_HOOK   := $(BUILD_DIR)/hooks/apt-secureboot-grub-resign.apt-hook
SRC_KERNEL_HOOK := $(BUILD_DIR)/hooks/apt-secureboot-kernel-resign.apt-hook
SRC_SCBOOT_CONF := config/scboot.conf
SRC_SCBOOT_DKMS_CONF := config/dkms-framework.conf.d/scboot.conf
SRC_SCBOOT_LIB  := $(BUILD_DIR)/scripts/lib.sh
SRC_SCBOOT_BIN  := $(BUILD_DIR)/scripts/scboot.sh
SRC_SCBOOT_SYNC_DKMS := $(BUILD_DIR)/scripts/sync-dkms.sh
SRC_SCBOOT_SIGN_GRUB := $(BUILD_DIR)/scripts/resign-grub.sh
SRC_SCBOOT_SIGN_KERNEL := $(BUILD_DIR)/scripts/resign-kernel.sh
SRC_SYSTEMD_SERVICE := $(BUILD_DIR)/systemd/scboot-reload.service
SRC_SYSTEMD_PATH := $(BUILD_DIR)/systemd/scboot-reload.path

# Outputs (installed file names)
DST_GRUB_HOOK   := $(APT_CONFDIR)/99-apt-secureboot-grub-resign
DST_KERNEL_HOOK := $(APT_CONFDIR)/99-apt-secureboot-kernel-resign
DST_SCBOOT_CONF := $(SCBOOT_CONFDIR)/scboot.conf
DST_SCBOOT_DKMS_CONF := $(DKMS_CONFDIR)/99-scboot.conf
DST_VERSION_FILE := $(SCBOOT_LIBDIR)/VERSION
DST_SCBOOT_LIB  := $(SCBOOT_LIBDIR)/lib.sh
DST_SCBOOT_BIN  := $(SCBOOT_LIBDIR)/scboot.sh
DST_SCBOOT_SYNC_DKMS := $(SCBOOT_LIBDIR)/sync-dkms.sh
DST_SCBOOT_SIGN_GRUB := $(SCBOOT_LIBDIR)/resign-grub.sh
DST_SCBOOT_SIGN_KERNEL := $(SCBOOT_LIBDIR)/resign-kernel.sh
DST_SYSTEMD_SERVICE := $(SYSTEMDDIR)/scboot-reload.service
DST_SYSTEMD_PATH := $(SYSTEMDDIR)/scboot-reload.path

# Symlinks
SYM_SCBOOT_SIGN_GRUB := $(LIBEXECDIR)/resign-grub
SYM_SCBOOT_SIGN_KERNEL := $(LIBEXECDIR)/resign-kernel
SYM_SCBOOT_BIN := $(LIBEXECDIR)/scboot
REL_LIB_FROM_SBIN_GRUB := $(patsubst $(LIBEXECDIR)/%,%,$(SCBOOT_LIBDIR))/resign-grub.sh
REL_LIB_FROM_SBIN_KERNEL := $(patsubst $(LIBEXECDIR)/%,%,$(SCBOOT_LIBDIR))/resign-kernel.sh
REL_LIB_FROM_SBIN_BIN := $(patsubst $(LIBEXECDIR)/%,%,$(SCBOOT_LIBDIR))/scboot.sh

# Sed variables for templating
SED_VARS = \
	-e 's|@DST_SCBOOT_SIGN_KERNEL@|$(DST_SCBOOT_SIGN_KERNEL)|g' \
	-e 's|@SYM_SCBOOT_SIGN_GRUB@|$(SYM_SCBOOT_SIGN_GRUB)|g' \
	-e 's|@DST_SCBOOT_SYNC_DKMS@|$(DST_SCBOOT_SYNC_DKMS)|g' \
	-e 's|@DST_SCBOOT_DKMS_CONF@|$(DST_SCBOOT_DKMS_CONF)|g' \
	-e 's|@DST_SCBOOT_CONF@|$(DST_SCBOOT_CONF)|g'

all: clean build

help:
	@echo "Available targets:"
	@echo "  install      Install files into DESTDIR"
	@echo "  uninstall    Remove installed files from DESTDIR"
	@echo "  build        No-op"
	@echo "  test         No-op"
	@echo "  clean        No-op"

# ----------------------------
# No-op targets (by design)
# ----------------------------

test:
	@:

# ----------------------------
# Build (templating)
# ----------------------------

build:
	@mkdir -p "$(BUILD_DIR)"

	@for dir in hooks systemd scripts; do \
		mkdir -p "$(BUILD_DIR)/$$dir"; \
		for file in $$dir/*; do \
			sed $(SED_VARS) "$$file" \
				> "$(BUILD_DIR)/$$dir/$$(basename "$$file")"; \
		done; \
	done

clean:
	@rm -rf "$(BUILD_DIR)"
	@echo "Cleaned build directory."

# ----------------------------
# Installation
# ----------------------------

install: build
	# Create target directories
	install -d "$(DESTDIR)$(APT_CONFDIR)"
	install -d "$(DESTDIR)$(SCBOOT_CONFDIR)"
	install -d "$(DESTDIR)$(SCBOOT_LIBDIR)"
	install -d "$(DESTDIR)$(LIBEXECDIR)"
	install -d "$(DESTDIR)$(SYSTEMDDIR)"
	install -d "$(DESTDIR)$(DKMS_CONFDIR)"

	# Install files
	install -m 0644 "$(SRC_GRUB_HOOK)"   "$(DESTDIR)$(DST_GRUB_HOOK)"
	install -m 0644 "$(SRC_KERNEL_HOOK)" "$(DESTDIR)$(DST_KERNEL_HOOK)"
	install -m 0644 "$(SRC_SCBOOT_CONF)" "$(DESTDIR)$(DST_SCBOOT_CONF)"
	install -m 0644 "$(SRC_SCBOOT_DKMS_CONF)" "$(DESTDIR)$(DST_SCBOOT_DKMS_CONF)"
	install -m 0644 "$(SRC_SCBOOT_LIB)"  "$(DESTDIR)$(DST_SCBOOT_LIB)"
	install -m 0755 "$(SRC_SCBOOT_BIN)"  "$(DESTDIR)$(DST_SCBOOT_BIN)"
	install -m 0755 "$(SRC_SCBOOT_SYNC_DKMS)" "$(DESTDIR)$(DST_SCBOOT_SYNC_DKMS)"
	install -m 0755 "$(SRC_SCBOOT_SIGN_GRUB)" "$(DESTDIR)$(DST_SCBOOT_SIGN_GRUB)"
	install -m 0755 "$(SRC_SCBOOT_SIGN_KERNEL)" "$(DESTDIR)$(DST_SCBOOT_SIGN_KERNEL)"
	install -m 0644 "$(SRC_SYSTEMD_SERVICE)" "$(DESTDIR)$(DST_SYSTEMD_SERVICE)"
	install -m 0644 "$(SRC_SYSTEMD_PATH)" "$(DESTDIR)$(DST_SYSTEMD_PATH)"
	install -m 0644 "$(SRC_VERSION_FILE)" "$(DESTDIR)$(DST_VERSION_FILE)"

	# Create symlinks
	ln -sf "$(REL_LIB_FROM_SBIN_GRUB)" \
		"$(DESTDIR)$(SYM_SCBOOT_SIGN_GRUB)"
	ln -sf "$(REL_LIB_FROM_SBIN_KERNEL)" \
		"$(DESTDIR)$(SYM_SCBOOT_SIGN_KERNEL)"
	ln -sf "$(REL_LIB_FROM_SBIN_BIN)" \
		"$(DESTDIR)$(SYM_SCBOOT_BIN)"

uninstall:
	# Remove installed files (ignore if missing)
	rm -f "$(DESTDIR)$(DST_GRUB_HOOK)"
	rm -f "$(DESTDIR)$(DST_KERNEL_HOOK)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_CONF)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_DKMS_CONF)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_LIB)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_BIN)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_SYNC_DKMS)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_SIGN_GRUB)"
	rm -f "$(DESTDIR)$(DST_SCBOOT_SIGN_KERNEL)"
	rm -f "$(DESTDIR)$(DST_SYSTEMD_SERVICE)"
	rm -f "$(DESTDIR)$(DST_SYSTEMD_PATH)"
	rm -f "$(DESTDIR)$(DST_VERSION_FILE)"

	# Remove symlinks
	rm -f "$(DESTDIR)$(SYM_SCBOOT_SIGN_GRUB)"
	rm -f "$(DESTDIR)$(SYM_SCBOOT_SIGN_KERNEL)"
	rm -f "$(DESTDIR)$(SYM_SCBOOT_BIN)"

	# Try to remove directories if they became empty
	-rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(SCBOOT_CONFDIR)" 2>/dev/null || true
	-rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(SCBOOT_LIBDIR)" 2>/dev/null || true
	-rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(DKMS_CONFDIR)" 2>/dev/null || true