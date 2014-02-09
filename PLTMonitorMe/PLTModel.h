//
//  PLTModel.h
//  PLTMonitorMe
//
//  Created by Sairam Sankaran on 2/8/14.
//  Copyright (c) 2014 Sairam Sankaran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLTModel : NSObject

@property (strong, nonatomic) NSString *headNod;
@property (nonatomic) NSUInteger pedometerCount;

+ (PLTModel *)instance;
- (void) setHeadNodYN: (NSString*)string;
- (void) setPedCount: (NSUInteger)pedCount;

@end
