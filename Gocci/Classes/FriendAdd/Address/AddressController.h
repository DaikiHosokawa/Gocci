//
//  AddressController.h
//  Gocci
//
//  Created by Castela on 2015/10/08.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@class AddressController;

@protocol AddressControllerDelegate <NSObject>

@end

@interface AddressController : UITableViewController<CNContactPickerDelegate>

@property(nonatomic,strong) id<AddressControllerDelegate> delegate;

@end
