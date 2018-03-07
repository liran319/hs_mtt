//
//  MTT_DeviceAcrossModel.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/4/12.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_DevicePassengerFlowModel.h"
#import "MTT_deviceDataTools.h"
static NSMutableDictionary *_deviceDic;

static NSMutableDictionary *_deviceTimeDic;

@interface MTT_DevicePassengerFlowModel()
@property(nonatomic,assign)NSInteger           number;
//@property(nonatomic,copy)  NSString          *macStr;
@property(nonatomic,copy)  NSString            *verson;
@end
@implementation MTT_DevicePassengerFlowModel
+(void)initialize{
    _deviceDic = [NSMutableDictionary dictionary];
    _deviceTimeDic = [NSMutableDictionary dictionary];
}
+(NSString*)Tag{
    return @"42";
}
+(MTT_DevicePassengerFlowModel*)getModelFormDataStr:(NSString*)str withVersion:(NSString*)version{
    MTT_DevicePassengerFlowModel *model  = [[MTT_DevicePassengerFlowModel alloc]init];
    
    model.verson                = version;
    
    NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];
    
    model.macStr                = macStr;
    
    NSString *dataStateStr         = [str substringWithRange:NSMakeRange(str.length-4, 2)];
    int dataState =[MTT_deviceDataTools mtt_getIntValueFromHexString:dataStateStr];
    model.number                = dataState;
//    NSLog(@"str==%@==%zd",str,dataState);

    
    NSString *devStateStr           = [str substringWithRange:NSMakeRange(str.length-2, 2)];
    int devState = [MTT_deviceDataTools mtt_getIntValueFromHexString:devStateStr];
    model.deviceState           =  devState;
    
    model.dataStr = str;

    //  计算差值
    if (![_deviceDic valueForKey:macStr]) {
        
        [_deviceDic setValue:@(model.number) forKey:macStr];
        
        model.number =1;
        if (model.deviceState != DeviceStateNormal) {
            double currTime = [[NSDate date]timeIntervalSince1970];
            
            if (![_deviceTimeDic valueForKey:macStr]) {
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
                
            }else{
                NSNumber *timeValue = [_deviceTimeDic valueForKey:macStr];
                if (timeValue && currTime-timeValue.doubleValue<20 && currTime-timeValue.doubleValue>0) {
                    return nil;
                }
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
            }
            return model;
        }

    }else{
        
        if (model.deviceState != DeviceStateNormal) {
            double currTime = [[NSDate date]timeIntervalSince1970];
            
            if (![_deviceTimeDic valueForKey:macStr]) {
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
                
            }else{
                NSNumber *timeValue = [_deviceTimeDic valueForKey:macStr];
                if (timeValue && currTime-timeValue.doubleValue<20 && currTime-timeValue.doubleValue>0) {
                    return nil;
                }
                [_deviceTimeDic setValue:@(currTime) forKey:macStr];
            }
            return model;
        }
        
        NSNumber *value = [_deviceDic valueForKey:macStr];
        
        if (value && value.intValue>=0) {
            
            if (value.intValue==model.number) {
                return nil;
            }
            
//            NSLog(@"deviceState==%zd==%zd",model.number,value.intValue);
            
            if (value.intValue<model.number) {
                model.number = model.number-value.intValue;
            }else{
                model.number = 255 - value.intValue + model.number;
            }
            
        }
        
        [_deviceDic setValue:@(dataState) forKey:macStr];
        
    }

   
    
    return model;

}
+(MTT_DevicePassengerFlowModel*)scanModelFormDataStr:(NSString*)str withVersion:(NSString*)version{
    
    MTT_DevicePassengerFlowModel *model  = [[MTT_DevicePassengerFlowModel alloc]init];
    
    model.verson                = version;
    
    NSString *macStr            = [str substringWithRange:NSMakeRange(8, 12)];
    
    model.macStr                = macStr;
    
    NSString *dataState         = [str substringWithRange:NSMakeRange(str.length-4, 2)];
    model.number                = dataState.intValue;
    
    NSString *devState          = [str substringWithRange:NSMakeRange(str.length-2, 2)];
    model.deviceState           =  devState.intValue;
    
    
    return model;
}
-(NSString *)tag{
    return [MTT_DevicePassengerFlowModel Tag];
}
+(NSString*)VTagWith:(NSString*)version
{
    return [MTT_DevicePassengerFlowModel Tag];;
}
-(NSString*)getMacStr{
    return self.macStr;
}
-(int)type{
    return [MTT_DevicePassengerFlowModel Tag].intValue-40;
}
@end
