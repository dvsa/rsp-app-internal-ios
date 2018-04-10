export GIT_SECRETS_REPO="../secrets_ios"
echo $GIT_SECRETS_REPO
if [ -d "${GIT_SECRETS_REPO}" ]
then
    echo "Secrets Repo is present"
else
    echo "Cloning Secrets Repo"
    git clone git@gitlab.rsp.dvsacloud.uk:rsp/secrets_ios.git ${GIT_SECRETS_REPO}
fi

if [ -d "ConditionalBundleResources" ]
then
    echo "The ConditionalBundleResources folder exists"
else
    mkdir ConditionalBundleResources
    cd ConditionalBundleResources
    mkdir DEV
    mkdir PERF
    mkdir PROD
    mkdir QA
    mkdir UAT
    cd ..
fi

echo "Copying Secrets"

cp ${GIT_SECRETS_REPO}/SECRETS.xcconfig .
cp -r ${GIT_SECRETS_REPO}/fastlane fastlane
cp -r ${GIT_SECRETS_REPO}/ConditionalBundleResources/* ConditionalBundleResources/
cp ${GIT_SECRETS_REPO}/UITestsConfig.plist DVSA_Officer_FPNs_AppUITests/
cp ${GIT_SECRETS_REPO}/Environment.swift DVSA_Officer_FPNs_App/

echo "Dev Environment is Ready"
