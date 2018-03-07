//
//  MTT_DeviceAcrossModel.h
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

/*人流传感器*/
#import "MTT_BaseDeviceModel.h"

@interface MTT_DevicePassengerFlowModel : MTT_BaseDeviceModel
/**
 经过设备的客流数
 */
@property(nonatomic,assign,readonly)NSInteger           number;
//@property(nonatomic,copy,readonly)  NSString            *macStr;
@property(nonatomic,copy,readonly)  NSString            *verson;
@end
