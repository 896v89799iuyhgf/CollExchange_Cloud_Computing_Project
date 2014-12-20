//
//  MessageViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-15.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DDBUserTableRow;

@interface MessageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *messagetext;
@property (strong, nonatomic) IBOutlet UIButton *submitbutton;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) DDBUserTableRow *usertableRow;
@property (strong, nonatomic) NSString *mainusername;
@property (strong, nonatomic) NSString *itemname;


- (IBAction)submit:(id)sender;
- (IBAction)later:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *laterbutton;

@end
