//
//  ViewController.m
//  MTT_SDK
//
//  Created by IDAGE on 2017/3/6.
//  Copyright © 2017年 IDAGE. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVOSCloud/AVOSCloud.h>

#import "MTTSensorSDK.h"
@interface ViewController ()<UITextViewDelegate>
@property(nonatomic,strong)NSMutableArray *deviceArray;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic,copy)NSString *textStr;
@end

@implementation ViewController
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}
-(NSMutableArray *)deviceArray{
    if (_deviceArray==nil) {
        _deviceArray = [[NSMutableArray alloc]init];
    }
    return _deviceArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //添加蓝牙状态监听
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(mtt_blueStateChanged:) name:MTT_NOBLESTATUSCHANGE object:nil];
}
- (IBAction)didClickSacnDeviceBU:(id)sender {

//    self.textStr = @"";
//
//    [MTT_BLE_SHARED mtt_scanPeripheralsRespond:^(NSString *macStr, int rssi,MTTDeviceType type) {
//        NSLog(@"macStr==%@===rss==%d==%zd",macStr,rssi,type);
//
//
//        if (type==K_MTTDeviceTypeTableTop) {
//            //摆式传感器
//        }else if (type==K_MTTDeviceTypeOrnaments){
//            //挂式传感器
//        }else{
//            //客流传感器
//        }
//        NSString *currenStateStr = [NSString stringWithFormat:@"macStr:%@  rssi:%d==%zd\n",macStr,rssi,type];
//
//        if (self.textStr) {
//            self.textStr = [self.textStr stringByAppendingString:currenStateStr];
//        }else{
//            self.textStr = currenStateStr;
//        }
//        self.textView.text =self.textStr;
//
//        [self.deviceArray addObject:macStr];
//    } failure:^(id error) {
//        NSLog(@"error==%@",error);
//    }];

}

- (IBAction)didClickLissonAsyncInfoBU:(id)sender {
    self.textStr = @"";

    [MTT_BLE_SHARED mtt_scanPeripheralsWithMacStrArray:nil Respond:^(NSString *macStr,int rssi,NSInteger state, MTT_BaseDeviceModel* model) {

        NSString *modelConten = @"";
        if (state == K_MTTDeviceStateNormal){
            //设备正常有数据，需处理数据

            if (model.type==K_MTTDeviceTypeTableTop) {
                MTT_DeviceTabletopModel *cModel =(MTT_DeviceTabletopModel*)model;
                NSLog(@"摆式传感器macStr %zd", model.macStr);
                NSLog(@"摆式传感器状态%zd",cModel.state);

                AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
                [testObject setObject:@"bar" forKey:@"foo"];
                [testObject save];

                if (cModel.state==DevicePickedStateUp) {
                    modelConten = [NSString stringWithFormat:@"摆式传感器状态:拿起"];
                }else if (cModel.state==DevicePickedStateDown){
                    modelConten = [NSString stringWithFormat:@"摆式传感器状态:放下"];
                }else{
                    return ;
                }
//                modelConten = [NSString stringWithFormat:@"摆式传感器状态%zd",cModel.state];
                //摆式传感器
            }else if (model.type==K_MTTDeviceTypeOrnaments){
                //挂式传感器
                MTT_DeviceOrnamentsModel *cModel =(MTT_DeviceOrnamentsModel*)model;
//                NSLog(@"挂式传感器状态%zd",cModel.number);
                if (cModel.state==DeviceOrnamentStateUp) {
                    modelConten = [NSString stringWithFormat:@"挂式传感器状态:拿起"];
                }else if (cModel.state==DeviceOrnamentStateDown){
                     modelConten = [NSString stringWithFormat:@"挂式传感器状态:放下"];
                }else{
                    return ;
                }

            }else{
                //客流传感器
                MTT_DevicePassengerFlowModel *cModel =(MTT_DevicePassengerFlowModel*)model;
                NSLog(@"客流传感器状态%zd",cModel.number);
                modelConten = [NSString stringWithFormat:@"客流传感器状态%zd",cModel.number];
            }

        }else if (state == K_MTTDeviceStateElectricLow){
            //电量低，不需要处理数据
            return ;
        }else if (state == K_MTTDeviceStateHeartbeat) {
            //心跳包，说明设备正常，但是不做数据处理
            return ;
        }else{
            return;//未知
        }

        NSLog(@"macStr==%@,state==%zd==%@",macStr,state,modelConten);

        NSString *currenStateStr = [NSString stringWithFormat:@"MAC:%@ %@\n",macStr,modelConten];

        if (self.textStr) {
            self.textStr = [self.textStr stringByAppendingString:currenStateStr];
        }else{
            self.textStr = currenStateStr;
        }
        self.textView.text =self.textStr;

    } failure:^(id error) {

        NSLog(@"error==%@",error);

    }];



}
- (IBAction)didClickStopScanBU:(id)sender {

    //停止扫描所有设备
    [MTT_BLE_SHARED mtt_stopScanPeriphals];

}

-(void)mtt_blueStateChanged:(NSNotification*)cender{
    NSNumber *obj =  cender.object;
    if (obj.integerValue==K_MTTCBManagerStatePoweredOn) {
        NSLog(@"MTT_蓝牙已经打开");

    }else{
        NSLog(@"MTT_蓝牙没有打开");
    }
}
@end


/*
 // Do any additional setup after loading the view, typically from a nib.
 NSString *mac = @"c8:e0:eb:5a:e0:69";

 NSString *enStr = [self macStrEncrypt:mac];
 NSLog(@"jiami===%@",enStr);
 NSLog(@"jiami===%@",[self macStrDecrypt:enStr]);

 }
 //加密
 -(NSString*)macStrEncrypt:(NSString*)macStr{

 NSArray *itemArray = [macStr componentsSeparatedByString:@":"];

 return  [[self reverseArray:[itemArray mutableCopy] K:3]componentsJoinedByString:@":"];
 }
 //解密
 -(NSString*)macStrDecrypt:(NSString*)macStr{

 NSArray *itemArray = [macStr componentsSeparatedByString:@":"];

 return [[self reverseArray:[itemArray mutableCopy] K:itemArray.count-3]componentsJoinedByString:@":"];
 }

 -(NSArray*)reverseArray:(NSMutableArray*)dataA K:(NSInteger)k{

 //反转数组 数组 开始位置 结束位置
 void (^reverse)(NSMutableArray *,NSInteger ,NSInteger )=^(NSMutableArray * A,NSInteger start,NSInteger end){
 while (start<end) {
 id temp = A[start];
 A[start] = A[end];
 A[end]   = temp;
 start++;
 end--;

 }
 };

 if (!dataA || k>=dataA.count) {
 return dataA;
 }
 reverse(dataA,0,dataA.count-1);
 reverse(dataA,0,k-1);
 reverse(dataA,k,dataA.count-1);

 return dataA;
 }
 */

