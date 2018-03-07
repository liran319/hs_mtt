//
//  MTT_DeviceFactory.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_DeviceFactory.h"
#import "MTT_DeviceTabletopModel.h"
#import "MTT_DeviceOrnamentsModel.h"
#import "MTT_DevicePassengerFlowModel.h"
#import "MTT_BaseDeviceModel+private.h"
@implementation MTT_DeviceFactory
+(instancetype)deviceFactory{
    static MTT_DeviceFactory *factiry = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{factiry = [[MTT_DeviceFactory alloc] init];});
    return factiry;

}
-(MTT_BaseDeviceModel*)getDeviceInfo:(NSString*)dataStr deviceId:(int)deviceID version:(NSString*)version{
   
    MTT_BaseDeviceModel *model = nil;
    
    if (deviceID==40) {
      model =  [MTT_DeviceTabletopModel getModelFormDataStr:dataStr withVersion:version];
    }else if (deviceID==41){
       model = [MTT_DeviceOrnamentsModel getModelFormDataStr:dataStr withVersion:version];
    }else if (deviceID==42){
     
        model =  [MTT_DevicePassengerFlowModel getModelFormDataStr:dataStr withVersion:version];
    }else{
      model =nil;
    }

    return model;
}

-(MTT_BaseDeviceModel*)scanDeviceInfo:(NSString*)dataStr deviceId:(int)deviceID version:(NSString*)version{
    
    MTT_BaseDeviceModel *model = nil;
    
    if (deviceID==40) {
        model =  [MTT_DeviceTabletopModel scanModelFormDataStr:dataStr withVersion:version];
    }else if (deviceID==41){
        model = [MTT_DeviceOrnamentsModel scanModelFormDataStr:dataStr withVersion:version];
    }else if (deviceID==42){
        model =  [MTT_DevicePassengerFlowModel scanModelFormDataStr:dataStr withVersion:version];
    }else{
        model =nil;
    }
    
   return model;
}



    
  

@end
