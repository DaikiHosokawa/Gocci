//
//  APIClient.m
//  Gocci
//

#import "APIClient.h"
#import "AFNetworking.h"

NSString * const APIClientBaseVer2URL = API_BASE_VER2_URL;
NSString * const APIClientErrorDomain = @"APIClientErrorDomain";

NSString * const APIClientResultCacheKeyDist = @"dist";

@interface APIClient()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPSessionManager *manager2;
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
    
    NSURL *baseURL = [NSURL URLWithString:API_BASE_VER2_URL];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    self.manager.responseSerializer =[AFJSONResponseSerializer serializer];
    
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                              @"application/json",
                                                              @"text/html",
                                                              @"text/javascript",
                                                              nil];
    
    NSURL *baseURL2 = [NSURL URLWithString:API_BASE_VER2_URL];
    self.manager2 = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL2];
    NSMutableSet *newAcceptableContentTypes = [NSMutableSet setWithSet:self.manager2.responseSerializer.acceptableContentTypes] ;
    [newAcceptableContentTypes addObject:@"text/html"];
    self.manager2.responseSerializer.acceptableContentTypes = newAcceptableContentTypes;
    self.resultCache = [NSCache new];
    
    return self;
}


#pragma mark - Class Methods



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




+ (void)Near:(CGFloat)latitude longitude:(CGFloat)longitude handler:(void (^)(id, NSUInteger, NSError *))handler useCache:(void (^)(id))cacheHandler
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
                             };
    
    [[APIClient sharedClient].manager GET:@"get/near"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      NSLog(@"task:%@",task);
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

+ (void)POST:(NSString *)movie_name rest_id:(NSString *)rest_id cheer_flag:(NSInteger)cheer_flag value:(NSInteger)value category_id:(NSString *)category_id tag_id:(NSString *)tag_id memo:(NSString *)memo handler:(void (^)(id, NSUInteger, NSError *))handler{
    NSDictionary *params = @{
                             @"rest_id" : rest_id,
                             @"cheer_flag" :@(cheer_flag),
                             @"tag_id" : tag_id,
                             @"value" :@(value),
                             @"category_id" : category_id,
                             @"memo" : memo
                             };
    NSLog(@"params:%@",params);
    [[APIClient sharedClient].manager POST:@"post/post"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
}

    /*
    [[APIClient sharedClient].manager POST:@"movie/"
                                parameters:params
                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                     NSError *error = nil;
                     [formData appendPartWithFileURL:fileURL
                                                name:@"movie"
                                            fileName:[fileURL lastPathComponent]
                                            mimeType:@"video/mp4"
     
                     NSLog(@"pram:%@",params);
                     if (error) LOG(@"error=%@", error);
     
                 } success:^(NSURLSessionDataTask *task, id responseObject) {
                     handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                     handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                 }];
}
*/
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
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"totalBytesWritten:%d totalBytesExpectedToWrite:%d",(int)totalBytesWritten,(int)totalBytesExpectedToWrite );
        float myFloat = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        NSLog(@"Progress:%.2f",myFloat);
    }];
    [downloadTask resume];
}

+ (void)registUserWithUsername:(NSString *)username
                  withPassword:(NSString *)pwd
                     withEmail:(NSString *)email
                  withToken_id:(NSString *)token_id
                       handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"user_name" : username,
                             @"password" : pwd,
                             @"email" : email,
                             @"token_id" : token_id
                             };
    
    NSLog(@"regist_Params: %@", params);
    
    [[APIClient sharedClient].manager POST:@"register/test.php"
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
                 WithToken_id:(NSString *)token_id
                      handler:(void (^)(id result, NSUInteger code, NSError *error))handler
{
    NSDictionary *params = @{
                             @"user_name" :username,
                             @"password" :pwd,
                             @"token_id" :token_id
                             };
    
    
    NSLog(@"login_Params: %@", params);
    
    [[APIClient sharedClient].manager POST:@"auth/test.php"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
}


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
    [[APIClient sharedClient].manager POST:@"post/gochi/"
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
    [[APIClient sharedClient].manager POST:@"post/postdel/"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
    
}

+ (void)postViolation:(NSString *)post_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"post_id" :post_id,
                             };
    
    NSLog(@"paramsgoodinsert:%@",params);
    [[APIClient sharedClient].manager POST:@"violation/"
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
                             @"target_user_id" :target_user_id,
                             };
    
    [[APIClient sharedClient].manager POST:@"post/follow/"
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
                             @"target_user_id" :target_user_id,
                             };
    
    [[APIClient sharedClient].manager POST:@"post/unfollow/"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
    
}

+ (void)restInsert:(NSString *)restName latitude:(CGFloat)latitude longitude:(CGFloat)longitude handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"restname": restName,
                             @"lat": [NSString stringWithFormat:@"%@", @(latitude)],
                             @"lon": [NSString stringWithFormat:@"%@", @(longitude)],
                             };
    [[APIClient sharedClient].manager POST:@"post/restadd/"
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
    [[APIClient sharedClient].manager POST:@"post/comment/"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
}


+ (void)Welcome:(NSString *)identity_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"identity_id" :@"us-east-1:718f0ae6-e859-40b9-b9ab-d624d9374a02",
                             @"sns_flag" :@"1"
                             };
    NSLog(@"Welcome param:%@",params);
    [[APIClient sharedClient].manager GET:@"auth/login/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)SNSSignUp:(NSString *)identity_id profile_img:(NSString *)profile_img handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"identity_id" :identity_id,
                             @"profile_img" :profile_img
                             };
    NSLog(@"SNS param:%@",params);
    [[APIClient sharedClient].manager GET:@"auth/sns/"
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
    
    [[APIClient sharedClient].manager GET:@"get/comment/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)FollowList:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    
    NSDictionary *params = @{
                             @"target_user_id" : target_user_id,
                             };
    
    
    [[APIClient sharedClient].manager GET:@"get/follow/"
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                  }];
}

+ (void)FollowerList:(NSString *)target_user_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"target_user_id" : target_user_id,
                             };
    
    
    [[APIClient sharedClient].manager GET:@"get/follower/"
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

+ (void)Singup:(NSString *)username os:(NSString *)os model:(NSString *)model register_id:(NSString *)register_id handler:(void (^)(id, NSUInteger, NSError *))handler
{
    NSDictionary *params = @{
                             @"username" : username,
                             @"os" : os,
                             @"model" : model,
                             @"register_id" : register_id
                             };
    
    NSLog(@"Signup:%@",params);
    
    [[APIClient sharedClient].manager POST:@"auth/signup/"
                                parameters:params
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       handler(responseObject, [(NSHTTPURLResponse *)task.response statusCode], nil);
                                       NSLog(@"%@",responseObject);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       handler(nil, [(NSHTTPURLResponse *)task.response statusCode], error);
                                   }];
}


@end
