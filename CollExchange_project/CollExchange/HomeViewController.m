//
//  ViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-22.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "HomeViewController.h"
#import "PersonViewController.h"
#import "JoinViewController.h"
#import "DynamoDB.h"
#import "UserDynamoDBManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize userfield,passfield;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _usertableRow = [DDBUserTableRow new];
    
    _loginbutton.layer.cornerRadius = 12.0;
    _loginbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _loginbutton.layer.borderWidth = 3.0;
    _loginbutton.clipsToBounds = YES;
    
    _joinbutton.layer.cornerRadius = 12.0;
    _joinbutton.layer.borderWidth = 3.0;
    _joinbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _joinbutton.clipsToBounds = YES;
    //[self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];

    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    //self.view.backgroundColor = [UIColor blackColor];
    
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
    [userfield resignFirstResponder];
    [passfield resignFirstResponder];
    
    
    
}

- (IBAction)login:(id)sender {
    [self getTableRow:self.passfield.text];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"gotoperson"]) {

    
    PersonViewController *pvc = [segue destinationViewController];
    pvc.usernametext = _username;
    pvc.passtext = _password;
    pvc.emailtext = _email;
    pvc.citytext = _city;
    pvc.collegetext = _college;
    //pvc.usertableRow = _usertableRow;
    }
}

- (void)getTableRow:(NSString *)rangeKey {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper load:[DDBUserTableRow class]
                        hashKey:self.userfield.text//[[UIDevice currentDevice].identifierForVendor UUIDString]
                       rangeKey:rangeKey] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            DDBUserTableRow *tableRow = task.result;
         
            
            //NSLog(@"Error: %i",[tableRow.passconf length]);
            if([tableRow.passconf length] == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                message:@"Username or password is wrong! Please check."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
                
            }else{
                _usertableRow = tableRow;
                _username = self.userfield.text;
                _password = self.passfield.text;
                _city = tableRow.city;
                _email = tableRow.email;
                _college = tableRow.college;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"You are logged in!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self performSegueWithIdentifier:@"gotoperson" sender:self];

            }
        } else {
            NSLog(@"Error: [%@]", task.error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                            message:@"Username and password cannot be blank!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        return nil;
    }];
}
- (IBAction)submit:(id)sender {
    [self performSegueWithIdentifier:@"gotojoin" sender:self];

}

@end
