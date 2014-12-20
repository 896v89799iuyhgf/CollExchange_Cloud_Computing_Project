//
//  PopularViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-11.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "PopularViewController.h"

@interface PopularViewController ()

@end

@implementation PopularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _url = [NSURL URLWithString:@"http://www.ebay.com"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:{
            _url = [NSURL URLWithString:@"http://www.ebay.com"];
            NSURLRequest *requestObj0 = [NSURLRequest requestWithURL:_url];
            [_webView loadRequest:requestObj0];
            break;}
        case 1:{
            _url = [NSURL URLWithString:@"http://www.amazon.com"];
            NSURLRequest *requestObj1 = [NSURLRequest requestWithURL:_url];
            [_webView loadRequest:requestObj1];
            break;}
        case 2:{
            _url = [NSURL URLWithString:@"http://www.walmart.com"];
            NSURLRequest *requestObj2 = [NSURLRequest requestWithURL:_url];
            [_webView loadRequest:requestObj2];
            break;}
        case 3:{
            _url = [NSURL URLWithString:@"http://www.bestbuy.com"];
            NSURLRequest *requestObj3 = [NSURLRequest requestWithURL:_url];
            [_webView loadRequest:requestObj3];
            break;}
        default:
            break; 
    }
}
@end
