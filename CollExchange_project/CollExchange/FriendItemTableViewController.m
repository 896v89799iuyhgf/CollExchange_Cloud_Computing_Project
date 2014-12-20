//
//  FriendItemTableViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-16.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "FriendItemTableViewController.h"
#import "DynamoDB.h"
#import "ItemDynamoDBManager.h"
#import "MessageViewController.h"

@interface FriendItemTableViewController ()
@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;


@end

@implementation FriendItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //NSLog(@"edit:%@",_usernametext);
    _tableRows = [NSMutableArray new];
    _lock = [NSLock new];
    [self refreshList:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BFTask *)refreshList:(BOOL)startFromBeginning {
    if ([_lock tryLock]) {
        if (startFromBeginning) {
            _lastEvaluatedKey = nil;
            _doneLoading = NO;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
        queryExpression.limit = @20;
        queryExpression.hashKeyValues = _usernametext;// [[UIDevice currentDevice].identifierForVendor UUIDString];
        queryExpression.scanIndexForward = @YES;
        
        /*
         AWSDynamoDBCondition *condition = [AWSDynamoDBCondition new];
         AWSDynamoDBAttributeValue *attribute = [AWSDynamoDBAttributeValue new];
         attribute.S = @"Columbia";
         condition.attributeValueList = @[attribute];
         condition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
         AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
         scanExpression.exclusiveStartKey = nil;
         scanExpression.limit = @20;
         scanExpression.scanFilter = @{@"college": condition};
         */
        return [[[dynamoDBObjectMapper query:[DDBItemTableRow class]
                                  expression:queryExpression]
                 continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                     if (!self.lastEvaluatedKey) {
                         [self.tableRows removeAllObjects];
                     }
                     
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (DDBItemTableRow *item in paginatedOutput.items) {
                         [self.tableRows addObject:item];
                     }
                     //NSLog(@"%@",_usernametext);
                     self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey;
                     if (!paginatedOutput.lastEvaluatedKey) {
                         self.doneLoading = YES;
                     }
                     
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     [self.tableView reloadData];
                     
                     return nil;
                 }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                     if (task.error) {
                         NSLog(@"Error: [%@]", task.error);
                     }
                     
                     [self.lock unlock];
                     
                     return nil;
                 }];
    }
    
    return nil;
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableRows count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"frienditem" forIndexPath:indexPath];
    DDBItemTableRow *item = self.tableRows[indexPath.row];

    // Configure the cell...
    UILabel *itemNameLabel = (UILabel *)[cell viewWithTag:400];
    itemNameLabel.text = item.itemname;
    
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:401];
    UILabel *contactLabel = (UILabel *)[cell viewWithTag:402];

    valueLabel.text = [@"$" stringByAppendingString:[NSString stringWithFormat:@"%i", item.value]];
    contactLabel.text = item.contact;
    NSString *replace = [item.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    //NSLog(@"%@",finalpath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:403];
    [itemImageView setImage:[UIImage imageWithData:data]];
    if (indexPath.row == [self.tableRows count] - 1 && !self.doneLoading) {
        [self refreshList:NO];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"gotosendmessage"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MessageViewController *mvc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    DDBItemTableRow *tableRow = [self.tableRows objectAtIndex:indexPath.row];
    mvc.username = tableRow.username;
    mvc.mainusername = _mainusername;
    mvc.itemname = tableRow.itemname;
    
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
