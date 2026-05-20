.PHONY: clean build watch apk

clean:
	flutter clean

build:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

apk:
	flutter clean && flutter build apk --release