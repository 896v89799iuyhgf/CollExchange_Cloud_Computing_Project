//
//  ViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-22.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDBUserTableRow;


@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *userfield;
@property (strong, nonatomic) IBOutlet UITextField *passfield;
- (IBAction)login:(id)sender;
@property (nonatomic, strong) DDBUserTableRow *usertableRow;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *college;
@property (strong, nonatomic) NSString *email;
- (IBAction)submit:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *loginbutton;
@property (strong, nonatomic) IBOutlet UIButton *joinbutton;


@end

