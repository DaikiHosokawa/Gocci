//
//  APIClient.m
//  Gocci
//

#import "APIClient.h"
#import "AFNetworking.h"

NSString * const APIClientBaseURL = API_BASE_URL;
NSString * const APIClientErrorDomain = @"APIClientErrorDomain";

NSString * const APIClientResultCacheKeyDist = @"dist";

@interface APIClient()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSCache *resultCache;

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
    self.resultCache = [NSCache new];
    
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

+ (void)distTimelineWithLatitude:(double)latitude longitude:(double)longitude limit:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"lat" : @(latitude),
                             @"lon" : @(longitude),
                             @"limit" : @(limit)
                             };
    
    [[APIClient sharedClient].manager GET:@"dist_timeline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)distTimelineWithLatitudeAll:(double)latitude longitude:(double)longitude limit:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"lat" : @(latitude),
                             @"lon" : @(longitude),
                             @"limit" : @(limit)
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

+ (void)LifelogWithDate:(NSString *)date handler:(void (^)(id result, NSUInteger code, NSError *error))handler{
    NSDictionary *params = @{
                             @"lifelog_date" : date,
                             };
    
    [[APIClient sharedClient].manager GET:@"lifelogs/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


+ (void)LifelogWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
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

+ (void)searchWithRestName:(NSString *)restName latitude:(CGFloat)latitude longitude:(CGFloat)longitude limit:(NSUInteger)limit handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"restname": restName,
                             @"lat": [NSString stringWithFormat:@"%@", @(latitude)],
                             @"lon": [NSString stringWithFormat:@"%@", @(longitude)],
                             @"limit": [NSString stringWithFormat:@"%@", @(limit)],
                             };
    NSLog(@"searchparams:%@",params);
    [[APIClient sharedClient].manager GET:@"search/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)distWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude limit:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [APIClient distWithLatitude:latitude longitude:longitude limit:limit handler:handler useCache:nil];
}

+ (void)distWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude limit:(NSUInteger)limit handler:(void (^)(id result, NSUInteger code, NSError *error))handler useCache:(void (^)(id))cacheHandler
{
    if (cacheHandler != nil) {
        NSDictionary *cachedDictionary = [[APIClient sharedClient].resultCache objectForKey:APIClientResultCacheKeyDist];
        
        if (cachedDictionary) {
            cacheHandler(cachedDictionary);
        } else {
            cacheHandler(nil);
        }
    }
    
    NSDictionary *params = @{
                             @"lat": [NSString stringWithFormat:@"%@", @(latitude)],
                             @"lon": [NSString stringWithFormat:@"%@", @(longitude)],
                             @"limit": [NSString stringWithFormat:@"%@", @(limit)],
                             };
    
    [[APIClient sharedClient].manager GET:@"dist/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      
                                      // 結果をキャッシュ
                                      [[APIClient sharedClient].resultCache setObject:responseObject forKey:APIClientResultCacheKeyDist];
                                      
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                      
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)postRestname:(NSString *)restaurantName handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
    {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@post_restname/", API_BASE_URL]];
        NSString *content = [NSString stringWithFormat:@"restname=%@", restaurantName];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]]; NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            handler([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                    [(NSHTTPURLResponse *)response statusCode],
                    error);
        });
    });
}

+ (void)movieWithFilePathURL:(NSURL *)fileURL restname:(NSString *)restaurantName handler:(void (^)(id, NSUInteger, NSError *))handler{
    NSDictionary *params = @{
                             @"restname" : restaurantName,
                             };
    [[APIClient sharedClient].manager POST:@"movie/"
                                parameters:params
                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                     NSError *error = nil;
                     [formData appendPartWithFileURL:fileURL
                                                name:@"movie"
                                            fileName:[fileURL lastPathComponent]
                                            mimeType:@"video/mp4"
                                               error:&error];
                     if (error) LOG(@"error=%@", error);
                 } success:^(NSURLSessionDataTask *task, id responseObject) {
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

+ (void)registUserWithUsername:(NSString *)username
                  withPassword:(NSString *)pwd
                     withEmail:(NSString *)email
                       handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"user_name" : username,
                             @"password" : pwd,
                             @"email" : email
                             };
    
    NSLog(@"Params: %@", params);
    
    [[APIClient sharedClient].manager POST:@"register/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                      NSLog(@"%@",responseObject);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)loginUserWithUsername:(NSString *)username
                  withPassword:(NSString *)pwd
                       handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"user_name" : username,
                             @"password" : pwd
                             };
    [[APIClient sharedClient].manager POST:@"auth/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


@end
