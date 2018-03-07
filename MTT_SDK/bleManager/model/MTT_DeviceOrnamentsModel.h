//
//  MTT_DeviceStateModel.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//


/*挂饰传感器*/
#import "MTT_BaseDeviceModel.h"
typedef enum{
    DeviceOrnamentStateUp = 1, //拿起
    DeviceOrnamentStateDown , //放下
} DeviceOrnamentState;
@interface MTT_DeviceOrnamentsModel : MTT_BaseDeviceModel
/**
 设备被动得次数
 */
@property(nonatomic,assign,readonly)DeviceOrnamentState   state;
//@property(nonatomic,copy,readonly)  NSString            *macStr;
@property(nonatomic,copy,readonly)  NSString            *verson;
//拿起放下的时间间隔
@property(nonatomic,assign,readonly)  NSInteger          duration;
@end
