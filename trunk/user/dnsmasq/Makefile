SRC_NAME=dnsmasq-2.80
SRC_URL=http://www.thekelleys.org.uk/dnsmasq/$(SRC_NAME).tar.gz

THISDIR=$(shell pwd)

COPTS := -DHAVE_BROKEN_RTC -DNO_INOTIFY -DNO_AUTH -DNO_LOOP -DNO_DUMPFILE
ifndef CONFIG_IPV6
COPTS += -DNO_IPV6
endif
ifndef CONFIG_USB_SUPPORT
COPTS += -DNO_TFTP
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
COPTS += -DNO_IPSET
endif

all: download_test extract_test
	$(MAKE) -C $(SRC_NAME) COPTS="$(COPTS)"

download_test: 
	( if [ ! -f $(THISDIR)/$(SRC_NAME).tar.gz ]; then \
		wget -t5 --timeout=20 -O $(SRC_NAME).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(THISDIR)/$(SRC_NAME) ]; then \
		tar xzvf $(SRC_NAME).tar.gz; \
	fi )

clean:
	$(MAKE) -C $(SRC_NAME) clean

romfs:
	$(ROMFSINST) $(SRC_NAME)/src/dnsmasq /usr/sbin/dnsmasq
