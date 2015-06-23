//
//  groceryStoreAppTests.m
//  groceryStoreAppTests
//
//  Created by Jen Kelley on 6/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HTTPSessionManager+MockData.h"
#import "NetworkAPIUtility.h"

@interface groceryStoreAppTests : XCTestCase

@property NSNumber *beerQuantity;
@property NSDictionary *productDictionary;

@end

@implementation groceryStoreAppTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetStockOfAllProducts
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"I have all the products!"];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing getStockOfAllProducts:^(NSDictionary *produts, NSError *error) {
        XCTAssertTrue(produts.count >= 0, @"there isn't a negative count");
        XCTAssertGreaterThanOrEqual([produts valueForKey:@"beer"], [NSNumber numberWithInt:0], @"you have negative stuff?");
        XCTAssertNotEqualObjects([[produts valueForKey:@"worm"] class], [NSNumber class], @"number isn't a number?");

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testGetStockOfSpecificProduct
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"I have beer!"];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing getStockOfOneProduct:@"beer" withCompletion:^(NSDictionary *produts, NSError *error) {

        //check if stock name matches product that comes back
        NSArray *dictArray = [produts allKeys];
        XCTAssertEqualObjects(dictArray[0], @"beer", @"this thing isn't beer");
        //make sure dictionary has one item
        XCTAssertEqual(produts.count, 1, @"well, there is more than one thing in the dictionary");
        //make sure there is a value for each key and value field
        XCTAssertNotNil([produts valueForKey:@"beer"], @"apparently you have nil beer");
        self.beerQuantity = [produts valueForKey:@"beer"];
        NSLog(@"%@", self.beerQuantity);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];

}

- (void)testGetSpecificProductNotInInventory
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing getStockOfOneProduct:@"dog" withCompletion:^(NSDictionary *produts, NSError *error) {

        //make sure we get a 404 error
        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: not found (404)");
        XCTAssertNil(produts);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];

}

- (void)testRestockOneProduct
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing restockSpecificProduct:@"beer" withQuantity:@20 withCompletion:^(NSDictionary *produts, NSError *error) {

        NSArray *dictArray = [produts allKeys];
        XCTAssertNotNil(produts, @"dictionary is nil!");
        XCTAssertEqualObjects(dictArray[0], @"beer", @"this thing isn't beer");
        XCTAssertEqual(produts.count, 1, @"well, there is more than one thing in the dictionary");
        //this verifies that quantity was actually added to the server
        NSNumber *finalBeer = [produts objectForKey:@"beer"];
        int initialBeerInt = [self.beerQuantity intValue];
        int initialPlusQuantity = initialBeerInt + 20;
        XCTAssertTrue(finalBeer = [NSNumber numberWithInt:initialPlusQuantity]);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRestockMultipleProducts
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing restockMultipleProducts:@"beer, worm" withQuantity:@"40, 10" withCompletion:^(NSDictionary *produts, NSError *error) {

        NSArray *dictArray = [produts allKeys];
        XCTAssertNotNil(produts, @"dictionary is nil!");
        XCTAssertEqualObjects(dictArray[1], @"beer", @"this thing isn't beer");
        XCTAssertTrue(produts.count > 1);
        //this verifies that quantity was actually added to the server
        NSNumber *finalBeer = [produts objectForKey:@"beer"];
        int initialBeerInt = [self.beerQuantity intValue];
        int initialPlusQuantity = initialBeerInt + 40;
        XCTAssertTrue(finalBeer = [NSNumber numberWithInt:initialPlusQuantity]);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testPutNegativeNumber
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing restockSpecificProduct:@"beer" withQuantity:@(-19) withCompletion:^(NSDictionary *produts, NSError *error) {

        //TODO: make this an actual status code test with error.
        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: bad request (400)");
        XCTAssertNil(produts);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
    
}

- (void)testRestockFailure
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing restockSpecificProduct:@"cake" withQuantity:@9999 withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: not found (404)");
        XCTAssertNil(produts);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testSuccessfulRemoveOneProduct
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing removeAllOfASpecificProduct:@"earth" withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertNil(produts);
        //need to add this because if the product has already been removed it'll throw an error
        XCTAssertNil(error);


        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testFailedRemoveOneProduct
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing removeAllOfASpecificProduct:@"internet" withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: not found (404)");
        XCTAssertNil(produts);
        XCTAssertNotNil(error);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testPurchaseOneProduct
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing purchaseSpecificProduct:@"beer" withQuantity:@100 withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertTrue(produts.count == 1);
        NSArray *keyArray = [produts allKeys];
        XCTAssertEqualObjects(keyArray[0], @"beer");
        NSNumber *finalBeer = [produts objectForKey:@"beer"];
        int initialBeerInt = [self.beerQuantity intValue];
        int initialPlusQuantity = initialBeerInt - 100;
        XCTAssertTrue(finalBeer = [NSNumber numberWithInt:initialPlusQuantity]);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

//this could be two tests, one that tests the product and the other that tests the quantity
- (void)testFailedPurchaseOneProductNotInInventory
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing purchaseSpecificProduct:@"internet" withQuantity:@0 withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: not found (404)");
        XCTAssertNil(produts);


        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testFailedPurchaseOneProductWithNegativeQuantity
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing purchaseSpecificProduct:@"beer" withQuantity:@(-10) withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: bad request (400)");
        XCTAssertNil(produts);

        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testPurchaseMultipleProducts
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing purchaseMultipleProducts:@"worm, beer" withQuantity:@"2, 3" withCompletion:^(NSDictionary *produts, NSError *error) {

        NSArray *dictArray = [produts allKeys];
        XCTAssertNotNil(produts, @"dictionary is nil!");
        XCTAssertEqualObjects(dictArray[0], @"worm", @"this thing isn't worms");
        XCTAssertTrue(produts.count > 1);
        //this verifies that quantity was actually added to the server
        NSNumber *finalBeer = [produts objectForKey:@"beer"];
        int initialBeerInt = [self.beerQuantity intValue];
        int initialPlusQuantity = initialBeerInt - 100;
        XCTAssertTrue(finalBeer = [NSNumber numberWithInt:initialPlusQuantity]);

        //this needs to have tests that test error states. 400 and 404 errors should return a string. 404 error should contain the product that's not available.

        NSLog(@"%@", produts);


        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testPurchaseMultipleProductsFailedBecauseNotEnoughInStock
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NetworkAPIUtility *thing = [NetworkAPIUtility sharedUtility];
    [thing purchaseMultipleProducts:@"beer" withQuantity:@"10000" withCompletion:^(NSDictionary *produts, NSError *error) {

        XCTAssertEqualObjects(error.localizedDescription, @"Request failed: bad request (400)");
        XCTAssertNil(produts);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}
@end
