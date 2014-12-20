//
//  JoinViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *joinUserField;
@property (strong, nonatomic) IBOutlet UITextField *joinPassField;
@property (strong, nonatomic) IBOutlet UITextField *joinConField;
@property (strong, nonatomic) IBOutlet UITextField *joinMailField;
@property (strong, nonatomic) IBOutlet UITextField *joinCityField;
@property (strong, nonatomic) IBOutlet UIPickerView *joinCollegePicker;
@property (strong, nonatomic) IBOutlet UITextField *joinConfirmField;
@property (strong, nonatomic) NSString *confirmationNumber;


- (IBAction)Send:(id)sender;

- (IBAction)submit:(id)sender;
- (IBAction)available:(id)sender;
- (IBAction)later:(id)sender;
- (IBAction)information:(id)sender;

@end
