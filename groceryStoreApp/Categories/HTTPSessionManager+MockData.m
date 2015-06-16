//
//  HTTPSessionManager+MockData.m
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "HTTPSessionManager+MockData.h"

#import "VOKMockUrlProtocol.h"

@implementation HTTPSessionManager (MockData)

+ (void)switchToMockData
{
    NSURLSessionConfiguration *sessionConfiguration = [HTTPSessionManager sharedManager].session.configuration;

    Class mockURLProtocol = [VOKMockUrlProtocol class];
    NSMutableArray *currentProtocolClasses = [sessionConfiguration.protocolClasses mutableCopy];
    [currentProtocolClasses insertObject:mockURLProtocol atIndex:0];
    sessionConfiguration.protocolClasses = currentProtocolClasses;

    [HTTPSessionManager resetSharedManagerWithSessionConfiguration:sessionConfiguration];
}

+ (void)switchToLiveNetwork
{
    NSURLSessionConfiguration *sessionConfiguration = [HTTPSessionManager sharedManager].session.configuration;

    Class mockURLProtocol = [VOKMockUrlProtocol class];
    NSMutableArray *currentProtocolClasses = [sessionConfiguration.protocolClasses mutableCopy];
    [currentProtocolClasses removeObject:mockURLProtocol];
    sessionConfiguration.protocolClasses = currentProtocolClasses;

    [HTTPSessionManager resetSharedManagerWithSessionConfiguration:sessionConfiguration];
}

@end
