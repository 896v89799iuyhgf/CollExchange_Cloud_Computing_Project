//
//  PopularViewController.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-11.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)indexChanged:(UISegmentedControl *)sender;

@property (strong, nonatomic) NSURL *url;


@end
