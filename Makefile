kernel-version=5.9.11
lsm-version=0.7.1
fedora-version=33
ubuntu-version='bionic'
arch=x86_64

prepare:
	mkdir -p ~/build
	cd ~/build && git clone -b v$(kernel-version) --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
	cd ~/build/linux-stable && $(MAKE) mrproper
	cd ~/build && wget https://github.com/camflow/camflow-dev/releases/download/v$(lsm-version)/0001-information-flow.patch
	cd ~/build/linux-stable && git apply ../0001-information-flow.patch
	cd ~/build && wget https://github.com/camflow/camflow-dev/releases/download/v$(lsm-version)/0002-camflow.patch
	cd ~/build/linux-stable && git apply ../0002-camflow.patch
	cd ~/build/linux-stable && sed -i -e "s/EXTRAVERSION =/EXTRAVERSION = camflow$(lsm-version)/g" Makefile

config_def:
	echo "Default method to retrieve configuration"
	cd ~/build/linux-stable && cp -f /boot/config-$(shell uname -r) .config

config_pi:
	echo "Pi method to retrieve configuration"
	sudo modprobe configs
	zcat /proc/config.gz > /tmp/config.new
	cd ~/build/linux-stable && cp -f /tmp/config.new .config

config:
	test -f /boot/config-$(shell uname -r) && $(MAKE) config_def || $(MAKE) config_pi
	cd ~/build/linux-stable && $(MAKE) olddefconfig
	cd ~/build/linux-stable && $(MAKE) menuconfig
	cd ~/build/linux-stable && sudo cp -f .config /boot/config-$(kernel-version)camflow-$(lsm-version)
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO=n/CONFIG_DEBUG_INFO=y/g" .config
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO_BTF=n/CONFIG_DEBUG_INFO_BTF=y/g" .config

config_small:
	test -f /boot/config-$(shell uname -r) && $(MAKE) config_def || $(MAKE) config_pi
	cd ~/build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ~/build/linux-stable &&  mv .config config_sav
	cd ~/build/linux-stable &&  mv config_strip .config
	cd ~/build/linux-stable && $(MAKE) menuconfig
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO=n/CONFIG_DEBUG_INFO=y/g" .config
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_DEBUG_INFO_BTF=n/CONFIG_DEBUG_INFO_BTF=y/g" .config

config_travis:
	cp .config_fedora ~/build/linux-stable/.config
	cd ~/build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ~/build/linux-stable &&  mv .config config_sav
	cd ~/build/linux-stable &&  mv config_strip .config
	cd ~/build/linux-stable && $(MAKE) olddefconfig
	cd ~/build/linux-stable && $(MAKE) oldconfig
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

config_circle_fedora:
	cp .config_fedora ~/build/linux-stable/.config
	cd ~/build/linux-stable && $(MAKE) olddefconfig
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

config_circle_ubuntu:
	cp .config_ubuntu ~/build/linux-stable/.config
	cd ~/build/linux-stable && $(MAKE) olddefconfig
	cd ~/build/linux-stable && sed -i -e "s/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor\"/CONFIG_LSM=\"yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,provenance\"/g" .config

compile_security:
	cd ~/build/linux-stable && $(MAKE) security W=1

compile:
	cd ~/build/linux-stable && $(MAKE) -j16
	cd ~/build/linux-stable && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

deb:
	echo "Starting to build deb packages..."
	cd ~/build/linux-stable && $(MAKE) -j 16 deb-pkg

move_deb:
	echo "Preparing packages..."
	mkdir -p output
	mv -f ~/build/*.deb ./output
	cd output && ls

publish:
	cd output && ls
	cd output && ../scripts/upload_rpm_packages.sh camflow/provenance/fedora/$(fedora-version)
	cd output && ../scripts/upload_deb_packages.sh camflow/provenance/ubuntu/$(ubuntu-version)

install:
	cd ~/build/linux-stable && sudo $(MAKE) modules_install
	cd ~/build/linux-stable && sudo $(MAKE) install

clean:
	rm -rf ~/build
	rm -rf ./output

fedora:
	mkdir -p ~/build
	cd ~/build && fedpkg clone -a kernel
	cd ~/build/kernel && git checkout -b camflow origin/f$(fedora-version)
	cd ~/build/kernel && sudo dnf -y builddep kernel.spec
	cd ~/build/kernel && wget https://github.com/camflow/camflow-dev/releases/download/v$(lsm-version)/0001-information-flow.patch
	cd ~/build/kernel && wget https://github.com/camflow/camflow-dev/releases/download/v$(lsm-version)/0002-camflow.patch
	./scripts/add_patch.sh
	cd ~/build/kernel && sed -i -e "s/# define buildid .local/%define buildid .camflow/g" kernel.spec
	cd ~/build/kernel && sed -i -e "s/%define with_headers 0/%define with_headers 1/g" kernel.spec
	cd ~/build/kernel && sed -i -e "s/%define with_cross_headers 0/%define with_cross_headers 1/g" kernel.spec
	./scripts/prep_config.sh
	cd ~/build/kernel && make release
	cd ~/build/kernel && fedpkg prep
	cd ~/build/kernel && fedpkg local
	mkdir -p output
	mv -f ~/build/kernel/x86_64/*.rpm ./output
	mv -f ~/build/kernel/*.rpm ./output
	cd output && ls
