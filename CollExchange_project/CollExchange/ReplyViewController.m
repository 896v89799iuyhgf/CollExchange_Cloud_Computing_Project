//
//  ReplyViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-18.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "ReplyViewController.h"
#import "DynamoDB.h"
#import "UserDynamoDBManager.h"

@interface ReplyViewController ()

@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _submitButton.layer.cornerRadius = 12.0;
    _submitButton.layer.borderWidth = 3.0;
    _submitButton.layer.borderColor = [UIColor orangeColor].CGColor;
    _submitButton.clipsToBounds = YES;
    
    _laterButton.layer.cornerRadius = 12.0;
    _laterButton.layer.borderWidth = 3.0;
    _laterButton.layer.borderColor = [UIColor orangeColor].CGColor;
    _laterButton.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [_replyMessage resignFirstResponder];
    [_receiverusernametext resignFirstResponder];
    
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

- (IBAction)submit:(id)sender {
    if([_receiverusernametext.text length] > 0){
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        queryExpression.hashKeyValues = _receiverusernametext.text;
        [[[dynamoDBObjectMapper query:[DDBUserTableRow class]
                       expression:queryExpression]
          continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
          
              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
              for (DDBUserTableRow *item in paginatedOutput.items) {
                  _usertableRow = item;
              }
              
              if([_usertableRow.username length] == 0){
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                  message:@"The receiver username is wrong."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                  [alert show];
                  
                  
                  
              }else{
                  NSMutableArray *addmessage = _usertableRow.message;
                  if([_replyMessage.text length]>0){
                      NSString *mes = [[[[@"The member " stringByAppendingString:_originname] stringByAppendingString:@" replied to you on your message ( "] stringByAppendingString:_originmessage] stringByAppendingString:@") :"];
                      NSString *finalmes = [NSString stringWithFormat:@"%@\r\r%@", mes,[@"      " stringByAppendingString:_replyMessage.text]];
                      [addmessage insertObject:finalmes atIndex:0];
                  }
                  _usertableRow.message = addmessage;
                  [[dynamoDBObjectMapper save:_usertableRow]
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
          
          
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              return nil;
      }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
          if (task.error) {
              NSLog(@"Error: [%@]", task.error);
          }
          
          
          return nil;
      }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please enter receiver's username."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
}
- (IBAction)later:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
