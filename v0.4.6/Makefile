kernel-version=4.20
lsm-version=0.4.6
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && git clone -b v$(kernel-version) --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
	cd ./build/linux-stable && $(MAKE) mrproper
	cd ./build/linux-stable && patch -p2 < ../../patch-$(kernel-version)-v$(lsm-version)

config_def:
	echo "Default method to retrieve configuration"
	cd ./build/linux-stable && cp -f /boot/config-$(shell uname -r) .config

config_pi:
	echo "Pi method to retrieve configuration"
	sudo modprobe configs
	zcat /proc/config.gz > /tmp/config.new
	cd ./build/linux-stable && cp -f /tmp/config.new .config

config:
	test -f /boot/config-$(shell uname -r) && $(MAKE) config_def || $(MAKE) config_pi
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && $(MAKE) menuconfig
	cd ./build/linux-stable && sudo cp -f .config /boot/config-$(kernel-version)camflow-$(lsm-version)

config_travis:
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-stable &&  mv .config config_sav
	cd ./build/linux-stable &&  mv config_strip .config
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && $(MAKE) oldconfig

config_circle:
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && $(MAKE) olddefconfig

compile:
	cd ./build/linux-stable && $(MAKE) -j16
	cd ./build/linux-stable && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm..."
	cd ./build/linux-stable && $(MAKE) -j16 rpm-pkg

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
	cd ./output && ls
	cd ./output && rename -v -f 's/$(lsm-version)\+-[1-9]/$(lsm-version)/gi' *.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/27 kernel-headers-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/27 kernel-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/27 kernel-$(kernel-version)camflow$(lsm-version).src.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/27 kernel-devel-$(kernel-version)camflow$(lsm-version).x86_64.rpm

install:
	cd ./build/linux-stable && sudo $(MAKE) modules_install
	cd ./build/linux-stable && sudo $(MAKE) install

clean:
	rm -rf ./build
	rm -rf ./output
