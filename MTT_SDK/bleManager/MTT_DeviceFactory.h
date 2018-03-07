//
//  MTT_DeviceFactory.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTT_BaseDeviceModel.h"
@interface MTT_DeviceFactory : NSObject
/** 获得Runbone耳机数据工厂对象 */
+(instancetype)deviceFactory;

/**
 *  获得MTT设备数据对象
 *
 *  @param dataStr  获得的数据
 *  @param version 版本号
 *
 *  @return MTT设备数据对象
 */
-(MTT_BaseDeviceModel*)getDeviceInfo:(NSString*)dataStr deviceId:(int)deviceID version:(NSString*)version;

/**
 *  扫描设备获得MTT设备数据对象
 *
 *  @param dataStr  获得的数据
 *  @param version 版本号
 *
 *  @return MTT设备数据对象
 */
-(MTT_BaseDeviceModel*)scanDeviceInfo:(NSString*)dataStr deviceId:(int)deviceID version:(NSString*)version;
@end
