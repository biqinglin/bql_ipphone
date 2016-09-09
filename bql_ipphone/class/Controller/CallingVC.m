//
//  CallingVC.m
//  bql_ipphone
//
//  Created by hao 好享购 on 16/7/15.
//  Copyright © 2016年 hao 好享购. All rights reserved.
//

#import "CallingVC.h"
#import "BQLIPPManager.h"

static NSTimer *timer;

@interface CallingVC ()

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *callStatusBtn;

@end

@implementation CallingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        timer = 0;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callReleasedEvent) name:kBQLCallReleased object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingEvent) name:kBQLCalling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callConnectedEvent) name:kBQLCallConnected object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self cancelTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.phoneNumberLabel.text = self.phoneNumber;
    [[BQLIPPManager InstanceIPPManager] call:self.phoneNumber displayName:@"" transfer:NO];
}

- (IBAction)hangup:(id)sender {
    
    [[BQLIPPManager InstanceIPPManager] hanUpCall];
    [self callReleasedEvent];
}

// 通话已挂断
- (void)callReleasedEvent {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 正在接通
- (void)callingEvent {
    
    [self.callStatusBtn setTitle:@"取消" forState:0];
    self.callStatusLabel.text = @"正在呼叫...";
}

// 通话已建立
- (void)callConnectedEvent {
    
    [self.callStatusBtn setTitle:@"挂断" forState:0];
    self.callStatusLabel.text = @"00:00";
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callDurationUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}

- (void)callDurationUpdate {
    
    int duration = [[BQLIPPManager InstanceIPPManager] getCallDuration];
    if (duration != 0) {
        
        self.callStatusLabel.text = [NSString stringWithFormat:@"%@",[BQLIPPManager durationToString:duration]];
    }
}

- (void)cancelTimer {
    
    [timer invalidate];
    timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
