//
//  AWSADALSignInProvider.m
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 08/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

#import "AWSADALSignInProvider.h"
#import <AWSAuthCore/AWSSignInManager.h>
#import <ADAL/ADAL.h>
#import "DVSA_Officer_FPNs_App-Swift.h"

static NSTimeInterval const AWSADALSignInProviderTokenRefreshBuffer = 10 * 60;

NSNotificationName const AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION = @"AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION";

typedef void (^AWSSignInManagerCompletionBlock)(id result, NSError *error);

@interface AWSSignInManager()

- (void)completeLogin;

@end

@interface AWSADALSignInProvider() {
    NSString *clientID;
    NSURL *redirectURI;
    NSString *resource;
    NSString *authority;
    NSString *tenantID;
    NSString *oidcProviderName;
}
@property (atomic, strong) ADTokenCacheItem *tokenCacheItem;
@property (atomic, copy) AWSSignInManagerCompletionBlock completionHandler;
@property (strong, nonatomic) AWSTaskCompletionSource *taskCompletionSource;
@property (nonatomic, strong) AWSUICKeyChainStore *keychain;
@end

@implementation AWSADALSignInProvider

- (ADTokenCacheItem *)tokenCacheItem {
    
    
    NSString *stringToken = self.keychain[@"kADALTokenCacheItem"];
    if (stringToken == nil) { return nil; }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:stringToken options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
    if (data == nil) { return nil; }
    ADTokenCacheItem *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return obj;
}

- (void)setTokenCacheItem:(ADTokenCacheItem *)tokenCacheItem {
    if (tokenCacheItem == nil) {
        self.keychain[@"kADALTokenCacheItem"] = nil;
        [[XCGLoggerWrapper shared] verboseWithValue: @"tokenCacheItem = nil"];
    } else {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:tokenCacheItem];
        NSString *stringToken = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        self.keychain[@"kADALTokenCacheItem"] = stringToken;
        [[XCGLoggerWrapper shared] verboseWithValue: @"tokenCacheItem != nil"];
    }
}

+ (instancetype)sharedInstance {
    static AWSADALSignInProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AWSADALSignInProvider alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)isLoggedIn {
    BOOL value = (self.tokenCacheItem != nil);
    NSString *info = value ? @"AWSADAL tokenCacheItem has value" : @"AWSADAL tokenCacheItem is empty";
    [[XCGLoggerWrapper shared] infoWithValue: info];
    return value;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        redirectURI = [NSURL URLWithString:[Environment adalRedirectURI]];
        clientID = [Environment adalClientId];
        resource = [Environment adalResource];
        authority = [Environment adalAuthority];
        oidcProviderName = [Environment adalOIDCProvider];
        NSString *service = [NSBundle mainBundle].bundleIdentifier;
        [[XCGLoggerWrapper shared] debugWithValue: [NSString stringWithFormat:@"keyChainStoreWithService:%@",service]];
        self.keychain = [AWSUICKeyChainStore keyChainStoreWithService:service];
    }
    return self;
}

- (NSString *)identityProviderName {
    return oidcProviderName;
}

