//
//  VZInspectOverView.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectOverView : UIView

- (void)updateGlobalInfo;
- (void)handleRead;
- (void)handleWrite;
- (void)performMemoryWarning:(BOOL)b;


@end
