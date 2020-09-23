include properties.mk

appName = `grep entry manifest.xml | sed 's/.*entry="\([^"]*\).*/\1/'`
#appName = OpenWatchFaceApp
devices = `grep 'iq:product id' manifest.xml | sed 's/.*iq:product id="\([^"]*\).*/\1/'`
JAVA_OPTIONS = JDK_JAVA_OPTIONS="--add-modules=java.xml.bind"

build:
	$(SDK_HOME)/bin/monkeyc \
	--jungles ./monkey.jungle \
	--device $(DEVICE) \
	--output bin/$(appName).prg \
	--private-key $(PRIVATE_KEY) \
	--warn

buildall:
	@for device in $(devices); do \
		echo "-----"; \
		echo "Building for" $$device; \
    $(SDK_HOME)/bin/monkeyc \
		--jungles ./monkey.jungle \
		--device $$device \
		--output bin/$(appName)-$$device.prg \
		--private-key $(PRIVATE_KEY) \
		--warn; \
	done

debug: build
	connectiq & \
	mdd -e bin/$(appName).prg -x bin/$(appName).prg.debug.xml -d $(DEVICE)

go: build
	connectiq & \
	monkeydo bin/$(appName).prg $(DEVICE)

run: build
	connectiq & \
       	sleep 3 && \
	monkeydo bin/$(appName).prg $(DEVICE)

test:
	echo "Device: "$(DEVICE)

deploy: build
	@cp bin/$(appName).prg $(DEPLOY)

package:
	@$(SDK_HOME)/bin/monkeyc \
	--jungles ./monkey.jungle \
	--package-app \
	--release \
	--output bin/$(appName).iq \
	--private-key $(PRIVATE_KEY) \
	--warn
