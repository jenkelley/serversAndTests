//
//  HTTPSessionManager+MockData.h
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "HTTPSessionManager.h"

/**
 * Interface to provide methods for turning mock data on and off, using VOKMockUrlProtocol.
 *
 * Before this category can be used, you must do the following:
 *
 *   1. Add the VOKMockUrlProtocol pod to your Podfile. This only needs to be in
 *      the testing target(s).
 *   2. Add HTTPSessionManager+MockData.m to your testing target(s). By default,
 *      it's not included in any targets: because VOKMockUrlProtocol is not
 *      included in the project template, this category would fail to build.
 *   3. In your tests, call switchToMockData in setup/beforeAll, and
 *      switchToLiveNetwork in teardown/afterAll to set it back.
 */
@interface HTTPSessionManager (MockData)

/**
 * Replace the sharedManager with a new version that makes use of
 * VOKMockUrlProtocol to provide data.
 */
+ (void)switchToMockData;

/**
 * Replace the sharedManager with a new version that makes does not include
 * VOKMockUrlProtocol in the protocol classes, so that all subsequent requests
 * are made against the live server.
 */
+ (void)switchToLiveNetwork;

@end
