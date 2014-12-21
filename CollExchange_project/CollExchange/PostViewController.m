//
//  PostViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "PostViewController.h"
#import "ItemDynamoDBManager.h"
#import "DynamoDB.h"
#import "S3.h"
#import "AWSCore.h"

@interface PostViewController ()

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _fileUrl = nil;
    _filename = nil;
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _uploadbutton.layer.cornerRadius = 12.0;
    _uploadbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _uploadbutton.layer.borderWidth = 3.0;
    _uploadbutton.clipsToBounds = YES;
    
    _postbutton.layer.cornerRadius = 12.0;
    _postbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _postbutton.layer.borderWidth = 3.0;
    _postbutton.clipsToBounds = YES;
    
    _laterbutton.layer.cornerRadius = 12.0;
    _laterbutton.layer.borderColor = [UIColor orangeColor].CGColor;
    _laterbutton.layer.borderWidth = 3.0;
    _laterbutton.clipsToBounds = YES;
    
}

-(void)dismissKeyboard {
    [_itemnametext resignFirstResponder];
    [_contacttext resignFirstResponder];
    [_desciptext resignFirstResponder];
    [_valuetext resignFirstResponder];
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

- (IBAction)post:(id)sender {
        if (([_itemnametext.text  isEqual: @""])||([_contacttext.text  isEqual: @""] )||([_desciptext.text  isEqual: @""])||([_valuetext.text  isEqual: @""]) ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"All inputs are required. "
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else{
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"#######";
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
        

        
        
        
        
        
        
        
        
        
        
        
        
        DDBItemTableRow *tableRow = [DDBItemTableRow new];
        tableRow.username = _usernametext;
        tableRow.itemname = _itemnametext.text;
        tableRow.contact = _contacttext.text;
        tableRow.descriptions = _desciptext.text;
        tableRow.value = [_valuetext.text integerValue];
        tableRow.college = _collegetext;
        tableRow.pictureurl = _filename;
        
        
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        [[dynamoDBObjectMapper save:tableRow]
         continueWithExecutor:[BFExecutor mainThreadExecutor]
         withBlock:^id(BFTask *task) {
             //This block will be executed after the table row is saved.
             if (!task.error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                 message:@"Your item has been post!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 _itemnametext.text = nil;
                 _contacttext.text = nil;
                 _desciptext.text = nil;
                 _valuetext.text = nil;
                 
                 
             } else {
                 NSLog(@"Error: [%@]", task.error);
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Failed to save item informaiton."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
             
             
             return nil;
         }];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }

    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)later:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)uploadimage:(id)sender {
    
     UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
     imagePicker.delegate = self;
     [self presentViewController:imagePicker animated:YES completion:nil];
   
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [_imageView setImage:_image];
    NSURL *url=[info
                objectForKey:UIImagePickerControllerReferenceURL];
    NSString *name = [url absoluteString];
    NSArray *myWords = [name componentsSeparatedByString:@"?"];
    name = [myWords objectAtIndex:[myWords count]-1];
    _filename = [name stringByAppendingString:@".png"];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:name] stringByAppendingString:@".jpg"];
    
    [UIImageJPEGRepresentation(_image,0.5) writeToFile:filePath atomically:YES];
    filePath = [NSString stringWithFormat:@"file://%@", filePath];
    _fileUrl = [NSURL URLWithString:filePath];
    //NSLog(@"@aaaaaaa:%@",_fileUrl);
    //NSLog(@"@aaaaaaa:%@",name);
    //NSLog(@"@aaaaaaa:%@",url);



}
@end
