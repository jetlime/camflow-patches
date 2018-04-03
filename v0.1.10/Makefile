kernel-version=4.4.31
lsm-version=0.1.10
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && git clone -b v$(kernel-version) --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
	cd ./build/linux-stable && $(MAKE) mrproper
	cd ./build/linux-stable && patch --dry-run -p2 < ../../patch-$(kernel-version)-v$(lsm-version)
	cd ./build/linux-stable && patch -p2 < ../../patch-$(kernel-version)-v$(lsm-version)

config:
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-stable &&  mv .config config_sav
	cd ./build/linux-stable &&  mv config_strip .config
	cd ./build/linux-stable && $(MAKE) menuconfig

config_travis:
	cd ./build/linux-stable && cp ../../.config .config
	cd ./build/linux-stable && $(MAKE) defconfig

compile:
	cd ./build/linux-stable && $(MAKE) -j4
	cd ./build/linux-stable && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

install:
	cd ./build/linux-stable && sudo $(MAKE) modules_install
	cd ./build/linux-stable && sudo $(MAKE) install
