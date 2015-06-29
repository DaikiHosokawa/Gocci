// TODO: We need valid licensing information.

#import <Foundation/Foundation.h>

// TODO: We need to finalize the name of the entry point.
@interface FabricAWSiOSSDKKitEntryPoint : NSObject

/**
 Returns the current version of the Kit that is being used at runtime.
 */
+ (NSString *)kitDisplayVersion;

/**
 The globally unique identifier of the Kit.
 */
+ (NSString *)bundleIdentifier;

/**
 Performs any necessary initialization using the info.plist. When valid values are not provided in info.plist, this method does not initialize the default credentials provider and service configuration.
 This method will be invoked on the Kit when the user calls +[Fabric initializeKits].
 */
+ (void)initializeIfNeeded;

@end
