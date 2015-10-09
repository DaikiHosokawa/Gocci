//
//  APIClientTests.m
//  Gocci
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APIClient.h"
#import "TimelinePost.h"

@interface APIClientTests : XCTestCase

@end

@implementation APIClientTests

- (void)testTimeline
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch Timeline"];
    
    
    [APIClient Timeline:^(id result, NSUInteger code, NSError *error) {
        NSLog(@"result=%@", result);
        NSLog(@"code=%@", @(code));
        NSLog(@"error=%@", error);
        
        XCTAssertNotNil(result);
        XCTAssertEqual(code, 200);
        XCTAssertNil(error);
        
        NSArray *posts = (NSArray *)result;
        for (NSDictionary *post in posts) {
            NSLog(@"post=%@", post);
            TimelinePost *obj = [TimelinePost timelinePostWithDictionary:post];
            XCTAssertNotNil(obj.locality);
            XCTAssertNotNil(obj.movie);
            XCTAssertNotNil(obj.picture);
            XCTAssertNotNil(obj.postID);
            XCTAssertNotNil(obj.restname);
            XCTAssertNotNil(obj.thumbnail);
            XCTAssertNotNil(obj.userID);
            XCTAssertNotNil(obj.userName);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
