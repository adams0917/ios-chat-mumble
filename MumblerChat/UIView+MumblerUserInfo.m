//
//  UIView+MumblerUserInfo.m
//  Mumbler
//
//  Created by Ransika De Silva on 1/3/14.
//  Copyright (c) 2014 Visni (Pvt) Ltd. All rights reserved.
//

#import "UIView+MumblerUserInfo.h"
#import <objc/runtime.h>

@implementation UIView (MumblerUserInfo)

-(void)setViewUserInfo:(id)info
{
    objc_setAssociatedObject(self, "_viewUserInfo", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



-(id)viewUserInfo
{
    return objc_getAssociatedObject(self, "_viewUserInfo");   
}
@end
