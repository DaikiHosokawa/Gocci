//
//  LocationClient.m
//  Gocci
//

#import "LocationClient.h"

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
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        LOG(@"アクティブ時の位置情報の利用不可");
        
        NSError *error = [[NSError alloc] initWithDomain:LocationClientErrorDomain
                                                    code:LocationClientErrorCodeSettingErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey: @"アクティブ時の位置情報の利用不可"}];
        completion(nil, error);
        return;
    }
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
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
    }
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (self.updatedBlock) {
        self.updatedBlock(nil, error);
    }
}

@end
