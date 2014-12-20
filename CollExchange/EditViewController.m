//
//  EditViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "EditViewController.h"
#import "DynamoDB.h"
#import "ItemDynamoDBManager.h"
#import "EditDetailViewController.h"

@interface EditViewController ()
@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;

@end

@implementation EditViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"update refresh");
    [self refreshList:YES];
/*
    if (self.needsToRefresh) {
        [self refreshList:YES];
        self.needsToRefresh = NO;
    }
 */
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
                     //NSLog(@"ADDD");
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
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tableRows count];
    ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"edcl" forIndexPath:indexPath];
    
    // Configure the cell...
    DDBItemTableRow *item = self.tableRows[indexPath.row];
    UILabel *itemNameLabel = (UILabel *)[cell viewWithTag:200];
    itemNameLabel.text = item.itemname;
    
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:201];
    valueLabel.text = [NSString stringWithFormat:@"%i", item.value];
    UILabel *collegeLabel = (UILabel *)[cell viewWithTag:202];
    collegeLabel.text = item.college;
    
    
    //cell.textLabel.text = item.itemname;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", item.value];//item.value;
    
    NSString *replace = [item.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    //NSLog(@"%@",finalpath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:222];
    [itemImageView setImage:[UIImage imageWithData:data]];
    if (indexPath.row == [self.tableRows count] - 1 && !self.doneLoading) {
        [self refreshList:NO];
    }
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"edit"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DDBItemTableRow *row = self.tableRows[indexPath.row];
        [self deleteTableRow:row];
        
        [self.tableRows removeObject:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}


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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EditDetailViewController *edvc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    DDBItemTableRow *tableRow = [self.tableRows objectAtIndex:indexPath.row];
    edvc.tableRow = tableRow;
    
}

- (void)deleteTableRow:(DDBItemTableRow *)row {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper remove:row]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         if (task.error) {
             NSLog(@"Error: [%@]", task.error);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to delete an item."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             
             [self.tableView reloadData];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
         
         return nil;
     }];
}


@end
