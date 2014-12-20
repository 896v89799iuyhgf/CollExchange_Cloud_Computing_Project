//
//  UserDynamoDBManager.h
//  CollExchange
//
//  Created by Cao Wei on 14-12-6.
//  Copyright (c) 2014年 Cao Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamoDB.h"

@class DDBUserTableRow;
@class BFTask;

@interface UserDynamoDBManager : NSObject

@end

@interface DDBUserTableRow : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passconf;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *college;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *message;




@end
