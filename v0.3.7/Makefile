kernel-version=4.13.4
lsm-version=0.3.7
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(kernel-version).tar.xz && tar -xJf linux-$(kernel-version).tar.xz && cd ./linux-$(kernel-version) && $(MAKE) mrproper
	cd ./build/linux-$(kernel-version) && patch -p2 < ../../patch-$(kernel-version)-v$(lsm-version)

config:
	cd ./build/linux-$(kernel-version) && cp -f /boot/config-$(shell uname -r) .config
	cd ./build/linux-$(kernel-version) && $(MAKE) olddefconfig
	cd ./build/linux-$(kernel-version) && $(MAKE) menuconfig
	cd ./build/linux-$(kernel-version) && sudo cp -f .config /boot/config-$(kernel-version)camflow-$(lsm-version)

config_travis:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-$(kernel-version) &&  mv .config config_sav
	cd ./build/linux-$(kernel-version) &&  mv config_strip .config
	cd ./build/linux-$(kernel-version) && $(MAKE) olddefconfig
	cd ./build/linux-$(kernel-version) && $(MAKE) oldconfig

config_circle:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && $(MAKE) silentoldconfig

compile:
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm..."
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4 rpm-pkg

move_local:
	echo "Preparing packages..."
	mkdir -p output
	mv -f /home/$(USER)/rpmbuild/RPMS/x86_64/*.rpm ./output
	mv -f /home/$(USER)/rpmbuild/SRPMS/*.rpm ./output

move:
	echo "Preparing packages..."
	mkdir -p output
	mv -f /root/rpmbuild/RPMS/x86_64/*.rpm ./output
	mv -f /root/rpmbuild/SRPMS/*.rpm ./output

publish:
	cd ./output && rename -v -f 's/$(lsm-version)-[1-9]/$(lsm-version)/gi' *.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/26 kernel-headers-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/26 kernel-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/26 kernel-$(kernel-version)camflow$(lsm-version).src.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/26 kernel-devel-$(kernel-version)camflow$(lsm-version).x86_64.rpm

install:
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) modules_install
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) install

clean:
	rm -rf ./build
	rm -rf ./output
