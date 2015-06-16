//
//  NetworkAPIUtility.m
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "NetworkAPIUtility.h"

#import "HTTPSessionManager.h"

#pragma mark - API paths

static NSString *const UserLoginPath = @"v1/user/authenticate";
static NSString *const UserRegisterPath = @"v1/user";
static NSString *const CurrentUserFetchPath = @"v1/user";
static NSString *const SpecificUserFetchPathFormat = @"v1/user/%@"; // v1/user/:id
static NSString *const FacebookLoginRegisterPath = @"v1/user/facebook";
static NSString *const PasswordResetPath = @"v1/password-reset/request";
static NSString *const NotificationRegisterPath = @"v1/push/apn";

static NSString *const APIKeyEmail = @"email";
static NSString *const APIKeyPassword = @"password";
static NSString *const APIKeyUserID = @"id";
static NSString *const APIKeyUserAuthToken = @"token";
static NSString *const APIKeyFacebookID = @"facebook_id";
static NSString *const APIKeyFacebookToken = @"token";
static NSString *const APIKeyPushNotificationToken = @"token";

#pragma mark - Constants for errors

NSString *const NetworkAPIUtilityErrorDomain = @"NetworkAPIUtilityErrorDomain";

const struct NetworkAPIUtilityErrorCodes NetworkAPIUtilityErrorCodes = {
    .UnexpectedResponseType = 300001,
};

const struct NetworkAPIUtilityErrorInfoKeys NetworkAPIUtilityErrorInfoKeys = {
    .ReceivedResponseType = @"Received response type",
};

#pragma mark - Class implementation

@implementation NetworkAPIUtility

+ (instancetype)sharedUtility
{
    static NetworkAPIUtility *_sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [NetworkAPIUtility new];
    });
    return _sharedUtility;
}

- (void)registerWithEmailAddress:(NSString *)email
                        password:(NSString *)password
                      completion:(UserInfoCompletionBlock)completion
{
    NSParameterAssert(email);
    NSParameterAssert(password);
    NSDictionary *userInfo = @{
                               APIKeyEmail: email ?: @"",
                               APIKeyPassword: password ?: @"",
                               };
    [self executeLoginOrRegisterOnPath:UserRegisterPath
                           withDetails:userInfo
                            completion:completion];
}

- (void)loginWithEmailAddress:(NSString *)email
                     password:(NSString *)password
                   completion:(UserInfoCompletionBlock)completion
{
    NSParameterAssert(email);
    NSParameterAssert(password);
    NSDictionary *userInfo = @{
                               APIKeyEmail: email ?: @"",
                               APIKeyPassword: password ?: @"",
                               };
    [self executeLoginOrRegisterOnPath:UserLoginPath
                           withDetails:userInfo
                            completion:completion];
}

- (void)loginOrRegisterFacebookUserID:(NSString *)facebookID
                        facebookToken:(NSString *)facebookToken
                           completion:(UserInfoCompletionBlock)completion
{
    NSParameterAssert(facebookID);
    NSParameterAssert(facebookToken);
    NSDictionary *userInfo = @{
                               APIKeyFacebookID: facebookID ?: @"",
                               APIKeyFacebookToken: facebookToken ?: @"",
                               };
    [self executeLoginOrRegisterOnPath:FacebookLoginRegisterPath
                           withDetails:userInfo
                            completion:completion];
}

- (void)fetchCurrentUserWithCompletion:(UserInfoCompletionBlock)completion
{
    [[HTTPSessionManager sharedManager] GET:CurrentUserFetchPath
                                    parameters:nil
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                               if (completion) {
                                                   completion(responseObject, nil);
                                               }
                                           } else if (completion) {
                                               completion(nil, [self unexpectedResponseTypeErrorForClass:[responseObject class]]);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           if (completion) {
                                               completion(nil, error);
                                           }
                                       }];
}

- (void)resetPasswordForEmail:(NSString *)email
                   completion:(NoResponseNetworkCompletionBlock)completion
{
    NSParameterAssert(email);

    NSDictionary *parameters = @{APIKeyEmail: email ?: @""};

    [[HTTPSessionManager sharedManager] POST:PasswordResetPath
                                     parameters:parameters
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            if (completion) {
                                                completion(nil);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            if (completion) {
                                                completion(error);
                                            }
                                        }];
}

- (void)registerForNotificationsWithDeviceToken:(NSData *)deviceToken
                                     completion:(NoResponseNetworkCompletionBlock)completion
{
    NSParameterAssert(deviceToken);

    // Convert NSData device token to NSString token
    NSString *stringToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    stringToken = [stringToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSDictionary *parameters = @{APIKeyPushNotificationToken: stringToken ?: @""};

    [[HTTPSessionManager sharedManager] POST:NotificationRegisterPath
                                     parameters:parameters
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            if (completion) {
                                                completion(nil);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            if (completion) {
                                                completion(error);
                                            }
                                        }];
}

- (void)getUserWithID:(NSInteger)userID
           completion:(UserInfoCompletionBlock)completion
{
    NSParameterAssert(userID > 0);
    NSString *userFetchPath = [NSString stringWithFormat:SpecificUserFetchPathFormat, @(userID)];

    [[HTTPSessionManager sharedManager] GET:userFetchPath
                                    parameters:nil
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                               if (completion) {
                                                   completion(responseObject, nil);
                                               }
                                           } else if (completion) {
                                               completion(nil, [self unexpectedResponseTypeErrorForClass:[responseObject class]]);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           if (completion) {
                                               completion(nil, error);
                                           }
                                       }];
}

#pragma mark - Private helpers

/**
 * Since the register and login endpoints take (roughly) the same parameters and
 * return the same kind of response, and in both cases the authorization token
 * needs to be saved, this helper method handles both actions by taking the path
 * against which the operation should be executed.
 */
- (void)executeLoginOrRegisterOnPath:(NSString *)path
                         withDetails:(NSDictionary *)loginDetails
                          completion:(UserInfoCompletionBlock)completion
{
    NSParameterAssert(path);
    NSParameterAssert(loginDetails);

    [[HTTPSessionManager sharedManager] POST:path
                                     parameters:loginDetails
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                // Store the authorization token for future API calls
                                                NSString *authorizationToken = responseObject[APIKeyUserAuthToken];
                                                [HTTPSessionManager setAuthorizationToken:authorizationToken];

                                                if (completion) {
                                                    completion(responseObject, nil);
                                                }
                                            } else if (completion) {
                                                completion(nil, [self unexpectedResponseTypeErrorForClass:[responseObject class]]);
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            if (completion) {
                                                completion(nil, error);
                                            }
                                        }];
}

- (NSError *)unexpectedResponseTypeErrorForClass:(Class)class
{
    return [NSError errorWithDomain:NetworkAPIUtilityErrorDomain
                               code:NetworkAPIUtilityErrorCodes.UnexpectedResponseType
                           userInfo:@{NetworkAPIUtilityErrorInfoKeys.ReceivedResponseType: NSStringFromClass(class)}];
}

@end
