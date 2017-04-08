//
//  LocationClient.m
//  Gocci
//

#import "LocationClient.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

NSString * const LocationClientErrorDomain = @"LocationClientErrorDomain";

@interface LocationClient()
<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) LocationClientUpdatedBlock updatedBlock;
@property (nonatomic, strong) CLLocation *cachedLocation;

@end

@implementation LocationClient

static LocationClient *_sharedInstance = nil;

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [LocationClient new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    self.cachedLocation = nil;
    
    return self;
}

- (void)requestLocationWithCompletion:(void (^)(CLLocation *, NSError *))completion
{
    if (completion == nil) {
        completion = ^(CLLocation *l, NSError *e) {};
    }
    
    if (![CLLocationManager locationServicesEnabled]) {
        LOG(@"位置情報使用不可");
        
        NSError *error = [[NSError alloc] initWithDomain:LocationClientErrorDomain
                                                    code:LocationClientErrorCodeSettingErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey: @"位置情報使用不可"}];
        
        
        completion(nil, error);
        //progress dismiss
        [SVProgressHUD dismiss];
    
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        LOG(@"位置情報サービス利用不可 (iPhone の位置情報サービスの設定を確認してください)");
        
        NSError *error = [[NSError alloc] initWithDomain:LocationClientErrorDomain
                                                    code:LocationClientErrorCodeSettingErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey: @"位置情報サービス利用不可 (iPhone の位置情報サービスの設定を確認してください)"}];
        
        completion(nil, error);
        //progress dismiss
        [SVProgressHUD dismiss];
        return;
    }
    
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // 既に待機中の Blocks がある場合はエラーを返す
    if (self.updatedBlock) {
        NSError *interruptedError = [[NSError alloc] initWithDomain:LocationClientErrorDomain
                                                               code:LocationClientErrorCodeInterrupted
                                                           userInfo:@{NSLocalizedDescriptionKey: @"処理が中断されました"}];
        self.updatedBlock(nil, interruptedError);
        self.updatedBlock = nil;
    }
    self.updatedBlock = completion;
    
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    LOG(@"status=%d", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    self.cachedLocation = location;
    
    if (self.updatedBlock) {
        self.updatedBlock(location, nil);
        self.updatedBlock = nil;
    }
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (self.updatedBlock) {
        self.updatedBlock(nil, error);
        self.updatedBlock = nil;
    }
}

@end
