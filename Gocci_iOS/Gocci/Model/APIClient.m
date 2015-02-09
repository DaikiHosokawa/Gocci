//
//  APIClient.m
//  Gocci
//

#import "APIClient.h"
#import "AFNetworking.h"

NSString * const APIClientBaseURL = API_BASE_URL;
NSString * const APIClientErrorDomain = @"APIClientErrorDomain";

@interface APIClient()
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation APIClient

#pragma mark - Initialize

static APIClient *_sharedInstance = nil;

+ (APIClient *)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [APIClient new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSURL *baseURL = [NSURL URLWithString:APIClientBaseURL];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                              @"application/json",
                                                              @"text/html",
                                                              @"text/javascript",
                                                              nil];
    
    return self;
}


#pragma mark - Class Methods

+ (void)timelineWithLimit:(NSString *)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"limit" : limit,
                             };
    [[APIClient sharedClient].manager GET:@"timeline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)restaurantWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
	
}


+ (void)restaurantWithRestName:(NSString *)restName handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"restname" : restName,
                             };
    
    [[APIClient sharedClient].manager GET:@"restpage/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

/*
+ (void)restaurantWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [[APIClient sharedClient].manager GET:@"timeline"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}
 */

+ (void)profileWithUserName:(NSString *)userName handler:(void (^)(id result, NSUInteger code, NSError *error))handler{
    NSDictionary *params = @{
                             @"user_name" : userName,
                             };
    
    [[APIClient sharedClient].manager GET:@"mypage/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


+ (void)profileWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [[APIClient sharedClient].manager GET:@"timeline"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)profile_otherWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [[APIClient sharedClient].manager GET:@"timeline"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)profile_otherWithUserName:(NSString *)userName handler:(void (^)(id result, NSUInteger code, NSError *error))handler{
    NSDictionary *params = @{
                             @"user_name" : userName,
                             };
    
    [[APIClient sharedClient].manager GET:@"mypage/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)downloadMovieFile:(NSString *)movieURL completion:(void (^)(NSURL *fileURL, NSError *error))handler
{
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:NO
                                                                    error:nil];
    NSURL *saveURL = [directoryURL URLByAppendingPathComponent:[movieURL lastPathComponent]];
    //LOG(@"savePath=%@, exist=%@", [saveURL absoluteString], @([[NSFileManager defaultManager] fileExistsAtPath:[saveURL absoluteString]]));
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[saveURL absoluteString]]) {
        handler(saveURL, nil);
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:movieURL]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return saveURL;
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        handler(filePath, error);
        
    }];
    [downloadTask resume];
}

@end
