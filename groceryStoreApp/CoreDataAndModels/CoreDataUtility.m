//
//  CoreDataUtility.m
//  groceryStoreApp
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "CoreDataUtility.h"

#import "VOKCoreDataManager.h"

@implementation CoreDataUtility

+ (void)setupCoreDataForTesting
{
    [self setupCoreDataWithDatabaseName:nil];
}

+ (void)setupCoreData
{
    [self setupCoreDataWithDatabaseName:@"groceryStoreApp.sqlite"];
}

+ (void)nukeAndResetCoreData
{
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [self setupCoreData];
}

+ (void)nukeAndResetCoreDataForTesting
{
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [self setupCoreDataForTesting];
}

+ (void)setupCoreDataWithDatabaseName:(NSString *)databaseName
{
    //Setup Core Data Stack
    [self setupCoreDataStackWithDatabaseName:databaseName];

    //Setup Object Mappers
    [self setupObjectMappers];
}

+ (void)setupCoreDataStackWithDatabaseName:(NSString *)databaseName
{
    //Model Setup
    [[VOKCoreDataManager sharedInstance] setResource:@"groceryStoreApp" database:databaseName];

    //Fire Up Context
    [[VOKCoreDataManager sharedInstance] managedObjectContext];
}

#pragma mark - Mappers

+ (void)setupObjectMappers
{
    //TODO:Fire Off Your Mapper Methods Here
}

@end
