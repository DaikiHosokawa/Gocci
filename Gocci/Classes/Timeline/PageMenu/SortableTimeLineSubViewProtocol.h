//
//  SortableProtocol.h
//  Gocci
//
//  Created by Ma Wa on 28.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#ifndef SortableProtocol_h
#define SortableProtocol_h

@protocol SortableTimeLineSubView

@required

- (void)sortFunc:(NSString *)category;
- (void)sortValue:(NSString *)value;

- (void)sort:(NSString *)value category:(NSString *)category;

@end


#endif /* SortableProtocol_h */
