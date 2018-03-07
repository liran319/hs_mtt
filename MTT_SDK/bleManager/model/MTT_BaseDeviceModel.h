//
//  MTT_BaseDeviceModel.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    DeviceStateNormal = 0,      //设备正常有数据
    DeviceStateElectricLow = 1, //电量低
    DeviceStateHeartbeat  = 2   //心跳包用来告知设备在正常运转
}   DeviceState;

@interface MTT_BaseDeviceModel : NSObject

/**
 该对象的类型标识
 */
@property(nonatomic,assign,readonly)int type;
/**
 设备状态
 */
@property(nonatomic)DeviceState deviceState;

@property(nonatomic,copy)NSString *dataStr;

@property(nonatomic,copy)  NSString            *macStr;

@end
