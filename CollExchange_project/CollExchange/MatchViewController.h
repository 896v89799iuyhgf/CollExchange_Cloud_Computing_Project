//
//  MatchViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDBItemTableRow;
@class DDBUserTableRow;



@interface MatchViewController : UITableViewController



@property (nonatomic, strong) DDBItemTableRow *tableRow;
@property (strong, nonatomic) NSString *searchtype;
@property (strong, nonatomic) NSString *mainusername;
@property (nonatomic, strong) DDBUserTableRow *usertableRow;


@end
