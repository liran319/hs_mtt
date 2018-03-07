//
//  MTT_BaseDeviceModel.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_BaseDeviceModel.h"
#import "MTT_BaseDeviceModel+private.h"
@interface MTT_BaseDeviceModel()

@end
@implementation MTT_BaseDeviceModel
-(int)type{
    return [MTT_BaseDeviceModel Tag].intValue-40;
}


@end
