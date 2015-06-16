//
//  HTTPSessionManager.m
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

// Un-comment this line to see full network traffic logging for debugging
// #define USE_NETWORKING_DEBUG_LOGGING 1

#import "HTTPSessionManager.h"

/**
 * TODO: replace these URLs with the actual staging and production API URLs.
 * Note that this method uses staging for debug builds, and production for
 * everything else. You should modify this if that's not what you want for your
 * app.
 * The URLs should NOT include the trailing slash, but may include subpaths. For
 * example, this would be a valid value:
 *   https://api-staging.example.com/api
 */
#ifdef DEBUG
    // Staging API
    static NSString *const APIBaseURL = @"https://api-staging.example.com";
#else
    // Production API
    static NSString *const APIBaseURL = @"https://api.example.com";
#endif

@implementation HTTPSessionManager

static HTTPSessionManager *_sharedManager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self resetSharedManagerWithSessionConfiguration:nil];
    });
    return _sharedManager;
}

+ (void)setAuthorizationToken:(NSString *)authToken
{
    NSDictionary *additionalHeaders;
    if (authToken) {
        additionalHeaders = @{@"Authorization": authToken};
    }
    HTTPSessionManager *sessionManager = [self sharedManager];
    sessionManager.session.configuration.HTTPAdditionalHeaders = additionalHeaders;
}

+ (void)resetSharedManagerWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration
{
    _sharedManager = [[HTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURL]
                                               sessionConfiguration:sessionConfiguration];
    _sharedManager.requestSerializer = [AFJSONRequestSerializer serializer];
}

// Override the data task completion handler to add debug logging
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
#ifdef USE_NETWORKING_DEBUG_LOGGING
                        // Debug logging
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        DLog(@"Response:\nCode %@ %@ %@\nRequest body:\n%@\nResponse body:\n%@\nError: %@",
                             @(httpResponse.statusCode),
                             request.HTTPMethod,
                             request.URL.absoluteString,
                             [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding],
                             responseObject,
                             error);
#endif

                        if (completionHandler) {
                            completionHandler(response, responseObject, error);
                        }
                    }];
}

@end
