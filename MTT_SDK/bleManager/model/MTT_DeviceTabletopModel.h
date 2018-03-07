//
//  MTT_DevicePickedModel.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.


/*摆饰传感器*/
#import "MTT_BaseDeviceModel.h"

typedef enum{
    DevicePickedStateUp = 1, //拿起
    DevicePickedStateDown , //放下
} DeviceTabletopState;

@interface MTT_DeviceTabletopModel : MTT_BaseDeviceModel
@property(nonatomic,assign,readonly)DeviceTabletopState   state;
//@property(nonatomic,copy,readonly)  NSString            *macStr;
@property(nonatomic,copy,readonly)  NSString            *verson;
//拿起放下的时间间隔
@property(nonatomic,assign,readonly)  NSInteger          duration;

@end
