kernel-version=4.11.3
lsm-version=0.3.2
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && git clone -b v$(kernel-version) --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
	cd ./build/linux-stable && $(MAKE) mrproper
	cd ./build/linux-stable && patch -p2 < ../../patch-$(kernel-version)-v$(lsm-version)

config:
	cd ./build/linux-stable && cp -f /boot/config-$(shell uname -r) .config
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && $(MAKE) menuconfig
	cd ./build/linux-stable && sudo cp -f .config /boot/config-$(kernel-version)camflow-$(lsm-version)

config_travis:
	cp -f /boot/config-$(shell uname -r) .config
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && $(MAKE) defconfig

config_circle:
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && $(MAKE) silentoldconfig

compile:
	cd ./build/linux-stable && $(MAKE) -j4
	cd ./build/linux-stable && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm..."
	cd ./build/linux-stable && $(MAKE) -j4 rpm-pkg

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
	cd ./output && package_cloud push camflow/provenance/fedora/25 kernel-headers-$(kernel-version)camflow_$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/25 kernel-$(kernel-version)camflow_$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/25 kernel-$(kernel-version)camflow_$(lsm-version).src.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/25 kernel-devel-$(kernel-version)camflow_$(lsm-version).x86_64.rpm

install:
	cd ./build/linux-stable && sudo $(MAKE) modules_install
	cd ./build/linux-stable && sudo $(MAKE) install

clean:
	rm -rf ./build
	rm -rf ./output
