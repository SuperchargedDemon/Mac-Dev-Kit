.PHONY: doctor build test ios-app mac-app zip clean

doctor:
	cd swift && swift run macdev doctor

build:
	cd swift && swift build -c release

test:
	cd swift && swift test

ios-app:
	cd ios && xcodegen generate && \
	xcodebuild -project AuroraDemo.xcodeproj -scheme AuroraDemo \
		-sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
		CODE_SIGNING_ALLOWED=NO build

mac-app:
	cd ios && xcodegen generate && \
	xcodebuild -project AuroraDemo.xcodeproj -scheme AuroraMac \
		-destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build

zip:
	mkdir -p dist
	cp swift/.build/release/macdev dist/
	cd build/Build/Products && \
		ditto -c -k --sequesterRsrc --keepParent Release/AuroraMac.app ../../dist/AuroraMac.zip

clean:
	rm -rf swift/.build build dist ios/*.xcodeproj
