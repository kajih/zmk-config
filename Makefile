
# Källkodskataloger
ZMK_APP := zmk/app
CONFIG_DIR := config
CONFIG_ABS := $(abspath config)
OUT_DIR := out
DIST_DIR := dist

MODULE_PATH := $(shell echo $(abspath $(MODULES)) | tr ' ' ';')

# Exportera miljövariabeln så den gäller för alla regler
export CMAKE_PREFIX_PATH := $(CONFIG_DIR)/zephyr:$(CMAKE_PREFIX_PATH)

# Tidsstämpel för builds
BUILD_DATE := $(shell date +"%Y%m%d-%H%M")

# Standardmål
all: left right

init:
	rm -rf .west
	west init -l config

update:
	west update
	west zephyr-export

# Bygg vänster halva
left:
	west build -d build/left -s $(ZMK_APP) -b nice_nano_v2 -S "studio-rpc-usb-uart" \
		-- -DZMK_CONFIG=$(CONFIG_ABS) \
		-DSHIELD="kyria_rev3_left nice_view_adapter nice_view" \
		-DCONFIG_ZMK_STUDIO=y
	mkdir -p $(OUT_DIR)
	cp build/left/zephyr/zmk.uf2 $(OUT_DIR)/firmware-kyria_rev3_left-nice_view_adapter-nice_view-nice_nano_v2-$(BUILD_DATE).uf2

# Bygg höger halva
right:
	west build -d build/right -s $(ZMK_APP) -b nice_nano_v2 -S "studio-rpc-usb-uart" -- \
		-DZMK_CONFIG=$(CONFIG_ABS) \
		-DSHIELD="kyria_rev3_right nice_view_adapter nice_view"
	mkdir -p $(OUT_DIR)
	cp build/right/zephyr/zmk.uf2 $(OUT_DIR)/firmware-kyria_rev3_right-nice_view_adapter-nice_view-nice_nano_v2-$(BUILD_DATE).uf2

# Paketera firmware som zip
dist: all
	mkdir -p $(DIST_DIR)
	zip -j $(DIST_DIR)/firmware-$(BUILD_DATE).zip $(OUT_DIR)/*.uf2

clean:
	rm -rf build $(OUT_DIR) $(DIST_DIR)

distclean:
	rm -rf build modules zephyr zmk $(OUT_DIR) $(DIST_DIR)

.PHONY: all update left right clean dist init
