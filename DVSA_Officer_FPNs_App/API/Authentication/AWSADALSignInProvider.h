//
//  AWSADALSignInProvider.h
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 08/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSAuthCore/AWSSignInProvider.h>
#import <AWSAuthCore/AWSSignInProviderApplicationIntercept.h>

extern NSNotificationName const AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION;

@interface AWSADALSignInProvider : NSObject <AWSSignInProvider,AWSSignInProviderApplicationIntercept>

/**
 Fetches the singleton instance of AWSADALSignInProvider.
 
 @return the singleton instance of AWSADALSignInProvider
 */
+ (instancetype)sharedInstance;
- (void)logout;

@end
