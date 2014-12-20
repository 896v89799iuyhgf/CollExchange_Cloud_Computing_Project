//
//  EditDetailViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "EditDetailViewController.h"
#import "DynamoDB.h"
#import "ItemDynamoDBManager.h"
#import "EditViewController.h"
#import "S3.h"
#import "AWSCore.h"


@interface EditDetailViewController ()
@property (nonatomic, assign) BOOL dataChanged;
@end

@implementation EditDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _itemname.text = _tableRow.itemname;
    _contact.text = _tableRow.contact;
    _descript.text = _tableRow.descriptions;
    _value.text = [NSString stringWithFormat:@"%d", _tableRow.value];
    _filename = _tableRow.pictureurl;
    
    NSString *replace = [_tableRow.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    //NSLog(@"%@",finalpath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    
    [_photo setImage:[UIImage imageWithData:data]];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    _updatebutton.layer.cornerRadius = 12.0;
    _updatebutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _updatebutton.layer.borderWidth = 3.0;
    _updatebutton.clipsToBounds = YES;
    
    _changebutton.layer.cornerRadius = 12.0;
    _changebutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _changebutton.layer.borderWidth = 3.0;
    _changebutton.clipsToBounds = YES;
    
    _backbutton.layer.cornerRadius = 12.0;
    _backbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _backbutton.layer.borderWidth = 3.0;
    _backbutton.clipsToBounds = YES;
    // Do any additional setup after loading the view.
}

-(void)dismissKeyboard {
    [_itemname resignFirstResponder];
    [_contact resignFirstResponder];
    [_descript resignFirstResponder];
    [_value resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.dataChanged) {
        EditViewController *evc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 1];
        evc.needsToRefresh = YES;
    }
}

- (void)updateTableRow:(DDBItemTableRow *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper save:tableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"Successfully updated the item in the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             self.dataChanged = YES;

             
             
         } else {
             NSLog(@"Error: [%@]", task.error);
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to update the item in the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
         return nil;
     }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitupdate:(id)sender {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"andyweicao";
    uploadRequest.key = _filename;
    uploadRequest.body = _fileUrl;
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                       withBlock:^id(BFTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                           }
                                                           return nil;
                                                       }];
    

    
    
    
    DDBItemTableRow *tabRow = [DDBItemTableRow new];
    tabRow.username = _tableRow.username;
    tabRow.itemname = _itemname.text;
    tabRow.college = _tableRow.college;
    tabRow.contact = _contact.text;
    tabRow.descriptions = _descript.text;
    tabRow.value = [_value.text integerValue];
    tabRow.pictureurl = _filename;
    if ([_itemname.text length] > 0) {
        [self updateTableRow:tabRow];
        NSString *replace = [tabRow.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
        //NSLog(@"%@",finalpath);
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
        
        [_photo setImage:[UIImage imageWithData:data]];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error: Invalid Input"
                                                            message:@"Range Key Value cannot be empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)updateimage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSURL *url=[info
                objectForKey:UIImagePickerControllerReferenceURL];
    NSString *name = [url absoluteString];
    NSArray *myWords = [name componentsSeparatedByString:@"?"];
    name = [myWords objectAtIndex:[myWords count]-1];
    _filename = [name stringByAppendingString:@".png"];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:name] stringByAppendingString:@".png"];
    
    [UIImageJPEGRepresentation(_image,0.5) writeToFile:filePath atomically:YES];
    filePath = [NSString stringWithFormat:@"file://%@", filePath];
    _fileUrl = [NSURL URLWithString:filePath];
    //NSLog(@"@aaaaaaa:%@",_fileUrl);
    //NSLog(@"@aaaaaaa:%@",name);
    //NSLog(@"@aaaaaaa:%@",url);
    
    
    
}



@end
