//
//  ItemDynamoDBManager.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-8.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "ItemDynamoDBManager.h"
#import "DynamoDB.h"
#import "Constants.h"

@implementation ItemDynamoDBManager

@end

@implementation DDBItemTableRow

+ (NSString *)dynamoDBTableName {
    return ItemTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"username";
}

+ (NSString *)rangeKeyAttribute {
    return @"itemname";
}
@end