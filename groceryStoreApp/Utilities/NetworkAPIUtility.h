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
typedef void(^ProductCompletionBlock)(NSDictionary *produts, NSError *error);

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

- (NSURLSessionDataTask *)getStockOfAllProducts:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)getStockOfOneProduct:(NSString *)product withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)restockSpecificProduct:(NSString *)product withQuantity:(NSNumber *)amount withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)restockMultipleProducts:(NSString *)product withQuantity:(NSString *)amount withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)removeAllOfASpecificProduct:(NSString *)product withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)purchaseSpecificProduct:(NSString *)product withQuantity:(NSNumber *)amount withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)purchaseMultipleProducts:(NSString *)product withQuantity:(NSString *)amount withCompletion:(ProductCompletionBlock)completion;
- (NSURLSessionDataTask *)addNewProduct:(NSString *)product withQuantity:(NSNumber *)amount withCompletion:(ProductCompletionBlock)completion;


@end
