//
//  EditDetailViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDBItemTableRow;


@interface EditDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) DDBItemTableRow *tableRow;
@property (strong, nonatomic) IBOutlet UITextField *itemname;
@property (strong, nonatomic) IBOutlet UITextField *contact;
@property (strong, nonatomic) IBOutlet UITextView *descript;
@property (strong, nonatomic) IBOutlet UITextField *value;
@property (strong, nonatomic) IBOutlet UIImageView *photo;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSURL *fileUrl;

@property (strong, nonatomic) IBOutlet UIButton *changebutton;
@property (strong, nonatomic) IBOutlet UIButton *updatebutton;
@property (strong, nonatomic) IBOutlet UIButton *backbutton;


- (IBAction)submitupdate:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)updateimage:(id)sender;

@end
