//
//  FriendItemTableViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-16.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendItemTableViewController : UITableViewController
@property (strong, nonatomic) NSString *usernametext;
@property (nonatomic, assign) BOOL needsToRefresh;
@property (strong, nonatomic) NSString *mainusername;


@end
