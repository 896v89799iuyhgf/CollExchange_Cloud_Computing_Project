//
//  ItemViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDBUserTableRow;

@interface ItemViewController : UITableViewController
@property (strong, nonatomic) NSString *usernametext;
@property (strong, nonatomic) NSString *passtext;
@property (strong, nonatomic) NSString *emailtext;
@property (strong, nonatomic) NSString *citytext;
@property (strong, nonatomic) NSString *collegetext;
@property (strong, nonatomic) NSString *searchtype;

@property (nonatomic, strong) DDBUserTableRow *usertableRow;


@end



