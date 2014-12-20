//
//  ReplyViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-18.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDBUserTableRow;

@interface ReplyViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *receiverusernametext;
@property (strong, nonatomic) IBOutlet UITextView *replyMessage;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submit:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *laterButton;
- (IBAction)later:(id)sender;
@property (nonatomic, strong) DDBUserTableRow *usertableRow;


@property (strong, nonatomic) NSString *originmessage;
@property (strong, nonatomic) NSString *originname;


@end
