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

static NSString *const baselinePath = @"http://127.0.0.1:8000";

static NSString *const allProductsPath = @"/api/inventory";
static NSString *const specifiedProductPath = @"/api/inventory/";
static NSString *const allPurchasePath = @"/api/purchase";
static NSString *const specifiedPurchasePath = @"/api/purchase/";

static NSString *const apiKeyProduct = @"product";

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

//?what does this do?
+ (instancetype)sharedUtility
{
    static NetworkAPIUtility *_sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [NetworkAPIUtility new];
    });
    return _sharedUtility;
}

- (NSURLSessionDataTask *)getStockOfAllProducts:(ProductCompletionBlock)completion
{
    NSString *inventoryEndpoint = [baselinePath stringByAppendingString:allProductsPath];

    NSURLSessionDataTask *inventoryTask = [[HTTPSessionManager sharedManager] GET:inventoryEndpoint
                                                                        //does this need to be products?
                                                                       parameters:nil
                                                                          success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                              NSLog(@"it was a success! I have %@", responseObject);
                                                                              completion(responseObject, nil);
                                                                          }
                                                                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                              NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                              completion(nil, error);
                                                                          }];
    [inventoryTask resume];
    return inventoryTask;
}

- (NSURLSessionDataTask *)getStockOfOneProduct:(NSString *)product withCompletion:(ProductCompletionBlock)completion
{
    NSString *specificInventoryEndpoint = [self baselineStringMaker:specifiedProductPath withSecondString:product];

    NSURLSessionDataTask *specificProductTask = [[HTTPSessionManager sharedManager] GET:specificInventoryEndpoint
                                                                       parameters:nil
                                                                          success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                              NSLog(@"it was a success! I have %@", responseObject);
                                                                              completion(responseObject, nil);
                                                                          }
                                                                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                              NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                              completion(nil, error);
                                                                          }];
    [specificProductTask resume];
    return specificProductTask;
}

- (NSURLSessionDataTask *)addNewProduct:(NSString *)product
                           withQuantity:(NSNumber *)amount
                         withCompletion:(ProductCompletionBlock)completion
{
    NSString *inventoryEndpoint = [baselinePath stringByAppendingString:allProductsPath];
    NSURLSessionDataTask *specifiedProductTask = [[HTTPSessionManager sharedManager] PUT:inventoryEndpoint
                                                                              parameters:@{ @"product_name" : product, @"quantity" : amount }
                                                                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                     completion(responseObject, nil);
                                                                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                     completion(nil, error);
                                                                                 }];
    [specifiedProductTask resume];
    return specifiedProductTask;
}

- (NSURLSessionDataTask *)restockSpecificProduct:(NSString *)product
                                     withQuantity:(NSNumber *)amount
                                   withCompletion:(ProductCompletionBlock)completion
{
    NSString *addSpecificInventoryEndpoint = [self baselineStringMaker:specifiedProductPath withSecondString:product];

    NSURLSessionDataTask *addProductTask = [[HTTPSessionManager sharedManager] PUT:addSpecificInventoryEndpoint
                                                                        parameters:@{ @"product_name" : product, @"quantity" : amount }
                                                                           success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                               NSLog(@"it was a success! I have %@", responseObject);
                                                                               completion(responseObject, nil);
                                                                           }
                                                                           failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                               NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                               completion(nil, error);
                                                                           }];
    [addProductTask resume];
    return addProductTask;
}

- (NSURLSessionDataTask *)restockMultipleProducts:(NSString *)product
                                    withQuantity:(NSString *)amount
                                  withCompletion:(ProductCompletionBlock)completion
{
    NSString *addSpecificInventoryEndpoint = [baselinePath stringByAppendingString:allProductsPath];

    NSURLSessionDataTask *addProductTask = [[HTTPSessionManager sharedManager] PUT:addSpecificInventoryEndpoint
                                                                        parameters:@{ @"product_name" : product, @"quantity" : amount }
                                                                           success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                               NSLog(@"it was a success! I have %@", responseObject);
                                                                               completion(responseObject, nil);
                                                                           }
                                                                           failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                               NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                               completion(nil, error);
                                                                           }];
    [addProductTask resume];
    return addProductTask;
}

