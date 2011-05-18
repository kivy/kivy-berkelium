version=1.0
data=berkelium/data

.PHONY: all clean

all: clean
	# Copy needed data
	cp ../berkelium ../liblibberkelium.so ../resources.pak ../chrome.pak $(data)
	cp -r ../locales $(data)
	cp ../build/chromium/src/out/Release/libffmpegsumo.so $(data)

	# Patches data
	chrpath -r '$$ORIGIN' $(data)/berkelium $(data)/liblibberkelium.so

	# Now create package
	python setup.py create_package

clean:
	# Create data dir
	rm -rf $(data)
	mkdir $(data)

