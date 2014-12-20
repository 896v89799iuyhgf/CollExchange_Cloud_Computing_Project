//
//  MessageTableViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-15.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "MessageTableViewController.h"
#import "DynamoDB.h"
#import "UserDynamoDBManager.h"
#import "ReplyViewController.h"

@interface MessageTableViewController ()

@end

@implementation MessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper load:[DDBUserTableRow class]
                        hashKey:_usertableRow.username//[[UIDevice currentDevice].identifierForVendor UUIDString]
                       rangeKey:_usertableRow.password] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            _usertableRow = task.result;
            _mess = _usertableRow.message;
            //NSLog(@"Error: [%@]", _mess);
            [self.tableView reloadData];
            
            
            
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


    self.view.backgroundColor = [UIColor blackColor];
    //NSLog(@"%@", _usertableRow.message);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_mess count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mes" forIndexPath:indexPath];
    
    // Configure the cell...
    UITextView *message = (UITextView *)[cell viewWithTag:123];
    message.text = [_mess objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *singlemess = [_mess objectAtIndex:indexPath.row];
        [_mess removeObject:singlemess];
        [self deletemessage:singlemess];
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)deletemessage:(NSString *)row {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    DDBUserTableRow *utableRow = [DDBUserTableRow new];
    NSMutableArray *removemessage = _usertableRow.message;
    [removemessage removeObject:row];
    utableRow.username = _usertableRow.username;
    utableRow.password = _usertableRow.password;
    utableRow.passconf = _usertableRow.passconf;
    utableRow.city = _usertableRow.city;
    utableRow.college = _usertableRow.college;
    utableRow.email = _usertableRow.email;
    utableRow.friends = _usertableRow.friends;
    utableRow.message = removemessage;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper save:utableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                             message:@"The message has been removed."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             [self.tableView reloadData];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
         } else {
             NSLog(@"Error: [%@]", task.error);
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to delete the message..."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
         
         return nil;
     }];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"gotoreply"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ReplyViewController *rvc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    rvc.originmessage = [_mess objectAtIndex:indexPath.row];
    rvc.originname = _usertableRow.username;
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
