version=1.0
data=berkelium/data

.PHONY: all clean copy build

all: clean copy build

copy:
	mkdir $(data)
	# Copy needed data
	cp ../berkelium ../liblibberkelium.so ../resources.pak ../chrome.pak $(data)
	cp -r ../locales $(data)
	cp ../build/chromium/src/out/Release/libffmpegsumo.so $(data)
	# Patches data
	chrpath -r '$$ORIGIN' $(data)/berkelium $(data)/liblibberkelium.so

build:
	# Now create package
	python setup.py create_package

clean:
	# Create data dir
	rm -rf $(data)

