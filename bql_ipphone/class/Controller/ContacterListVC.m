//
//  CallVC.m
//  bql_ipphone
//
//  Created by hao 好享购 on 16/7/15.
//  Copyright © 2016年 hao 好享购. All rights reserved.
//

#import "ContacterListVC.h"
#import "CallingVC.h"
#import "BQLIPPManager.h"
#import "AnswerVC.h"

#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>

// 屏幕尺寸
#define KWindowWidth ([UIScreen mainScreen].bounds.size.width)
#define KWindowHeight ([UIScreen mainScreen].bounds.size.height)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)

@interface ContacterListVC () <UITableViewDataSource,UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) UITableView *callTable;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ContacterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"拨号";
    
    [self setTable];
}

- (void)setTable {
    
    self.callTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KWindowWidth, KWindowHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.callTable];
    self.callTable.tableFooterView = [UIView new];
    self.callTable.rowHeight = 50;
    self.callTable.dataSource = self;
    self.callTable.delegate = self;
    
    self.dataSource = @[@"18012341234",@"18056785678",
                                        @"17012341234",@"17056785678",
                                        @"13012341234",@"13056785678",
                                        @"15000048476",@"17702041494",
                                        @"15214362421",@"100",
                                        @"13388691951",@"15988988674"];
    
    UIBarButtonItem *releaseButon=[[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStylePlain target:self action:@selector(contactList)];
    self.navigationItem.rightBarButtonItem=releaseButon;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier= @"call_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.detailTextLabel.text = @"拨号";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // http://60.12.105.222/api/subcalltask.php?caller=15214362421&called=18046712831
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择拨号方式"message:@"啦啦啦"preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *zhibo = [UIAlertAction actionWithTitle:@"直拨" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CallingVC *call = [[CallingVC alloc] init];
        call.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        call.phoneNumber = self.dataSource[indexPath.row];
        [self presentViewController:call animated:YES completion:nil];
    }];
    UIAlertAction *huibo = [UIAlertAction actionWithTitle:@"回拨" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL *url = [NSURL URLWithString:@"http://60.12.105.222/api/subcalltask.php?"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        NSString *body = [NSString stringWithFormat:@"caller=15214362421&called=%@",self.dataSource[indexPath.row]];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSLog(@"请求结果:%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        }];
        [task resume];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:zhibo];
    [alertController addAction:huibo];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    /*
    CallingVC *call = [[CallingVC alloc] init];
    call.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    call.phoneNumber = self.dataSource[indexPath.row];
    [self presentViewController:call animated:YES completion:nil];
    */
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger )buttonIndex {
    
    NSLog(@"%ld",buttonIndex);
}

- (void)contactList {
    
    NSLog(@"通讯录");
    ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
    nav.peoplePickerDelegate = self;
    if(IOS8_OR_LATER){
        nav.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    [self presentViewController:nav animated:YES completion:nil];
}

//取消选择
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    if ([phoneNO hasPrefix:@"+"]) {
        phoneNO = [phoneNO substringFromIndex:3];
    }
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"%@", phoneNO);
//    if (phone && [ZXValidateHelper checkTel:phoneNO]) {
//        phoneNum = phoneNO;
//        [self.tableView reloadData];
//        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
//        return;
//    }
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    if ([phoneNO hasPrefix:@"+"]) {
        phoneNO = [phoneNO substringFromIndex:3];
    }
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"%@", phoneNO);
//    if (phone && [ZXValidateHelper checkTel:phoneNO]) {
//        phoneNum = phoneNO;
//        [self.tableView reloadData];
//        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
//        return NO;
//    }
    return YES;
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
