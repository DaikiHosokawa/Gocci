//
//  APIClient.m
//  Gocci
//

#import "const.h"
#import "APIClient.h"
#import "AFNetworking.h"

#import "Swift.h"

NSString * const APIClientResultCacheKeyDist = @"dist";

@interface APIClient()

//@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) ReAuthFilterHack *manager;
@property (nonatomic, strong) ReAuthFilterHack *manager_v4;

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

+ (id)getManager {
    return [APIClient sharedClient].manager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSURL *baseURL = [NSURL URLWithString:API_BASE_URL];
    self.manager = [[ReAuthFilterHack alloc] initWithBaseURL:baseURL];

    NSURL *baseURL_v4 = [NSURL URLWithString:API_BASE_URL_V4];
    self.manager_v4 = [[ReAuthFilterHack alloc] initWithBaseURL:baseURL_v4];
//    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
//    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
//                                                              @"application/json",
//                                                              @"text/html",
//                                                              @"text/javascript",
//                                                              nil];
    
    return self;
}


#pragma mark - Class Methods

+ (void)Signup:(NSString *)username os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"username" : username,
                             @"os" : os,
                             @"model" : model,
                             @"register_id" : register_id
                             };
    
    [[APIClient sharedClient].manager GET:@"auth/signup/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)connectWithSNS:(NSString *)provider
                 token:(NSString *)token
     profilePictureURL:(NSString *)ppurl
               handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"provider" : provider,
                             @"token" : token,
                             @"profile_img" : ppurl,
                             };
    NSLog(@"SNS connectWithSNS param:%@",params);
    
    [[APIClient sharedClient].manager GET:@"post/sns/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)disconnectWithSNS:(NSString *)provider
                 token:(NSString *)token
               handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"provider" : provider,
                             @"token" : token,
                             };
    NSLog(@"SNS connectWithSNS param:%@",params);
    
    [[APIClient sharedClient].manager GET:@"post/sns_unlink/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)Timeline:(void (^)(id, NSUInteger, NSError *))handler
{
    
    [[APIClient sharedClient].manager GET:@"get/timeline/"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)Distance:(double)latitude longitude:(double)longitude call:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id  handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"call" : call,
                             @"category_id" : category_id,
                             @"value_id" : value_id,
                             @"order_id" : @"1",
                             @"lat" :  [NSString stringWithFormat:@"%@", @(latitude)],
                             @"lon" :  [NSString stringWithFormat:@"%@", @(longitude)],
                             };
    NSLog(@"Distance:%@",params);
    [[APIClient sharedClient].manager GET:@"get/timeline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)Reco:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id  handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"call" : call,
                             @"category_id" : category_id,
                             @"value_id" : value_id,
                             @"order_id" : @"0"
                             };
    NSLog(@"Reco:%@",params);
    [[APIClient sharedClient].manager GET:@"get/timeline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)Follow:(NSString *)call category_id:(NSString *)category_id value_id:(NSString *)value_id  handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"call" : call,
                             @"category_id" : category_id,
                             @"value_id" : value_id,
                             @"order_id" : @"0"
                             };
    NSLog(@"Distance:%@",params);
    [[APIClient sharedClient].manager GET:@"get/followline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)Popular:(void (^)(id, NSUInteger, NSError *))handler
{
    
    [[APIClient sharedClient].manager GET:@"get/popular"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)Restaurant:(NSString *)rest_id handler:(void (^)(id, NSUInteger, NSError *))handler

{
    NSDictionary *params = @{
                             @"rest_id" : rest_id,
                             };
    
    [[APIClient sharedClient].manager GET:@"get/rest/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


+ (void)LifelogWithHandler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [[APIClient sharedClient].manager GET:@"lifelogs"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)User:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"target_user_id" : target_user_id,
                             };
    
    
    [[APIClient sharedClient].manager GET:@"get/user/"
                               parameters:params
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




+ (void)searchWithRestName:(NSString *)restName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude limit:(NSUInteger)limit handler:(void (^)(id, NSUInteger, NSError *))handler
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




+ (void)Near:(double)latitude longitude:(double)longitude handler:(void (^)(id, NSUInteger, NSError *))handler
{
    
    
    NSDictionary *params = @{
                             @"lat": [NSString stringWithFormat:@"%@", @(latitude)],
                             @"lon": [NSString stringWithFormat:@"%@", @(longitude)],
                             };
    
    NSLog(@"param:%@",params);
    
    [[APIClient sharedClient].manager GET:@"get/near"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)POST:(NSString *)movie_name rest_id:(NSString *)rest_id cheer_flag:(NSString*)cheer_flag value:(NSString *)value category_id:(NSString *)category_id tag_id:(NSString *)tag_id memo:(NSString *)memo handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"movie_name" : movie_name,
                             @"rest_id" : rest_id,
                             @"cheer_flag" :cheer_flag,
                             @"tag_id" : @"1",
                             @"value" :value,
                             @"category_id" : category_id,
                             @"memo" : memo
                             };
    NSLog(@"POST:%@",params);
    [[APIClient sharedClient].manager GET:@"post/post"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


//+ (void)downloadMovieFile:(NSString *)movieURL completion:(void (^)(NSURL *fileURL, NSError *error))handler
//{
//    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
//                                                                 inDomain:NSUserDomainMask
//                                                        appropriateForURL:nil
//                                                                   create:NO
//                                                                    error:nil];
//    NSURL *saveURL = [directoryURL URLByAppendingPathComponent:[movieURL lastPathComponent]];
//    //LOG(@"savePath=%@, exist=%@", [saveURL absoluteString], @([[NSFileManager defaultManager] fileExistsAtPath:[saveURL absoluteString]]));
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[saveURL absoluteString]]) {
//        handler(saveURL, nil);
//        return;
//    }
//    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:movieURL]];
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        return saveURL;
//        
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        handler(filePath, error);
//        
//    }];
//    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        NSLog(@"totalBytesWritten:%d totalBytesExpectedToWrite:%d",(int)totalBytesWritten,(int)totalBytesExpectedToWrite );
//        float myFloat = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
//        NSLog(@"Progress:%.2f",myFloat);
//    }];
//    [downloadTask resume];
//}



+ (void)Notice:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    [[APIClient sharedClient].manager GET:@"get/notice/"
                               parameters:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)postGood:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"paramsgoodinsert:%@",params);
    [[APIClient sharedClient].manager GET:@"post/gochi/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)set_gochi:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"paramsgoodinsert:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"set/gochi/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)unset_gochi:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"paramsgoodinsert:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"unset/gochi/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)Gochi:(NSString *)page category_id:(NSString *)category_id value_id:(NSString *)value_id  handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"page" : page,
                             @"category_id" : category_id,
                             @"value_id" : value_id
                             };
    NSLog(@"Gochi:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"get/gochiline/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)postDelete:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"paramsgoodinsert:%@",params);
    [[APIClient sharedClient].manager GET:@"post/postdel/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)postBlock:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"postblock params:%@",params);
    [[APIClient sharedClient].manager GET:@"post/postblock/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)postFollow:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"user_id" :target_user_id,
                             };
    NSLog(@"follow param:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"set/follow/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)postUnFollow:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"user_id" :target_user_id,
                             };
    NSLog(@"unfollow param:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"unset/follow/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}


+ (void)postComment:(NSString *)text post_id:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"comment": text,
                             @"post_id": post_id,
                             };
    [[APIClient sharedClient].manager GET:@"post/comment/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


+ (void)Login:(NSString *)identity_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"identity_id" :identity_id,
                             };
    NSLog(@"Login param:%@",params);
    [[APIClient sharedClient].manager GET:@"auth/login/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}


+ (void)loginWithUsername:(NSString *)username password:(NSString*)pass os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"username" :username,
                             @"pass" :pass,
                             @"os" : os,
                             @"model" : model,
                             @"register_id" : register_id
                             };
    NSLog(@"SNS Login param:%@",params);
    [[APIClient sharedClient].manager GET:@"auth/pass_login/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}




+ (void)setPassword:(NSString *)pass handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"pass": pass
                             };
    NSLog(@"SNS setPassword:%@",params);
    [[APIClient sharedClient].manager GET:@"post/password/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)postFeedback:(NSString *)feedback handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"feedback": feedback
                             };
    NSLog(@"SNS setPassword:%@",params);
    [[APIClient sharedClient].manager GET:@"post/feedback/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)loginWithSNS:(NSString *)identity_id os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"identity_id" :identity_id,
                             @"os" : os,
                             @"model" : model,
                             @"register_id" : register_id
                             };
    NSLog(@"SNS Login param:%@",params);
    [[APIClient sharedClient].manager GET:@"auth/sns_login/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)commentJSON:(NSString *)post_id handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"post_id" : post_id,
                             };
    NSLog(@"commentJsonParam:%@",params);
    [[APIClient sharedClient].manager GET:@"get/comment/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)Follow:(NSString *)user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    
    NSDictionary *params = @{
                             @"user_id" : user_id,
                             };
    
    NSLog(@"FollowList pram:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"get/follow/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)Follower:(NSString *)user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"user_id" : user_id,
                             };
    
    NSLog(@"FollowerList pram:%@",params);
    [[APIClient sharedClient].manager_v4 GET:@"get/follower/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)CheerList:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"target_user_id" : target_user_id,
                             };
    
    
    [[APIClient sharedClient].manager GET:@"get/user_cheer/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}



+ (void)Conversion:(NSString *)username profile_img:(NSString *)profile_img os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"username" : username,
                             @"profile_img" : profile_img,
                             @"os" : os,
                             @"model" : model,
                             @"register_id" : register_id
                             };
    
    NSLog(@"Conversion:%@",params);
    
    [[APIClient sharedClient].manager GET:@"auth/conversion/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                      NSLog(@"%@",responseObject);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)postWant:(NSString *)rest_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"rest_id" :rest_id,
                             };
    NSLog(@"Want param:%@",params);
    [[APIClient sharedClient].manager GET:@"post/want/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)postUnWant:(NSString *)rest_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"rest_id" :rest_id,
                             };
    NSLog(@"Want param:%@",params);
    [[APIClient sharedClient].manager GET:@"post/unwant/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}


+ (void)updateProfileBoth:(NSString *)username profile_img:(NSString *)profile_img handler:(void (^)(id, NSUInteger, NSError *))handler
{
    
    NSDictionary *  params = @{
                   @"username" :username,
                   @"profile_img" : profile_img
                   };
    
    NSLog(@"follow param:%@",params);
    [[APIClient sharedClient].manager GET:@"post/update_profile/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}

+ (void)updateProfileOnlyUsername:(NSString *)username  handler:(void (^)(id, NSUInteger, NSError *))handler
{
    
    NSDictionary *  params = @{
                               @"username" :username
                               };
    
    NSLog(@"follow param:%@",params);
    [[APIClient sharedClient].manager GET:@"post/update_profile/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
    
}


@end