- (nonnull AWSTask<NSString *> *)token {

    NSString *tokenString = self.tokenCacheItem.accessToken;
    NSDate *idTokenExpirationDate = self.tokenCacheItem.expiresOn;
    
    if (tokenString
        // If the cached token expires within 10 min, tries refreshing a token.
        && [idTokenExpirationDate compare:[NSDate dateWithTimeIntervalSinceNow:AWSADALSignInProviderTokenRefreshBuffer]] == NSOrderedDescending) {
        [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL Cached token is not expired."];
        return [AWSTask taskWithResult:tokenString];
    }
    
    [[XCGLoggerWrapper shared] warningWithValue: @"AWSADAL Cached token expires within 10 min, tries refreshing a token."];
    self.taskCompletionSource = [AWSTaskCompletionSource taskCompletionSource];
    
    ADAuthenticationError *error;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority error:&error];

    __weak typeof(self) weakSelf = self;
    
    //TODO Check if we need to use the silent method
    [authContext acquireTokenSilentWithResource:resource clientId:clientID redirectUri:redirectURI completionBlock:^(ADAuthenticationResult *result) {
        if (AD_SUCCEEDED != result.status) {
            if (error.code == AD_ERROR_SERVER_USER_INPUT_NEEDED) {
                //It's required to call acquireTokenWithResource
                [weakSelf logout];
                [[NSNotificationCenter defaultCenter] postNotificationName:AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION object:nil userInfo:@{}];
            }
            [weakSelf.taskCompletionSource trySetError:result.error];
            [[XCGLoggerWrapper shared] errorWithValue:result.error];
        } else {
            [weakSelf logToken:result.tokenCacheItem];
            weakSelf.tokenCacheItem = result.tokenCacheItem;
            [weakSelf.taskCompletionSource trySetResult:result.accessToken];
            [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL AD_SUCCEEDED"];
        }
    }];
    return weakSelf.taskCompletionSource.task;
}

- (void)login:(nonnull void (^)(id _Nullable, NSError * _Nullable))completionHandler {

    [[XCGLoggerWrapper shared] infoWithValue: @"AWSADAL login"];
    self.completionHandler = completionHandler;
    if (self.tokenCacheItem != nil) {
        [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL reusing tokenCacheItem"];
        [self completeLogin];
        return;
    }
    
    ADAuthenticationError *error;
    ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority error:&error];
    
    __weak typeof(self) weakSelf = self;
    
    [authContext acquireTokenWithResource:resource clientId:clientID redirectUri:redirectURI completionBlock:^(ADAuthenticationResult *result) {
        
        switch (result.status) {
            case AD_USER_CANCELLED: {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[@"message"] = @"User Cancelled Login";
                    NSError *resultError = [NSError errorWithDomain:@"AWSADALSignInProvider" code:100 userInfo:userInfo];
                    [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL User Cancelled Login"];
                    weakSelf.completionHandler(result, resultError);
                }
                break;
            case AD_FAILED:
                [[XCGLoggerWrapper shared] errorWithValue:result.error];
                weakSelf.completionHandler(result, result.error);
                break;
            case AD_SUCCEEDED:{
                [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL AD_SUCCEEDED"];
                [weakSelf logToken:result.tokenCacheItem];
                weakSelf.tokenCacheItem = result.tokenCacheItem;
                [weakSelf completeLogin];
                }
                break;
            default:
                break;
        }
    }];
}

- (void)logout {
    
    [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL logout"];
    self.tokenCacheItem = nil;
    NSError *error;
    [[ADKeychainTokenCache defaultKeychainCache] removeAllForClientId:clientID error:&error];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieJar.cookies){
        [cookieJar deleteCookie:cookie];
    }
}

- (void)logToken:(ADTokenCacheItem *)tokenCacheItem {
  
#ifdef DEBUG
    NSDate *expiresOn = tokenCacheItem.expiresOn;
    NSString *userID = tokenCacheItem.userInformation.userId;
    NSString *adalUser = [NSString stringWithFormat:@"ADAL user:%@", userID];
    NSString *adalToken = [NSString stringWithFormat:@"ADAL Access token: %@\nexpiration:%@",
                           tokenCacheItem.accessToken,
                           expiresOn];
    [[XCGLoggerWrapper shared] debugWithValue:adalUser];
    [[XCGLoggerWrapper shared] debugWithValue:adalToken];
#endif
}

- (void)reloadSession {
    
    [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL reloadSession"];
    if (self.tokenCacheItem != nil) {
        
        ADAuthenticationError *error;
        ADAuthenticationContext *authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority error:&error];
        __weak typeof(self) weakSelf = self;
        [authContext acquireTokenSilentWithResource:resource clientId:clientID redirectUri:redirectURI completionBlock:^(ADAuthenticationResult *result) {
            
            if (AD_SUCCEEDED != result.status) {
                NSError *error = result.error;
                [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL reloadSession failed"];
                [[XCGLoggerWrapper shared] errorWithValue:error];
                [self logToken:self.tokenCacheItem];
                if (error.code == AD_ERROR_SERVER_USER_INPUT_NEEDED) {
                    //It's required to call acquireTokenWithResource
                    [self logout];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AD_ERROR_SERVER_USER_INPUT_NEEDED_NOTIFICATION object:nil userInfo:@{}];
                }
            } else {
                [[XCGLoggerWrapper shared] infoWithValue:@"AWSADAL reloadSession succeded"];
                weakSelf.tokenCacheItem = result.tokenCacheItem;
                [weakSelf completeLogin];
            }
        }];
    }
}

- (BOOL)interceptApplication:(nonnull UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)interceptApplication:(nonnull UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    return YES;
}

- (void)completeLogin {
    //FIX AD_ERROR_UI_NOT_ON_MAIN_THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AWSSignInManager sharedInstance] completeLogin];
    });
}

@end

