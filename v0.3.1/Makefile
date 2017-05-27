kernel-version=4.11.2
lsm-version=0.3.1
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(kernel-version).tar.xz && tar -xJf linux-$(kernel-version).tar.xz && cd ./linux-$(kernel-version) && $(MAKE) mrproper
	cd ./build/linux-$(kernel-version) && patch --dry-run -p2 < ../../patch-$(kernel-version)-v$(lsm-version)
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
	cd ./build/linux-$(kernel-version) && sudo cp -f .config /boot/config-$(kernel-version)camflow-$(lsm-version)

config_circle:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && $(MAKE) olddefconfig

compile:
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm..."
	cd ./build/linux-$(kernel-version) && $(MAKE) rpm-pkg
	mkdir -p output
	echo "Moving src rpm..."
	mv -f /home/${USER}/rpmbuild/SRPMS/kernel-$(kernel-version)camflow_$(lsm-version)-2.src.rpm output/kernel-$(kernel-version)camflow_$(lsm-version)-2.src.rpm
	echo "Moving kernel rpm..."
	mv -f /home/${USER}/rpmbuild/RPMS/x86_64/kernel-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm output/kernel-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm
	echo "Moving kernel headers rpm..."
	mv -f /home/${USER}/rpmbuild/RPMS/x86_64/kernel-headers-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm output/kernel-headers-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm
	echo "Moving kernel devel rpm..."
	mv -f /home/${USER}/rpmbuild/RPMS/x86_64/kernel-devel-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm output/kernel-devel-$(kernel-version)camflow_$(lsm-version)-2.x86_64.rpm
	echo "Done."

install:
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) modules_install
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) install

clean:
	rm -rf ./build
