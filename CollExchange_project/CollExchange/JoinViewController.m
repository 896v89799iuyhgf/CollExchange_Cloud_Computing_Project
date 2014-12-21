//
//  JoinViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "JoinViewController.h"
#import "UserDynamoDBManager.h"
#import "DynamoDB.h"
#import "SES.h"


@interface JoinViewController ()
{
    NSArray *_pickerData;
    NSString *_pickerText;

}
@property BOOL signal;


@end

@implementation JoinViewController
@synthesize joinUserField,joinPassField,joinConField,joinMailField,joinCityField,joinCollegePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int i = 10000+arc4random()%89999;
    _confirmationNumber = [NSString stringWithFormat:@"%d",i];
    //NSLog(@"Random Number: %i", i);
    
    _pickerData = @[@"Columbia", @"Harvard", @"Cornell", @"Dartmouth", @"UPenn", @"Yale", @"Brown", @"Princeton"];
    self.joinCollegePicker.dataSource = self;
    self.joinCollegePicker.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _pickerText = @"Columbia";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


-(void)dismissKeyboard {
    [joinUserField resignFirstResponder];
    [joinPassField resignFirstResponder];
    [joinConField resignFirstResponder];
    [joinMailField resignFirstResponder];
    [joinCityField resignFirstResponder];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    _pickerText = _pickerData[row];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)Send:(id)sender {
    AWSSESDestination *dadad = [[AWSSESDestination alloc] init];
    dadad.toAddresses = @[self.joinMailField.text];
    AWSSESContent *subject = [[AWSSESContent alloc] init];
    subject.data = @"Welcome to CollExchange!";
    AWSSESContent *textbody = [[AWSSESContent alloc] init];
    textbody.data = [@"Thank you for joining CollExchange. Please enter the following confirmation number into the text field. Here is your confirmation number: " stringByAppendingString: _confirmationNumber];
    AWSSESBody *body = [[AWSSESBody alloc] init];
    body.text = textbody;
    AWSSESMessage *message = [[AWSSESMessage alloc] init];
    message.subject = subject;
    message.body = body;
    AWSSESSendEmailRequest *request = [[AWSSESSendEmailRequest  alloc] init];
    request.source = @"andyweicao@gmail.com";
    request.destination = dadad;
    request.message = message;
    //NSLog(@"good");
    AWSSES *ses = [AWSSES defaultSES];
    if (![self isValidateEmail:self.joinMailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"The email address is not valid. Please use your college email!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
    [[ses sendEmail:request]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         //NSLog(@"good");
         if (task.error) {
             NSLog(@"Error: [%@]", task.error);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to send the confirmation email."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"The confirmation number has been send!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
         return nil;
     }];
    }

}

- (IBAction)submit:(id)sender {
    
    if(!self.signal){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Username is not available or did not check availablity."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    else if (([self.joinUserField.text  isEqual: @""])||([self.joinPassField.text  isEqual: @""] )||([self.joinConField.text  isEqual: @""])||([self.joinCityField.text  isEqual: @""])||([self.joinMailField.text  isEqual: @""])||([_pickerText  isEqual: @""]) ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"All inputs are required. "
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else if (![self.joinPassField.text isEqual:self.joinConField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Password confirmaiton is wrong."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (![self isValidateEmail:self.joinMailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"The email address is not valid. Please use your college email!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (![self.joinConfirmField.text isEqual:_confirmationNumber]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The confirmation number you entered is wrong. Please check and enter the correct one or you can press send again to get the number."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
    }else{
        DDBUserTableRow *tableRow = [DDBUserTableRow new];
        tableRow.username = self.joinUserField.text;
        tableRow.password = self.joinPassField.text;
        tableRow.passconf = self.joinConField.text;
        tableRow.city = self.joinCityField.text;
        tableRow.email = self.joinMailField.text;
        tableRow.college = _pickerText;
        NSMutableArray *init_friend = [[NSMutableArray alloc] init];
        [init_friend addObject:[@"self: " stringByAppendingString:self.joinUserField.text]];
        NSMutableArray *init_message = [[NSMutableArray alloc] init];
        [init_message addObject:[@"Welcome to CollExchange, " stringByAppendingString:self.joinUserField.text]];
        tableRow.friends = init_friend;
        tableRow.message = init_message;
        self.signal = NO;
        
        
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        [[dynamoDBObjectMapper save:tableRow]
         continueWithExecutor:[BFExecutor mainThreadExecutor]
         withBlock:^id(BFTask *task) {
             //This block will be executed after the table row is saved.
             if (!task.error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome"
                                                                 message:@"Thank you to be a member of CollExchange! Please sign in and enjoy!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 self.joinUserField.text = nil;
                 self.joinPassField.text = nil;
                 self.joinConField.text = nil;
                 self.joinCityField.text = nil;
                 self.joinMailField.text = nil;
                 
                 
             } else {
                 NSLog(@"Error: [%@]", task.error);
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Failed to save your informaiton."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
             
             
             return nil;
         }];
        [self dismissViewControllerAnimated:YES completion:nil];

    }

    
    }

- (IBAction)available:(id)sender {
    self.signal = YES;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.exclusiveStartKey=nil;
    queryExpression.hashKeyValues = self.joinUserField.text;
    [[dynamoDBObjectMapper query:[DDBUserTableRow class] expression:queryExpression] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            //NSLog(@"Error: hello");
            AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
            if([paginatedOutput.items count] == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                                message:@"This username is available!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
                
            }else{
                
                
                for (DDBUserTableRow *item in paginatedOutput.items) {
                    
                    if(item.password != nil){
                        //NSLog(@"Error: [%@]", item);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                        message:@"This username has been used. Please choose another one!"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                        
                        self.signal = NO;
                    }
                }
            }
            
        } else {
            NSLog(@"Error: [%@]", task.error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"The username cannot be empty."
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

- (IBAction)information:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How to get comfirmation number"
                                                    message:@"You should enter the email address which you want to use to make registration. Then press the send button beside the email text field and you will receive the confirmation number by email."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

-(BOOL)isValidateEmail:(NSString *)email {
    //NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[columbia]+\\.[edu]";
    //NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSArray *emailarray = [email componentsSeparatedByString:@"."];
    if([emailarray count]<2){
        return NO;
    }
    if([[emailarray objectAtIndex:[emailarray count]-1] isEqualToString:@"edu"]){
        if([[emailarray objectAtIndex:[emailarray count]-2] containsString:@"columbia"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"harvard"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"cornell"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"dartmouth"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"yale"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"brown"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"princeton"]||[[emailarray objectAtIndex:[emailarray count]-2] containsString:@"upenn"]){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    return NO;
    //return [emailTest evaluateWithObject:email];
}
@end
