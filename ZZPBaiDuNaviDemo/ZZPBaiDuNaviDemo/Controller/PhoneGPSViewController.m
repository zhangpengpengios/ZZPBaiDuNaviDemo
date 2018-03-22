//
//  PhoneGPSViewController.m
//  ZZPBaiDuNaviDemo
//
//  Created by ZPP on 2018/3/22.
//  Copyright © 2018年 ZZP. All rights reserved.
//

#import "PhoneGPSViewController.h"
#import "BNCoreServices.h"
@interface PhoneGPSViewController ()<BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>

@end

@implementation PhoneGPSViewController

- (UIButton*)createButton:(NSString*)title target:(SEL)selector frame:(CGRect)frame
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }else
    {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"手机GPS导航";
    UILabel *startLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 30)];
    startLable.backgroundColor = [UIColor clearColor];
    startLable.text = @"起始位置";
    startLable.textAlignment = NSTextAlignmentCenter;
    //自动调整自己的宽度，保证与superView左边和右边的距离不变。
    startLable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:startLable];
    
    
    UILabel* endLabel = [[UILabel alloc] initWithFrame:CGRectMake(startLable.frame.origin.x, startLable.frame.origin.y+startLable.frame.size.height, self.view.frame.size.width, startLable.frame.size.height)];
    endLabel.backgroundColor = [UIColor clearColor];
    endLabel.text = @"终点";
    endLabel.textAlignment = NSTextAlignmentCenter;
    endLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:endLabel];
    // Do any additional setup after loading the view.
    
    CGSize buttonSize = {240,40};
    CGRect buttonFrame = {(self.view.frame.size.width-buttonSize.width)/2,40+endLabel.frame.size.height+endLabel.frame.origin.y,buttonSize.width,buttonSize.height};
    
    UIButton* realNaviButton = [self createButton:@"开始导航" target:@selector(realNavi:)  frame:buttonFrame];
    [self.view addSubview:realNaviButton];
    
    //设置白天黑夜模式
    //[BNCoreServices_Strategy setDayNightType:BNDayNight_CFG_Type_Auto];
    //设置停车场
    //[BNCoreServices_Strategy setParkInfo:YES];
    
    CLLocationCoordinate2D wgs84llCoordinate;
    //assign your coordinate here...
    
    CLLocationCoordinate2D bd09McCoordinate;
    //the coordinate in bd09MC standard, which can be used to show poi on baidu map
    bd09McCoordinate = [BNCoreServices_Instance convertToBD09MCWithWGS84ll: wgs84llCoordinate];
    
}

- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

//模拟导航
- (void)simulateNavi:(UIButton*)button
{
    if (![self checkServicesInited]) return;
    [self startNavi];
    
}

//真实GPS导航
- (void)realNavi:(UIButton*)button
{
    if (![self checkServicesInited]) return;
    [self startNavi];
}

- (void)startNavi
{
    BOOL useMyLocation = NO;
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    CLLocation *myLocation = [BNCoreServices_Location getLastLocation];
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    if (useMyLocation) {
        startNode.pos.x = myLocation.coordinate.longitude;
        startNode.pos.y = myLocation.coordinate.latitude;
        startNode.pos.eType = BNCoordinate_OriginalGPS;
    }
    else {
        startNode.pos.x = 113.948222;
        startNode.pos.y = 22.549555;
        startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    }
    [nodesArray addObject:startNode];
    
    //也可以在此加入1到3个的途经点
    
    BNRoutePlanNode *midNode = [[BNRoutePlanNode alloc] init];
    midNode.pos = [[BNPosition alloc] init];
    midNode.pos.x = 113.977004;
    midNode.pos.y = 22.556393;
    //midNode.pos.eType = BNCoordinate_BaiduMapSDK;
    //    [nodesArray addObject:midNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = 114.089863;
    endNode.pos.y = 22.546236;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    
    [nodesArray addObject:endNode];
    //关闭openURL,不想跳转百度地图可以设为YES
    [BNCoreServices_RoutePlan setDisableOpenUrl:YES];
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
    //导航中改变终点方法示例
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
     endNode.pos = [[BNPosition alloc] init];
     endNode.pos.x = 114.189863;
     endNode.pos.y = 22.546236;
     endNode.pos.eType = BNCoordinate_BaiduMapSDK;
     [[BNaviModel getInstance] resetNaviEndPoint:endNode];
     });*/
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary*)userInfo
{
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}


#pragma mark - 安静退出导航

- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (id)naviPresentedViewController {
    return self; //self必须是viewcontroller类型
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
