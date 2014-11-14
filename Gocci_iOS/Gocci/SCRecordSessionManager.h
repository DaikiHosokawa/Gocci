//
//  SCRecordSessionManager.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRecorder.h"

@interface SCRecordSessionManager : NSObject

- (void)saveRecordSession:(SCRecordSession *)recordSession;

- (void)removeRecordSession:(SCRecordSession *)recordSession;

- (BOOL)isSaved:(SCRecordSession *)recordSession;

- (void)removeRecordSessionAtIndex:(NSInteger)index;

- (NSArray *)savedRecordSessions;

+ (SCRecordSessionManager *)sharedInstance;

@end
