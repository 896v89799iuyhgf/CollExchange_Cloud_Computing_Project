//
//  MessageTableViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-15.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDBUserTableRow;


@interface MessageTableViewController : UITableViewController
@property (nonatomic, strong) DDBUserTableRow *usertableRow;
@property (nonatomic,strong) NSMutableArray *mess;
@end
