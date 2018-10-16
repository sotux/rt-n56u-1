SRC_NAME=shadowsocks-libev-3.2.1
ARCHIVE_NAME=shadowsocks-libev-3.2.1
THISDIR = $(shell pwd)

all: extract_test config_test
	$(MAKE) -C $(SRC_NAME)

extract_test:
	( if [ ! -d $(SRC_NAME) ]; then \
		tar -xzvf $(ARCHIVE_NAME).tar.gz ; \
	fi )

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( cd $(SRC_NAME) ; \
	./configure \
		--prefix=/usr \
		--disable-documentation \
		--disable-ssp \
		--disable-assert \
		--with-ev="$(STAGEDIR)" \
		--with-pcre="$(STAGEDIR)" \
		--with-cares="$(STAGEDIR)" \
		--with-sodium="$(STAGEDIR)" \
		--with-mbedtls="$(STAGEDIR)" \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) clean ; \
	fi ; \
	rm -f config_done

romfs:
	chmod -R +x scripts/
	$(ROMFSINST) $(THISDIR)/gfwlist_mode.txt /etc_ro/gfwlist_mode.txt
	$(ROMFSINST) $(THISDIR)/gfwlist.conf.tar.gz /etc_ro/gfwlist.conf.tar.gz
	$(ROMFSINST) $(THISDIR)/obfs-local /usr/bin/obfs-local
	$(ROMFSINST) $(THISDIR)/scripts/ /usr/bin/
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_NAME)/src/ss-redir /usr/bin/ss-redir
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_NAME)/src/ss-local /usr/bin/ss-local
	$(ROMFSINST) -p +x $(THISDIR)/$(SRC_NAME)/src/ss-tunnel /usr/bin/ss-tunnel

