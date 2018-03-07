//
//  MTT_deviceDataTools.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/3/24.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "MTT_deviceDataTools.h"
static NSInteger deviceState;
@implementation MTT_deviceDataTools
+(void)initialize{
    deviceState = 0;
}
//+(Mtt_PeripheralModel*)mtt_DeviceModelWith:(NSDictionary *)advertisementData peripheral:(CBPeripheral *)peripheral
//{
//    if ([advertisementData objectForKey:@"kCBAdvDataManufacturerData"]) {
//        
//        NSString *manufacturerDataString = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
//        
//        NSString *manufacturerDataValueString = [manufacturerDataString substringWithRange:NSMakeRange(1, manufacturerDataString.length-2)];
//        
//        //如果外设是MTT的产品
//        
//        if ([[manufacturerDataValueString substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"1112"]) {
//            
//            
//            NSString *deviceID = [manufacturerDataValueString substringWithRange:NSMakeRange(4, 2)];
//           
//
//            if (deviceID.intValue==40) {
//                 NSLog(@"manufacturerDataValueString==%@",manufacturerDataValueString);
//
//                manufacturerDataValueString = [manufacturerDataValueString stringByReplacingOccurrencesOfString:@" " withString:@""];
//                
//                Mtt_PeripheralModel *model  = [[Mtt_PeripheralModel alloc]init];
//                
//                model.peripheral            =  peripheral;
//                model.verson                = [manufacturerDataValueString substringWithRange:NSMakeRange(6, 2)];
//                
//                NSString *macStr            = [manufacturerDataValueString substringWithRange:NSMakeRange(8, 12)];
//                
//                model.macStr                = macStr;
//                
//                NSString *devState          = [manufacturerDataValueString substringWithRange:NSMakeRange(manufacturerDataValueString.length-2, 2)];
//                model.deviceState           =  devState.intValue;
//
//                if (model.deviceState==0) {
//                    
//                    deviceState=0;
//                }
//                
//                if (model.deviceState==3 && deviceState==0) {
//                    model.deviceState = 3;
//                    deviceState = 3;
//                }else{
//                    model.deviceState = 0;
//                }
//                
//                NSString *dataState         = [manufacturerDataValueString substringWithRange:NSMakeRange(manufacturerDataValueString.length-4, 2)];
//                model.dataState             = dataState.intValue;
//                
//                model.scanDate              =  [[NSDate date]timeIntervalSince1970];
//                
//                return model;
//            }else{
//                return nil;
//            }
//            
//        }
//    }
//    return nil;;
//}

+(NSDictionary*)mtt_receiveEletricDataValue:(NSData*)dataValue{
    
    NSString *str = [NSString stringWithFormat:@"%@",dataValue];
    NSString *valueStr = [str substringWithRange:NSMakeRange(1, 2)];
    int intvalue = [MTT_deviceDataTools mtt_getIntValueFromHexString:valueStr];
    NSString * eletric = [NSString stringWithFormat:@"%d",intvalue];
    
    return @{@"eletric":eletric};
}
+(NSDictionary*)mtt_setAsyncDataBaseInfo:(NSData*)dataValue{
    NSString *str = [NSString stringWithFormat:@"%@",dataValue];
    NSString *tarStr = [str substringWithRange:NSMakeRange(1, str.length-2)];
    tarStr = [tarStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (tarStr.length==12) {
        //        NSLog(@"tarStr===%@",tarStr);
        NSString* asyncDataStr = [tarStr substringWithRange:NSMakeRange(0, 4)];
        int intvalue = [MTT_deviceDataTools mtt_getIntValueFromHexString:asyncDataStr];
        
        NSString* timeStr = [tarStr substringWithRange:NSMakeRange(4, 4)];
        int timeCount = [MTT_deviceDataTools mtt_getIntValueFromHexString:timeStr];
        
        NSString* passStr = [tarStr substringWithRange:NSMakeRange(8, 4)];
        int passCount = [MTT_deviceDataTools mtt_getIntValueFromHexString:passStr];
        //        NSLog(@"--%zd---%zd----%zd--",intvalue,timeCount,passCount );
        
        return @{@"dataCount":@(intvalue),@"timeCount":@(timeCount),@"passCount":@(passCount)};
    }
    return nil;
}
//获取设备的状态码
+(NSDictionary*)mtt_getStateWithDataValue:(NSData*)dataValue{
    NSString *str = [NSString stringWithFormat:@"%@",dataValue];
    NSString *tarStr = [str substringWithRange:NSMakeRange(1, str.length-2)];
    tarStr = [tarStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (tarStr.length==12) {
        //        NSLog(@"tarStr===%@",tarStr);
        NSString* asyncDataStr = [tarStr substringWithRange:NSMakeRange(0, 2)];
        int intvalue = [MTT_deviceDataTools mtt_getIntValueFromHexString:asyncDataStr];
        
        
        return @{@"state":@(intvalue)};
    }
    return nil;
}


+(NSArray *)mtt_computeTheTimeDifferenceArray:(NSData*)dataValue{
    
    NSString *str = [NSString stringWithFormat:@"%@",dataValue];
    NSString *tarStr = [str substringWithRange:NSMakeRange(9, str.length-10)];
    tarStr = [tarStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (tarStr.length>=8) {
        NSMutableArray *timeA = [[NSMutableArray alloc]init];
        
        for (int i=0; i<tarStr.length/8; i++) {
            NSString *beginTime = [tarStr substringWithRange:NSMakeRange(i*8, 4)];
            NSString *endTime = [tarStr substringWithRange:NSMakeRange(i*8+4, 4)];
            
            int beginCount = [MTT_deviceDataTools mtt_getIntValueFromHexString:beginTime];
            
            int endCount = [MTT_deviceDataTools mtt_getIntValueFromHexString:endTime];
            
            [timeA addObject:@(endCount-beginCount)];
        }
        return timeA;
    }
    return nil;
}
+(NSInteger)mtt_getBroadcastDurtion:(NSInteger)count{
    NSInteger durtion=30;
    
    if (count<=10) {
        durtion  = 10;
    }else if (count>=150){
        durtion = 30;
    }else{
        durtion = (int)count*0.25/1+10;
//        NSLog(@"shujudaxiao===%zd",durtion);
    }
    return durtion;
}
+(NSString*)mtt_uuid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}
//16进制字符串转10进制数
+(int)mtt_getIntValueFromHexString:(NSString*)str
{
    int result = 0;
    NSString *compareString = @"0123456789abcdef";
    
    for (int x = 0; x < str.length; x++)
    {
        NSString *subString = [str substringWithRange:NSMakeRange(x, 1)];
        NSInteger index = [compareString rangeOfString:subString].location;
        long z = pow(16, ((int)str.length - 1 - x));
        result += z*index;
    }
    int a = (int)(short)(result);
    return a;
}

@end
