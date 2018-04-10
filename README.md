# DVSA_Officer_FPNs_App_iOS

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=59ef352365e8d5000162c9fd&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/59ef352365e8d5000162c9fd/build/latest?branch=master)

DVSA FPNs Mobile app for Officers

## 1. Environment Setup
Before you build the project, you need to configure your environment secrets.
Use the instructions in **a)** if you are an internal developer, otherwhise use the instructions in **b)**.


#### a) Internal Developer

You have been granted to the following GitLab Private repository: ssh://git@gitlab.rsp.dvsacloud.uk:rsp/secrets_ios.git

```
$ ./developer_setup.sh
```

#### b) External Developer

- Clone the repository

- Copy the secrets template file
```
$ cp SECRETS.TEMPLATE.xcconfig SECRETS.xcconfig
```

- Add your secrets environment values to the **SECRETS.xcconfig** file:

```

ENV_APP_CRASH_REPORTING_CRASHLYTICS_KEY                                         = <Your environment value>
ENV_APP_CRASH_REPORTING_CRASHLYTICS_KEY_BUILD                                   = <Your environment value>

ENV_CODE_SIGN_IDENTITY_DEV_DVSA                                                 = <Your environment value>
ENV_CODE_SIGN_IDENTITY_STORE_DVSA                                               = <Your environment value>
ENV_BUNDLE_IDENTIFIER_DVSA                                                      = <Your environment value>
ENV_BUNDLE_NAME_DVSA                                                            = <Your environment value>
ENV_PROVISIONING_PROFILE_DVSA_DEV                                               = <Your environment value>
ENV_PROVISIONING_PROFILE_SPECIFIER_DVSA_DEV                                     = <Your environment value>
ENV_PROVISIONING_PROFILE_DVSA_DIST                                              = <Your environment value>
ENV_PROVISIONING_PROFILE_SPECIFIER_DVSA_DIST                                    = <Your environment value>
ENV_COMMON_DVSA_DEVELOPMENT_TEAM                                                = <Your environment value>

//...

ENV_ADAL_REDIRECT_SCHEMA_PROD                                                   = <Your environment value>

ENV_SNS_ARN_PREFIX_PROD                                                         = <Your environment value>
ENV_SNS_ARN_SANDBOX_PREFIX_PROD                                                 = <Your environment value>

```

- Update the directory structure
```
$ mkdir ConditionalBundleResources
$ cd ConditionalBundleResources
$ mkdir DEV
$ mkdir PERF
$ mkdir PROD
$ mkdir QA
$ mkdir UAT
$ cd ..
```

- Add all the **awsconfiguration.json** you have generated from the AWS Mobile Hub under the folders:
    - ConditionalBundleResources/DEV
    - ConditionalBundleResources/PERF
    - ConditionalBundleResources/PROD
    - ConditionalBundleResources/QA
    - ConditionalBundleResources/UAT

```
{
  "UserAgent": "MobileHub/1.0",
  "Version": "1.0",
  "CredentialsProvider": {
    "CognitoIdentity": {
      "Default": {
        "PoolId": "<Your AWS CognitoIdentity PoolId>",
        "Region": "<Your AWS Region>"
      }
    }
  },
  "IdentityManager": {
    "Default": {
        "PoolId": "<Your AWS CognitoIdentity PoolId>",
        "Region": "<Your AWS Region>"
    }
  },
  "SNS": {
    "Default": {
    "Region": "<Your AWS Region>"
    }
  }
}
```

Uncomment the file Environment.example.swift and set your enviroment variables.


Run

```
pod install
```


