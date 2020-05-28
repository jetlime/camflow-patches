kernel-version=5.6.7
lsm-version=0.6.6
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && git clone -b v$(kernel-version) --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
	cd ./build/linux-stable && $(MAKE) mrproper
	cd ./build/linux-stable && patch -p2 < ../../patch-$(kernel-version)-v$(lsm-version)
	cd ./build/linux-stable/scripts/package && sed -i -e '/%define debug_package %{nil}/d' mkspec

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
	cd ./build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config
	cd ./build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO=n/CONFIG_DEBUG_INFO=y/g" .config
	cd ./build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO_BTF=n/CONFIG_DEBUG_INFO_BTF=y/g" .config

config_small:
	test -f /boot/config-$(shell uname -r) && $(MAKE) config_def || $(MAKE) config_pi
	cd ./build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-stable &&  mv .config config_sav
	cd ./build/linux-stable &&  mv config_strip .config
	cd ./build/linux-stable && $(MAKE) menuconfig
	cd ./build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config
	cd ./build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO=n/CONFIG_DEBUG_INFO=y/g" .config
	cd ./build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO_BTF=n/CONFIG_DEBUG_INFO_BTF=y/g" .config

config_travis:
	cd ./build/linux-stable && cp ../../.config_fedora .config
	cd ./build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-stable &&  mv .config config_sav
	cd ./build/linux-stable &&  mv config_strip .config
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && $(MAKE) oldconfig
	cd ./build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

config_circle_fedora:
	cd ./build/linux-stable && cp ../../.config_fedora .config
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

config_circle_ubuntu:
	cd ./build/linux-stable && cp ../../.config_ubuntu .config
	cd ./build/linux-stable && $(MAKE) olddefconfig
	cd ./build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

compile_security:
	cd ./build/linux-stable && $(MAKE) security W=1

compile:
	cd ./build/linux-stable && $(MAKE) -j16
	cd ./build/linux-stable && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

rpm:
	echo "Starting building rpm packages..."
	cd ./build/linux-stable && $(MAKE) -j16 rpm-pkg

deb:
	echo "Starting to build deb packages..."
	cd ./build/linux-stable && $(MAKE) -j 16 deb-pkg

move_local:
	echo "Preparing packages..."
	mkdir -p output
	mv -f /home/$(USER)/rpmbuild/RPMS/x86_64/*.rpm ./output
	mv -f /home/$(USER)/rpmbuild/SRPMS/*.rpm ./output
	mv -f build/*.deb ./output

move_rpm:
	echo "Preparing packages..."
	mkdir -p output
	mv -f /root/rpmbuild/RPMS/x86_64/*.rpm ./output
	mv -f /root/rpmbuild/SRPMS/*.rpm ./output
	cd output && ls

move_deb:
	echo "Preparing packages..."
	mkdir -p output
	mv -f build/*.deb ./output
	cd output && ls

publish:
	cd ./output && ls
	cd ./output && rename -v -f 's/$(lsm-version)\+-[1-9]/$(lsm-version)/gi' *.rpm
	cd ./output && ls
	cd ./output && package_cloud push camflow/provenance/fedora/31 kernel-headers-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/31 kernel-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/31 kernel-$(kernel-version)camflow$(lsm-version).src.rpm
	cd ./output && package_cloud push camflow/provenance/fedora/31 kernel-devel-$(kernel-version)camflow$(lsm-version).x86_64.rpm
	cd ./output && package_cloud push camflow/provenance/ubuntu/bionic linux-headers-$(kernel-version)camflow$(lsm-version)+_$(kernel-version)camflow$(lsm-version)+-1_amd64.deb
	cd ./output && package_cloud push camflow/provenance/ubuntu/bionic linux-image-$(kernel-version)camflow$(lsm-version)+_$(kernel-version)camflow$(lsm-version)+-1_amd64.deb
	cd ./output && package_cloud push camflow/provenance/ubuntu/bionic linux-libc-dev_$(kernel-version)camflow$(lsm-version)+-1_amd64.deb

install:
	cd ./build/linux-stable && sudo $(MAKE) modules_install
	cd ./build/linux-stable && sudo $(MAKE) install

clean:
	rm -rf ./build
	rm -rf ./output

fedora:
	mkdir -p build
	cd build && fedpkg co -a kernel
	cd build/kernel && git checkout -b camflow origin/f31
	cd build/kernel && sudo dnf -y builddep kernel.spec
	cd build/kernel && sed -i -e "s/# define buildid .local/%define buildid .camflow/g" kernel.spec
	cd build/kernel && make release
	cd build/kernel && fedpkg local
