//
//  LTNewsView.h
//  CustomerAlert
//
//  Created by chunlen on 2016/12/13.
//  Copyright © 2016年 lt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTNewsViewScrollDirection) {
    LTNewsViewScrollDirectionHorizon = 0,
    LTNewsViewScrollDirectionVertical
};

typedef void(^NewsClosedBlock)();


@interface CJNewsView : UIWindow


+ (CJNewsView *)showNews:(NSArray *)news inView:(UIView *)sView newsComplete:(void(^)())complete;

@end
