//
//  ItemDynamoDBManager.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-8.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamoDB.h"

@class DDBItemTableRow;
@class BFTask;

@interface ItemDynamoDBManager : NSObject

@end

@interface DDBItemTableRow : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *itemname;
@property (nonatomic, strong) NSString *contact;
@property (nonatomic, strong) NSString *descriptions;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, strong) NSString *pictureurl;
@property (nonatomic, strong) NSString *college;


@end