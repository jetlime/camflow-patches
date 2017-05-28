kernel-version=4.11.2
lsm-version=0.3.1
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
	cp -f /boot/config-$(shell uname -r) .config
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && $(MAKE) defconfig

config_circle:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && $(MAKE) silentoldconfig

compile:
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm..."
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4 binrpm-pkg

publish:
	echo "Preparing packages..."
	mkdir -p output
	mv -f /root/rpmbuild/RPMS/x86_64/*.rpm ./output
	echo "Publishing kernel package..."
	cd ./output && package_cloud push tfjmp/camflow/fedora/25 kernel-$(kernel-version)camflow_$(lsm-version)-1.x86_64.rpm
	echo "Publishing kernel headers package..."
	cd ./output && package_cloud push tfjmp/camflow/fedora/25 kernel-headers-$(kernel-version)camflow_$(lsm-version)-1.x86_64.rpm

install:
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) modules_install
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) install

clean:
	rm -rf ./build
	rm -rf ./output
