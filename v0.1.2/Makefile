kernel-version=4.4.6
arch=x86_64

prepare:
	mkdir -p build
	cd ./build && wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(kernel-version).tar.xz && tar -xvJf linux-$(kernel-version).tar.xz && cd ./linux-$(kernel-version) && $(MAKE) mrproper
	cd ./build/linux-$(kernel-version) && patch --dry-run -p2 < ../../patch-$(kernel-version)-v0.1.2
	cd ./build/linux-$(kernel-version) && patch -p2 < ../../patch-$(kernel-version)-v0.1.2

config:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && ./scripts/kconfig/streamline_config.pl > config_strip
	cd ./build/linux-$(kernel-version) &&  mv .config config_sav
	cd ./build/linux-$(kernel-version) &&  mv config_strip .config
	cd ./build/linux-$(kernel-version) && $(MAKE) menuconfig

config_travis:
	cd ./build/linux-$(kernel-version) && cp ../../.config .config
	cd ./build/linux-$(kernel-version) && $(MAKE) defconfig

compile:
	cd ./build/linux-$(kernel-version) && $(MAKE) -j4
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) headers_install ARCH=${arch} INSTALL_HDR_PATH=/usr

install:
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) modules_install
	cd ./build/linux-$(kernel-version) && sudo $(MAKE) install
