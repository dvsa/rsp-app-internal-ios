#!/usr/bin/env bash
#echo password | sudo -S gem update fastlane
# fastlane downloadDevProfiles
# fastlane downloadAssuranceProfiles
# fastlane downloadProdDevProfiles
# fastlane downloadProdProfiles

#Current Directory
pwd
ls

#Create Directory Structure
mkdir ConditionalBundleResources
cd ConditionalBundleResources
mkdir DEV
mkdir PERF
mkdir PROD
mkdir QA
mkdir UAT
mkdir UITests
cd ..
ls

#Copy Secret Files
cp ${BUDDYBUILD_SECURE_FILES}/awsconfiguration_DEV.json ConditionalBundleResources/DEV/awsconfiguration.json
cp ${BUDDYBUILD_SECURE_FILES}/awsconfiguration_PERF.json ConditionalBundleResources/PERF/awsconfiguration.json
cp ${BUDDYBUILD_SECURE_FILES}/awsconfiguration_PROD.json ConditionalBundleResources/PROD/awsconfiguration.json
cp ${BUDDYBUILD_SECURE_FILES}/awsconfiguration_QA.json ConditionalBundleResources/QA/awsconfiguration.json
cp ${BUDDYBUILD_SECURE_FILES}/awsconfiguration_UAT.json ConditionalBundleResources/UAT/awsconfiguration.json
cp ${BUDDYBUILD_SECURE_FILES}/UITestsConfig.plist DVSA_Officer_FPNs_AppUITests/
cp ${BUDDYBUILD_SECURE_FILES}/Environment.swift DVSA_Officer_FPNs_App/