//
//  AnswerVC.m
//  bql_ipphone
//
//  Created by hao 好享购 on 16/7/15.
//  Copyright © 2016年 hao 好享购. All rights reserved.
//

#import "AnswerVC.h"
#import "BQLIPPManager.h"
#import "LinphoneManager.h"

static NSTimer *timer;

@interface AnswerVC ()

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *rejectCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *answerCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;


@end

@implementation AnswerVC

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
    self.hangupBtn.hidden = YES;
    self.answerCallBtn.hidden =  NO;
    self.rejectCallBtn.hidden = NO;
    // 检查铃声是否准备好播放
    bool isVideoEnable = linphone_call_params_video_enabled(linphone_call_get_current_params(self.incomeCall));
    NSLog(@"isVideoEnable %d ",isVideoEnable);
}

// 通话已建立
- (void)callConnectedEvent {
    
    self.answerTimeLabel.text = @"00:00";
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callDurationUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
}

- (void)callDurationUpdate {
    
    int duration = [[BQLIPPManager InstanceIPPManager] getCallDuration];
    if (duration != 0) {
        
        self.answerTimeLabel.text = [NSString stringWithFormat:@"%@",[BQLIPPManager durationToString:duration]];
    }
}

// 通话已挂断
- (void)callReleasedEvent {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)answerCall:(id)sender {
    
    self.hangupBtn.hidden = NO;
    self.answerCallBtn.hidden =  YES;
    self.rejectCallBtn.hidden = YES;
    [[BQLIPPManager InstanceIPPManager] answer:self.incomeCall];
}

- (IBAction)rejectCall:(id)sender {
    
    [[BQLIPPManager InstanceIPPManager] hanUpCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)hangup:(id)sender {
    
    [[BQLIPPManager InstanceIPPManager] hanUpCall];
    [self callReleasedEvent];
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
