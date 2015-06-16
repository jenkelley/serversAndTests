//
//  HTTPSessionManager.h
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "AFNetworking.h"

@interface HTTPSessionManager : AFHTTPSessionManager

/**
 * Get the singleton object that's used for by VOKNetworkAPIUtility
 *
 * @return Shared manager object
 */
+ (instancetype)sharedManager;

/**
 * Update the authorization token that's included with all network calls. Pass
 * nil when the user logs out, to clear the token.
 *
 * @param authToken New auth token, or nil on logout
 */
+ (void)setAuthorizationToken:(NSString *)authToken;

/**
 * Replace the sharedManager with a new copy that uses the given session
 * configuration. Pass nil to use the default session configuration.
 *
 * @param sessionConfiguration New session configuration, or nil for default
 */
+ (void)resetSharedManagerWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration;

@end
