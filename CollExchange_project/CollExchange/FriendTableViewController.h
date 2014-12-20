//
//  FriendTableViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-16.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDBUserTableRow;


@interface FriendTableViewController : UITableViewController
@property (nonatomic, strong) DDBUserTableRow *usertableRow;
@property (nonatomic,strong) NSMutableArray *fri;
@property (strong, nonatomic) NSString *mainusername;

@end
