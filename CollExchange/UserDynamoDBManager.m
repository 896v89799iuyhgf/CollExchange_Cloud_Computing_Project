//
//  UserDynamoDBManager.m
//  CollExchange
//
//  Created by Cao Wei on 14-12-6.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import "UserDynamoDBManager.h"
#import "DynamoDB.h"
#import "Constants.h"

@implementation UserDynamoDBManager

@end

@implementation DDBUserTableRow

+ (NSString *)dynamoDBTableName {
    return UserTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"username";
}

+ (NSString *)rangeKeyAttribute {
    return @"password";
}
@end
