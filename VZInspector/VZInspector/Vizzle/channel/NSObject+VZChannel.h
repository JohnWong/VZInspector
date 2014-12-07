//
//  NSObject+VZChannel.h
//  VizzleListExample
//
//  Created by moxin.xt on 14-11-8.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VZChannel)

- (void)listen:(NSString* )channelName  then:(void(^)(NSDictionary* info))block;
- (void)post:(NSString* )channelName with:(NSDictionary* )info;

@end
