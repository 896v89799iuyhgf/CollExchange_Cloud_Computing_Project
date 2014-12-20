//
//  MatchDetailViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "DynamoDB.h"
#import "ItemDynamoDBManager.h"
#import "UserDynamoDBManager.h"
#import "S3.h"
#import "AWSCore.h"
#import "MessageViewController.h"

@interface MatchDetailViewController ()
@property (nonatomic, assign) BOOL followed;

@end

@implementation MatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _followed = NO;
    
    _messagebutton.layer.cornerRadius = 12.0;
    _messagebutton.layer.borderWidth = 3.0;
    _messagebutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _messagebutton.clipsToBounds = YES;


    _itemname.text = _tableRow.itemname;
    _username.text = _tableRow.username;
    _descipt.text = _tableRow.descriptions;
    _contact.text = _tableRow.contact;
    _college.text = _tableRow.college;
    _value.text = [NSString stringWithFormat:@"%d", _tableRow.value];
    NSString *replace = [_tableRow.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    //NSLog(@"%@",finalpath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    
    [_photo setImage:[UIImage imageWithData:data]];
       
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


- (IBAction)contact:(id)sender {
    if([self isValidateEmail:_contact.text]){
        // Email Subject
        NSString *emailTitle = @"I am interested in your Item!";
        // Email Content
        NSString *messageBody = @"I saw your post on CollExchange.";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:_contact.text];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];

    
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"The contact format is not valid. You have to contact by yourself."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
}

- (IBAction)follow:(id)sender {
    DDBUserTableRow *utableRow = [DDBUserTableRow new];
    NSMutableArray *addfriend = _usertableRow.friends;
    if([addfriend containsObject:_username.text]){
        _followed = YES;
    }else{
        [addfriend addObject:_username.text];
        _followed = NO;
    }
    utableRow.username = _usertableRow.username;
    utableRow.password = _usertableRow.password;
    utableRow.passconf = _usertableRow.passconf;
    utableRow.city = _usertableRow.city;
    utableRow.college = _usertableRow.college;
    utableRow.email = _usertableRow.email;
    utableRow.message = _usertableRow.message;
    utableRow.friends = addfriend;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper save:utableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             if(!_followed){
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"Thanks for your following!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                 [alert show];
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                 message:@"You have already followed him/her."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         
         } else {
             NSLog(@"Error: [%@]", task.error);
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to follow..."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
         return nil;
     }];

    
}

-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"gotomessage"]) {
        MessageViewController *mvc = [segue destinationViewController];
        mvc.username = _username.text;
        mvc.mainusername = _mainusername;
        mvc.itemname = _itemname.text;
    }
}




- (IBAction)message:(id)sender {
    [self performSegueWithIdentifier:@"gotomessage" sender:self];

}
@end
