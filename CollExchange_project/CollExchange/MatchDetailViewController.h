//
//  MatchDetailViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class DDBItemTableRow;
@class DDBUserTableRow;


@interface MatchDetailViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) DDBItemTableRow *tableRow;
@property (nonatomic, strong) DDBUserTableRow *usertableRow;

@property (strong, nonatomic) IBOutlet UILabel *itemname;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) IBOutlet UITextView *descipt;
@property (strong, nonatomic) IBOutlet UILabel *contact;
@property (strong, nonatomic) IBOutlet UILabel *value;
@property (strong, nonatomic) IBOutlet UILabel *college;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *mainusername;


- (IBAction)contact:(id)sender;
- (IBAction)follow:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *messagebutton;
- (IBAction)message:(id)sender;

@end
