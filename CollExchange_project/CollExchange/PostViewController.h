//
//  PostViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)post:(id)sender;
- (IBAction)later:(id)sender;
- (IBAction)uploadimage:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *itemnametext;
@property (strong, nonatomic) IBOutlet UITextField *contacttext;
@property (strong, nonatomic) IBOutlet UITextView *desciptext;

@property (strong, nonatomic) IBOutlet UITextField *valuetext;

@property (strong, nonatomic) NSString *usernametext;
@property (strong, nonatomic) NSString *collegetext;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *fileUrl;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) IBOutlet UIButton *laterbutton;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *uploadbutton;
@property (strong, nonatomic) IBOutlet UIButton *postbutton;


@end
