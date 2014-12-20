//
//  PersonViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDBUserTableRow;

@interface PersonViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *user;
@property (strong, nonatomic) NSString *usernametext;
@property (strong, nonatomic) NSString *passtext;
@property (strong, nonatomic) NSString *emailtext;
@property (strong, nonatomic) NSString *citytext;
@property (strong, nonatomic) NSString *collegetext;
@property (strong, nonatomic) IBOutlet UITextField *searchtext;

@property (nonatomic, strong) DDBUserTableRow *usertableRow;


- (IBAction)postanitem:(id)sender;
- (IBAction)edititems:(id)sender;
- (IBAction)findexchange:(id)sender;
- (IBAction)message:(id)sender;
- (IBAction)following:(id)sender;


@end
