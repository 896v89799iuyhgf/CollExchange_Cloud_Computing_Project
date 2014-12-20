//
//  MatchViewController.m
//  CollExchange
//
//  Created by Cao Wei on 14-11-30.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "MatchViewController.h"
#import "MatchDetailViewController.h"
#import "DynamoDB.h"
#import "ItemDynamoDBManager.h"


@interface MatchViewController ()
@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;
@property (nonatomic, assign) BOOL emptysignal;
@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    _tableRows = [NSMutableArray new];
    _lock = [NSLock new];
    _emptysignal = YES;
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
    if ([self.lock tryLock]) {
        if (startFromBeginning) {
            self.lastEvaluatedKey = nil;
            self.doneLoading = NO;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        /*
         AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
         queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
         queryExpression.limit = @20;
         queryExpression.hashKeyValues = @"steve";// [[UIDevice currentDevice].identifierForVendor UUIDString];
         queryExpression.scanIndexForward = @YES;
         */
        
        AWSDynamoDBCondition *condition1 = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute1 = [AWSDynamoDBAttributeValue new];
        attribute1.S = _tableRow.username;
        condition1.attributeValueList = @[attribute1];
        condition1.comparisonOperator = AWSDynamoDBComparisonOperatorNE;
        
        AWSDynamoDBCondition *condition2 = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute2a = [AWSDynamoDBAttributeValue new];
        NSString *num1 = [NSString stringWithFormat:@"%d",_tableRow.value-5];
        NSString *num2 = [NSString stringWithFormat:@"%d",_tableRow.value+5];
        /*
        if(num1.length < num2.length){
            attribute1.S = [@"0" stringByAppendingString:num1];
        }else{
            attribute1.S = num1;
        }
         */
        attribute2a.N = num1;
       // NSLog(@"Eor: [%@]",attribute2a.N);


         AWSDynamoDBAttributeValue *attribute2b = [AWSDynamoDBAttributeValue new];
        //NSString *num2 = [NSString stringWithFormat:@"%d",[_tableRow.value integerValue]+5];
        attribute2b.N = num2;
        //NSLog(@"Eoor: [%@]",attribute2b.N);

        condition2.attributeValueList = @[attribute2a,attribute2b];
        condition2.comparisonOperator = AWSDynamoDBComparisonOperatorBetween;
        
        
        AWSDynamoDBCondition *condition3 = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute3 = [AWSDynamoDBAttributeValue new];
        attribute3.S = _tableRow.college;
        condition3.attributeValueList = @[attribute3];
        condition3.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
        
        AWSDynamoDBCondition *condition4 = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute4 = [AWSDynamoDBAttributeValue new];
        attribute4.S = _searchtype;
        condition4.attributeValueList = @[attribute4];
        condition4.comparisonOperator = AWSDynamoDBComparisonOperatorContains;
        
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        scanExpression.exclusiveStartKey = nil;
        scanExpression.limit = @20;
        if ([_searchtype length] == 0) {
            scanExpression.scanFilter = @{@"value": condition2,@"username": condition1,@"college": condition3};
        }else{
            scanExpression.scanFilter = @{@"value": condition2,@"username": condition1,@"college": condition3,@"itemname": condition4};
        }
        return [[[dynamoDBObjectMapper scan:[DDBItemTableRow class]
                                 expression:scanExpression]
                 continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                     if (!self.lastEvaluatedKey) {
                         [self.tableRows removeAllObjects];
                     }
                     
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     //NSLog(@"Eeror: [%@]",paginatedOutput.items);
                     for (DDBItemTableRow *item in paginatedOutput.items) {
                         _emptysignal = NO;
                         //NSLog(@"EEror: [%@]",item.itemname );
                         [self.tableRows addObject:item];
                     }
                     if(_emptysignal){
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                         message:@"No matching items."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mc" forIndexPath:indexPath];
    
    
    // Configure the cell...
    DDBItemTableRow *item = self.tableRows[indexPath.row];
    
    UILabel *itemNameLabel = (UILabel *)[cell viewWithTag:100];
    itemNameLabel.text = item.itemname;
    
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag:101];
    userNameLabel.text = item.username;
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:102];
    valueLabel.text = [NSString stringWithFormat:@"%i", item.value];
    UILabel *collegeLabel = (UILabel *)[cell viewWithTag:103];
    collegeLabel.text = item.college;
    
  
    //cell.textLabel.text = item.itemname;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", item.value];//item.value;
    
    NSString *replace = [item.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    //NSLog(@"%@",finalpath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:104];
    [itemImageView setImage:[UIImage imageWithData:data]];
    //[cell.imageView setImage:[UIImage imageWithData:data]];
    /*
    cell.itemname.text = item.itemname;
    cell.value.text =[NSString stringWithFormat:@"%i", item.value];
    cell.username.text = item.username;
    cell.college.text = item.college;
    
    NSString *replace = [item.pictureurl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString *newreplace = [replace stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *finalpath = [@"https://s3.amazonaws.com/andyweicao" stringByAppendingPathComponent:newreplace];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalpath]];
    
    [cell.image setImage:[UIImage imageWithData:data]];
    */
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
    [self performSegueWithIdentifier:@"tod"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MatchDetailViewController *mdvc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    DDBItemTableRow *tableRow = [self.tableRows objectAtIndex:indexPath.row];
    mdvc.tableRow = tableRow;
    mdvc.usertableRow = _usertableRow;
    mdvc.mainusername = _mainusername;
    
}



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
