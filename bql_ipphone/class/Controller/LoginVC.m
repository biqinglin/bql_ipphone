//
//  LoginVC.m
//  bql_ipphone
//
//  Created by hao 好享购 on 16/7/15.
//  Copyright © 2016年 hao 好享购. All rights reserved.
//

#import "LoginVC.h"
#import "ContacterListVC.h"
#import "BQLIPPManager.h"

@interface LoginVC () <NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTextfiled;
@property (weak, nonatomic) IBOutlet UITextField *portTextfiled;
@property (weak, nonatomic) IBOutlet UITextField *accountTextfiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfiled;

//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@end

@implementation LoginVC

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatus:) name:kBQLLoginStatus object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录服务器";
    
//    // 公司需求：先登录后台 不然拨号失败 （敏感信息已去除）
//    NSURL *url = [NSURL URLWithString:@"**********"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    NSString *body = [NSString stringWithFormat:@"regnum=*********&regpwd=*******"];
//    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        NSXMLParser *par = [[NSXMLParser alloc]initWithData:data];
//        par.delegate = self;
//        [par parse];
//        
//        //id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        //NSLog(@"登录后台请求结果:%@", result);
//    }];
//    [task resume];
}

//开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"parserDidStartDocument...");
}

//准备节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    
    if([elementName isEqualToString:@"Ret"]) {
        
        self.currentElement = elementName;
    }
}

//获取节点内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if ([self.currentElement isEqualToString:@"Ret"]) {
        
        if([string integerValue] == 0) {
            NSLog(@"后台登录成功!");
        }
        else if ([string integerValue] == 1) {
            NSLog(@"后台登录失败!");
        }
        else if ([string integerValue] == 2) {
            NSLog(@"密码错误!");
        }
    }
}

//解析完一个节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    
    self.currentElement = @"";
}

//解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"parserDidEndDocument...");
}

-(void)loginStatus:(NSNotification *)sender{
    
    NSInteger status  = [sender.userInfo[@"status"] integerValue];
    if(status == BQLRegistrationOk) {
        
        NSLog(@"登录成功~~~");
    }
    else if (status == BQLRegistrationFailed) {
        
        NSLog(@"登录失败!!!");
    }
}

- (IBAction)login:(id)sender {
    
    if(self.addressTextfiled.text && self.portTextfiled.text && self.accountTextfiled.text && self.passwordTextfiled.text) {
        
        if([[BQLIPPManager InstanceIPPManager] addProxyConfig:self.accountTextfiled.text  password:self.passwordTextfiled.text DisplayName:@"" domain:self.addressTextfiled.text Port:self.portTextfiled.text withTransport:@"UDP"]) {
            
            ContacterListVC *call = [[ContacterListVC alloc] init];
            call.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            UINavigationController *nav= [[UINavigationController alloc]initWithRootViewController:call];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    else {
        
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"警告",nil)
                                                        message:NSLocalizedString(@"请将信息填写完整",nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定",nil)
                                              otherButtonTitles:nil ,nil];
        [error show];
    }
}

- (IBAction)logOut:(id)sender {
    
    [[BQLIPPManager InstanceIPPManager] logout];
}

// 注册
- (IBAction)register:(id)sender {
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
