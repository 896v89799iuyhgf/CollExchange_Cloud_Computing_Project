//
//  PersonViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "PersonViewController.h"
#import "ItemViewController.h"
#import "EditViewController.h"
#import "ItemViewController.h"
#import "PostViewController.h"
#import "UserDynamoDBManager.h"
#import "MessageViewController.h"
#import "FriendTableViewController.h"
#import "DynamoDB.h"
#import "UserDynamoDBManager.h"




@interface PersonViewController ()

@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _user.text = _usernametext;
    //NSLog(@"%@", _usertableRow.friends);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    
}

-(void)dismissKeyboard {
    [_searchtext resignFirstResponder];
    
    
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        [[dynamoDBObjectMapper load:[DDBUserTableRow class]
                            hashKey:_usernametext//[[UIDevice currentDevice].identifierForVendor UUIDString]
                           rangeKey:_passtext] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (!task.error) {
                _usertableRow = task.result;
                
                

                    
            } else {
                NSLog(@"Error: [%@]", task.error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                                message:@"Error happens. Log out and log in back!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
            return nil;
        }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"gotoitem"]) {
        
        
        EditViewController *evc = [segue destinationViewController];
        evc.usernametext = _usernametext;
    
    }else if ([[segue identifier] isEqualToString:@"gotopost"]) {
        
        
        PostViewController *pvc = [segue destinationViewController];
        pvc.usernametext = _usernametext;
        pvc.collegetext = _collegetext;
        
    }else if ([[segue identifier] isEqualToString:@"gotoexchange"]) {
        
        
        ItemViewController *ivc = [segue destinationViewController];
        ivc.usernametext = _usernametext;
        ivc.searchtype = _searchtext.text;
        ivc.usertableRow = _usertableRow;
    }else if ([[segue identifier] isEqualToString:@"gotomess"]) {
        MessageViewController *mvc = [segue destinationViewController];
        mvc.usertableRow = _usertableRow;
    }else if ([[segue identifier] isEqualToString:@"gotofriends"]) {
        FriendTableViewController *fvc = [segue destinationViewController];
        fvc.usertableRow = _usertableRow;
        fvc.mainusername = _usernametext;
       // NSLog(@"%@", _usertableRow.friends);
    }
}

- (IBAction)postanitem:(id)sender {
    [self performSegueWithIdentifier:@"gotopost" sender:self];

}

- (IBAction)edititems:(id)sender {
    [self performSegueWithIdentifier:@"gotoitem" sender:self];
}

- (IBAction)findexchange:(id)sender {
    [self performSegueWithIdentifier:@"gotoexchange" sender:self];

}

- (IBAction)message:(id)sender {
    [self performSegueWithIdentifier:@"gotomess" sender:self];
}

- (IBAction)following:(id)sender {
    [self performSegueWithIdentifier:@"gotofriends" sender:self];

}
@end
