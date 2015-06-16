//
//  NetworkAPIUtility.h
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Completion block definitions

/// Completion block for register and login actions. userInfo is set on success, nil on failure.
typedef void(^UserInfoCompletionBlock)(NSDictionary *userInfo, NSError *error);

/// Completion block for API endpoints that don't return any response body.
typedef void(^NoResponseNetworkCompletionBlock)(NSError *error);

#pragma mark - Constants for errors

FOUNDATION_EXPORT NSString *const NetworkAPIUtilityErrorDomain;

FOUNDATION_EXPORT const struct NetworkAPIUtilityErrorCodes
{
    NSInteger UnexpectedResponseType;
} NetworkAPIUtilityErrorCodes;

FOUNDATION_EXPORT const struct NetworkAPIUtilityErrorInfoKeys
{
    __unsafe_unretained NSString *ReceivedResponseType;
} NetworkAPIUtilityErrorInfoKeys;

#pragma mark - Class header

@interface NetworkAPIUtility : NSObject

+ (instancetype)sharedUtility;

- (void)registerWithEmailAddress:(NSString *)email
                        password:(NSString *)password
                      completion:(UserInfoCompletionBlock)completion;

- (void)loginWithEmailAddress:(NSString *)email
                     password:(NSString *)password
                   completion:(UserInfoCompletionBlock)completion;

- (void)loginOrRegisterFacebookUserID:(NSString *)facebookID
                        facebookToken:(NSString *)facebookToken
                           completion:(UserInfoCompletionBlock)completion;

- (void)fetchCurrentUserWithCompletion:(UserInfoCompletionBlock)completion;

- (void)resetPasswordForEmail:(NSString *)email
                   completion:(NoResponseNetworkCompletionBlock)completion;

- (void)registerForNotificationsWithDeviceToken:(NSData *)deviceToken
                                     completion:(NoResponseNetworkCompletionBlock)completion;

- (void)getUserWithID:(NSInteger)userID
           completion:(UserInfoCompletionBlock)completion;

@end
