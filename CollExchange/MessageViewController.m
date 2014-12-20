//
//  MessageViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-15.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "MessageViewController.h"
#import "DynamoDB.h"
#import "UserDynamoDBManager.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _submitbutton.layer.cornerRadius = 12.0;
    _submitbutton.layer.borderWidth = 3.0;
    _submitbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _submitbutton.clipsToBounds = YES;
    
    _laterbutton.layer.cornerRadius = 12.0;
    _laterbutton.layer.borderWidth = 3.0;
    _laterbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _laterbutton.clipsToBounds = YES;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.hashKeyValues = _username;
    
    [[[dynamoDBObjectMapper query:[DDBUserTableRow class]
                       expression:queryExpression]
      continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
          
          AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
          for (DDBUserTableRow *item in paginatedOutput.items) {
              _usertableRow = item;
          }
          
          
          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
          return nil;
      }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
          if (task.error) {
              NSLog(@"Error: [%@]", task.error);
          }
          
          
          return nil;
      }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [_messagetext resignFirstResponder];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit:(id)sender {
    
    DDBUserTableRow *utableRow = [DDBUserTableRow new];
    NSMutableArray *addmessage = _usertableRow.message;
    if([_messagetext.text length]>0){
        NSString *mes = [[[[@"The member " stringByAppendingString:_mainusername] stringByAppendingString:@" sent you a message on your posting "] stringByAppendingString:_itemname] stringByAppendingString:@":"];
        NSString *finalmes = [NSString stringWithFormat:@"%@\r\r%@", mes,[@"      " stringByAppendingString:_messagetext.text]];
        [addmessage insertObject:finalmes atIndex:0];
    }
    //NSLog(@"%@", addmessage);
    utableRow.username = _usertableRow.username;
    utableRow.password = _usertableRow.password;
    utableRow.passconf = _usertableRow.passconf;
    utableRow.city = _usertableRow.city;
    utableRow.college = _usertableRow.college;
    utableRow.email = _usertableRow.email;
    utableRow.friends = _usertableRow.friends;
    utableRow.message = addmessage;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

    [[dynamoDBObjectMapper save:utableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"The message has been sent!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             [self dismissViewControllerAnimated:YES completion:nil];

             
         } else {
             NSLog(@"Error: [%@]", task.error);
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to send message..."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
         return nil;
     }];

    
}

- (IBAction)later:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
