#!/usr/bin/env bash

# DEVICE SETTINGS
DEVICE="=iPhone 6s (9.3) ["
VERSION=9.3

# SET JAVA HOME TO BE JAVA 8
export JAVA_HOME=$JAVA8_HOME

WORKSPACE=`pwd`

# DETERMINE WHERE THE .app File is 
find /tmp/sandbox/${BUDDYBUILD_APP_ID} -name *.app -print
export APP=$(find /tmp/sandbox/${BUDDYBUILD_APP_ID} -name *.app | grep test | head -1)
echo "== APP LOCATION ${APP}"

# CARRY OUT APPIUM TESTS if We are in Test mode, and have a QA REPO Specified
if [ -d "${APP}" ] && [ "${QA_APPIUM_BRANCH}" != "" ]; then
	echo '=== TEST BUILD AVAILBALE - RUNNING ASSURANCE TESTS'

	echo '=== CHANGING DIRECTORY TO ROOT FOLDER'
	cd /Users/buddybuild/workspace

	echo '=== CLONE QA REPO'
	git clone ${QA_APPIUM_BRANCH} ../QA

	if [ ! -d "../QA" ]
	then
		echo "CLONE FAILED"
		exit 1
	fi

	echo '=== FOLDER LISTING POST BUILD'
	ls -1

	echo '=== Navigate to tests folder'
	cd ../QA

	echo '=== install maven'
	brew install maven

	echo '=== Install appium 1.5.3'
	npm install -g appium@1.5.3

	echo '=== Install selenium-webdriver'
	npm install wd

	echo '=== Authorize simulator access'
	echo password | sudo -S authorize_ios

	echo '=== AVAILABLE SIMULATORS'
	xcrun simctl list

	sleep 15 && ./run_tests.sh . ${APP} MobileAcceptanceTestSuite iphone "${DEVICE}" ${VERSION}

	status=$?
	pkill -f appium
	if [ $status -ne 0 ] 
	then
		echo "=== APPIUM TESTS FAILED"
		exit 1
	fi

	 ./run_tests.sh . "" APIAcceptanceTestSuite webapi
	status=$?
	if [ $status -ne 0 ] 
	then
		echo "=== API TESTS FAILED"
		exit 1
	fi

	echo "=== TEST SUCCEEDED"

	# UPLOAD RESULT TO AWS
	if [ "$AWS_S3_BUCKET" != "" ]
	then
		echo '=== Upload results to s3'
		aws s3 sync ./TestResults s3://$AWS_S3_BUCKET/AppiumResults/
	else
		echo '=== NOT UPLOADED RESULTS TO AWS'
	fi

else 
        echo '=== TEST BUILD NOT AVAILABLE - NOT RUNNING ASSURANCE TESTS'
fi

# Upload to Crashlytics
if [ "$Crashlytics_API" != "" ]
then
	echo '=== Upload to Crashlytics'
	pwd
	cd $WORKSPACE
	git log -1 --pretty=%B > releaseNotes.txt

  	./Pods/Crashlytics/submit $Crashlytics_API $Crashlytics_SECRET -ipaPath $BUDDYBUILD_IPA_PATH -emails Tim.Walpole@bjss.com -groupAliases $Crashlytics_DIST_DEV_QA -notesPath ./releaseNotes.txt
fi

echo "=== SUCCEEDED"

exit 0

# Uplad to AWS for Device Testin
if [ "$FL_AWS_DEVICE_FARM_NAME" != "" ]
	echo '=== Uploading to AWS Device Farm for ON-DEVICE Testing'
	cd QA
	mvn clean package -DskipTests=true
	fastlane test_appium_aws_device
else
        echo '=== AWS Device Farm Name not set - Not Running ON-DEVICE Tests'
fi