- (NSURLSessionDataTask *)removeAllOfASpecificProduct:(NSString *)product withCompletion:(ProductCompletionBlock)completion
{
    NSString *deleteInventoryEndpoint = [self baselineStringMaker:specifiedProductPath withSecondString:product];
    NSURLSessionDataTask *deleteProductTask = [[HTTPSessionManager sharedManager] DELETE:deleteInventoryEndpoint
                                                                                     parameters:nil
                                                                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                            NSLog(@"it was a success! I have %@", responseObject);
                                                                                            completion(responseObject, nil);
                                                                                        }
                                                                                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                            NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                                            completion(nil, error);
                                                                                        }];
    [deleteProductTask resume];
    return deleteProductTask;
}

- (NSURLSessionDataTask *)purchaseSpecificProduct:(NSString *)product
                                     withQuantity:(NSNumber *)amount
                                   withCompletion:(ProductCompletionBlock)completion
{
    NSString *purchaseOneProductEndpoint = [self baselineStringMaker:specifiedPurchasePath withSecondString:product];

    NSURLSessionDataTask *purchaseOneProductTask = [[HTTPSessionManager sharedManager] PUT:purchaseOneProductEndpoint
                                                                                parameters:@{ @"product_name" : product, @"quantity" : amount }
                                                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                       NSLog(@"it was a success! I have %@", responseObject);
                                                                                       completion(responseObject, nil);
                                                                                   }
                                                                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                       NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                                       completion(nil, error);
                                                                                   }];
    [purchaseOneProductTask resume];
    return purchaseOneProductTask;
}

- (NSURLSessionDataTask *)purchaseMultipleProducts:(NSString *)product
                                      withQuantity:(NSString *)amount
                                    withCompletion:(ProductCompletionBlock)completion
{
    NSString *purchaseMultipleProductsEndpoint = [baselinePath stringByAppendingString:allPurchasePath];

    NSURLSessionDataTask *purchaseMultipleProductsTask = [[HTTPSessionManager sharedManager] PUT:purchaseMultipleProductsEndpoint
                                                                                parameters:@{ @"product_name" : product, @"quantity" : amount }
                                                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                       NSLog(@"it was a success! I have %@", responseObject);
                                                                                       completion(responseObject, nil);
                                                                                   }
                                                                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                       NSLog(@"I'm so sorry, I couldn't get the inventory for a reason. Check out this %@", error);
                                                                                       completion(nil, error);
                                                                                   }];
    [purchaseMultipleProductsTask resume];
    return purchaseMultipleProductsTask;

    return nil;
}


//user action always starts with verb
#pragma mark - "helper methods"

- (NSString *)baselineStringMaker:(NSString *)string withSecondString:(NSString *)secondString
{
    NSString *baselineEndpoint = [baselinePath stringByAppendingString:string];
    NSString *endpoint = [baselineEndpoint stringByAppendingString:secondString];
        return endpoint;

}
//the only difference between the two is the path that is used.
/*
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
*/
#pragma mark - Private helpers

/**
 * Since the register and login endpoints take (roughly) the same parameters and
 * return the same kind of response, and in both cases the authorization token
 * needs to be saved, this helper method handles both actions by taking the path
 * against which the operation should be executed.

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
*/
//?what does this do?
//- (NSError *)unexpectedResponseTypeErrorForClass:(Class)class
//{
//    return [NSError errorWithDomain:NetworkAPIUtilityErrorDomain
//                               code:NetworkAPIUtilityErrorCodes.UnexpectedResponseType
//                           userInfo:@{NetworkAPIUtilityErrorInfoKeys.ReceivedResponseType: NSStringFromClass(class)}];
//}

@end
