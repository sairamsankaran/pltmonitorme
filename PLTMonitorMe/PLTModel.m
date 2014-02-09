//
//  PLTModel.m
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/8/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import "PLTModel.h"

@implementation PLTModel

- (id) init {
    self = [super init];
    if (self) {
        self.headNod = @"No";
        self.pedometerCount = 0;
    }
    return self;
}

+ (PLTModel *)instance {
    static dispatch_once_t once;
    static PLTModel *instance;
    
    dispatch_once(&once, ^{
        instance = [[PLTModel alloc] init];
    });
    
    return instance;
}

- (void) setHeadNodYN: (NSString*)string {
    self.headNod = string;
}

- (void) setPedCount: (NSUInteger)pedCount
{
    self.pedometerCount = pedCount;
}

@end
