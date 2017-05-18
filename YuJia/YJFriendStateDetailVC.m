//
//  YJFriendStateDetailVC.m
//  YuJia
//
//  Created by 万宇 on 2017/5/9.
//  Copyright © 2017年 wylt_ios_1. All rights reserved.
//

#import "YJFriendStateDetailVC.h"
#import "BRPlaceholderTextView.h"
#import "UIColor+colorValues.h"
#import "UILabel+Addition.h"
#import "YJFriendStateTableViewCell.h"
#import "YJFriendLikeFlowLayout.h"
#import "YJFriendLikeCollectionViewCell.h"
#import "YJFriendCommentTableViewCell.h"
#import "YJSelfReplyTableViewCell.h"
#import "YJPhotoDisplayCollectionViewCell.h"
#import <HUPhotoBrowser.h>
#import "YJFriendStateLikeModel.h"
#import "YJFriendStateCommentModel.h"
#import <UIImageView+WebCache.h>

static NSString* tableCell = @"table_cell";
static NSString* commentCell = @"comment_cell";
static NSString* photoCellid = @"photo_cell";
static NSString* friendCommentCellid = @"friendComment_cell";
static NSString* selfReplyCellid = @"selfReply_cell";
@interface YJFriendStateDetailVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)UITableView *commentTableView;
@property(nonatomic,weak)UIButton *typeBtn;
@property(nonatomic,weak)BRPlaceholderTextView *contentView;
@property(nonatomic, strong)NSString *content;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property(nonatomic,weak)UICollectionView *collectionView;
@property(nonatomic,weak)UIView *backView;
@property(nonatomic,weak)UIView *selectView;
//评论
@property(weak, nonatomic)BRPlaceholderTextView *commentField;
@property(nonatomic, strong)NSMutableArray *commentList;
@property(nonatomic, strong)NSMutableArray *likeList;
@property(nonatomic,weak)UIView *fieldBackView;
@end

@implementation YJFriendStateDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"友邻圈";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = false;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:15],
       NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    int i = 1;
    if (i) {
        //添加右侧发送按钮
        UIButton *deleateBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
        [deleateBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleateBtn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        deleateBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        deleateBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -30);
//        postBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        deleateBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleateBtn addTarget:self action:@selector(informationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:deleateBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    //添加大tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
    }];
    [tableView registerClass:[YJFriendStateTableViewCell class] forCellReuseIdentifier:tableCell];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate =self;
    tableView.dataSource = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 235*kiphone6;

}
-(void)setModel:(YJFriendNeighborStateModel *)model{
    _model = model;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self loadData];
}
-(void)loadData{
http://192.168.1.55:8080/smarthome/mobileapi/state/findStateOne.do?token=EC9CDB5177C01F016403DFAAEE3C1182
//    &stateId=1
    [SVProgressHUD show];// 动画开始
    NSString *statesUrlStr = [NSString stringWithFormat:@"%@/mobileapi/state/findStateOne.do?token=%@&stateId=%ld",mPrefixUrl,mDefineToken1,self.model.info_id];
    [[HttpClient defaultClient]requestWithPath:statesUrlStr method:0 parameters:nil prepareExecute:^{
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];// 动画结束
        if ([responseObject[@"code"] isEqualToString:@"0"]) {
            NSDictionary *bigDic = responseObject[@"result"];
            NSArray *likeArr = bigDic[@"likeNum"];
            NSMutableArray *likemArr = [NSMutableArray array];
            for (NSDictionary *dic in likeArr) {
                YJFriendStateLikeModel *infoModel = [YJFriendStateLikeModel mj_objectWithKeyValues:dic];
                [likemArr addObject:infoModel];
            }
            self.likeList = likemArr;//解析点赞数据
            NSArray *commentArr = bigDic[@"comment"];
            NSMutableArray *commentmArr = [NSMutableArray array];
            for (NSDictionary *dic in commentArr) {
                YJFriendStateCommentModel *infoModel = [YJFriendStateCommentModel mj_objectWithKeyValues:dic];
                [commentmArr addObject:infoModel];
            }
            self.commentList = commentmArr;//解析评论数据
            [self setupCommentTableView];
        }else if ([responseObject[@"code"] isEqualToString:@"-1"]){

            [SVProgressHUD showErrorWithStatus:responseObject[@"message"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];// 动画结束
        return ;
    }];
 
}
-(void)setupCommentTableView{
    //评论tableView中的头部试图
    UIView *commentHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 354*kiphone6, 45*kiphone6)];
    commentHeaderView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    UIImageView *heaterView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blue-like"]];
    heaterView.frame = CGRectMake(27*kiphone6, 5*kiphone6, 11*kiphone6, 11*kiphone6);
    [commentHeaderView addSubview:heaterView];

    //photoCollectionView
    UICollectionView *likeCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[[YJFriendLikeFlowLayout alloc]init]];
    likeCollectionView.frame = CGRectMake(46*kiphone6, 0, 300*kiphone6, 45*kiphone6);
    [commentHeaderView addSubview:likeCollectionView];

    self.collectionView = likeCollectionView;
    likeCollectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    likeCollectionView.dataSource = self;
    likeCollectionView.delegate = self;
    // 注册单元格
    [likeCollectionView registerClass:[YJFriendLikeCollectionViewCell class] forCellWithReuseIdentifier:photoCellid];
    likeCollectionView.showsHorizontalScrollIndicator = false;
    likeCollectionView.showsVerticalScrollIndicator = false;
    
    //添加大tb尾部视图中的评论tableView
    UIView *footBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 354*kiphone6, kScreenH)];
    footBackView.backgroundColor = [UIColor whiteColor];
    UITableView *commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(10*kiphone6, 0, 354*kiphone6, kScreenH)];
    [footBackView addSubview:commentTableView];

    self.commentTableView = commentTableView;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    [commentTableView registerClass:[YJFriendCommentTableViewCell class] forCellReuseIdentifier:friendCommentCellid];
    [commentTableView registerClass:[YJSelfReplyTableViewCell class] forCellReuseIdentifier:selfReplyCellid];
    commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    commentTableView.delegate =self;
    commentTableView.dataSource = self;
    commentTableView.rowHeight = UITableViewAutomaticDimension;
    commentTableView.estimatedRowHeight = 38*kiphone6;
    self.tableView.tableFooterView = footBackView;
    commentTableView.tableHeaderView = commentHeaderView;
    
    //评论框
//    UIView *fieldBackView = [[UIView alloc]initWithFrame:CGRectMake(20,self.view.frame.size.height- 110*kiphone6, self.view.frame.size.width-40*kiphone6, 45*kiphone6)];
    UIView *fieldBackView = [[UIView alloc]init];
    self.fieldBackView = fieldBackView;
    
    [self.view addSubview:fieldBackView];
    [self.view bringSubviewToFront:fieldBackView];
    [fieldBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20*kiphone6);
        make.right.offset(-20*kiphone6);
        make.bottom.offset(0);
        make.height.offset(45*kiphone6);
    }];
    [fieldBackView layoutIfNeeded];
    //键盘的Frame改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //输入框
    BRPlaceholderTextView *commentField = [[BRPlaceholderTextView alloc]init];
    [fieldBackView addSubview:commentField];
    [commentField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
    commentField.delegate = self;
    commentField.returnKeyType = UIReturnKeySend;
    self.commentField = commentField;
    commentField.placeholder = @"评论";
    commentField.font=[UIFont boldSystemFontOfSize:14];
    [commentField setBackgroundColor:[UIColor whiteColor]];
    [commentField setPlaceholderFont:[UIFont systemFontOfSize:15]];
    [commentField setPlaceholderColor:[UIColor colorWithHexString:@"999999"]];
    [commentField setPlaceholderOpacity:0.6];
    [commentField addMaxTextLengthWithMaxLength:200 andEvent:^(BRPlaceholderTextView *text) {
        [self.commentField endEditing:YES];
        
        NSLog(@"----------");
    }];
    [commentField addTextViewBeginEvent:^(BRPlaceholderTextView *text) {
        NSLog(@"begin");
        [self textViewDidChange:self.commentField];
    }];
    [commentField addTextViewEndEvent:^(BRPlaceholderTextView *text) {
        NSLog(@"end");
    }];
    //边框宽度
    [commentField.layer setBorderWidth:1];
    commentField.layer.borderColor=[UIColor colorWithHexString:@"#f3f3f3"].CGColor;
}
#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.tableView == tableView) {
        return 1;
    }
    return self.commentList.count;//根据请求回来的数据定
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView == tableView) {
    
    YJFriendStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCell forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }
    WS(ws);
    YJFriendStateCommentModel *model = self.commentList[indexPath.row];
    if (model.coverPersonalId == 0) {//判断是用户评论还是自己回复评论
        YJFriendCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendCommentCellid forIndexPath:indexPath];
        cell.model = model;
        
        cell.clickBtnBlock = ^(NSString *str){
            NSRange range = [str rangeOfString:@"{"];
            NSString *strs = [str substringToIndex:range.location];
            [ws.commentField setPlaceholder:[NSString stringWithFormat:@"回复 %@:",strs]];
            [ws.commentField becomeFirstResponder];
        };
        if (indexPath.row==0) {
            cell.iconView.hidden = false;
        }
        return cell;
    }else{
        YJSelfReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selfReplyCellid forIndexPath:indexPath];
        cell.model = model;
        cell.clickBtnBlock = ^(NSString *str){
            NSRange range = [str rangeOfString:@"{"];
            NSString *strs = [str substringToIndex:range.location];
            [ws.commentField setPlaceholder:[NSString stringWithFormat:@"回复 %@:",strs]];
            [ws.commentField becomeFirstResponder];
        };
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return UITableViewAutomaticDimension;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.commentTableView == tableView) {
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 354*kiphone6, 5*kiphone6)];
        footerView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
        return footerView;
    }
   return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.commentTableView == tableView) {
        
        return 5*kiphone6;
    }
    return 0.0f;
}
#pragma mark - UICollectionView
// 有多少行
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.likeList.count;
}

// cell内容
- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    // 去缓存池找
    YJFriendLikeCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellid forIndexPath:indexPath];
    YJFriendStateLikeModel *model = self.likeList[indexPath.row];
    NSString *iconUrlStr = [NSString stringWithFormat:@"%@%@",mPrefixUrl,model.avatar];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:iconUrlStr] placeholderImage:[UIImage imageNamed:@"icon"]];
    return cell;
    
}
// cell点击事件
- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
//    YJFriendLikeCollectionViewCell *cell = (YJFriendLikeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    UIImage *image = [UIImage imageNamed:@"house_repair"];
//    NSArray *imageArr = @[image,image,image,image,image];
//    [HUPhotoBrowser showFromImageView:cell.imageView withImages:imageArr atIndex:indexPath.row];
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti{
    
    //从userInfo里面取出来键盘最终的位置
    NSValue *rectValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rect = [rectValue CGRectValue];
    CGRect rectField = self.fieldBackView.frame;
    CGRect newRect = CGRectMake(rectField.origin.x, rect.origin.y - rectField.size.height-64*kiphone6, rectField.size.width, rectField.size.height) ;
    [UIView animateWithDuration:0.25 animations:^{
        self.fieldBackView.frame = newRect;
    }];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 500){
        
        if (location != NSNotFound){
            
            [textView resignFirstResponder];
        }
        return NO;
        
    }  else if (location != NSNotFound){
        
        [textView resignFirstResponder];
        if (textView.text!=nil&&![textView.text isEqualToString:@""]) {
//            //            http://192.168.1.55:8080/yuyi/comment/AddConment.do?telephone=18782931355&content_id=1&Content=haha
//            NSString *urlStr = [NSString stringWithFormat:@"%@/comment/AddConment.do?telephone=%@&content_id=%@&Content=%@",mPrefixUrl,telePhoneNumber,self.info_id,[textView.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
//            [SVProgressHUD show];// 动画开始
//            [[HttpClient defaultClient]requestWithPath:urlStr method:HttpRequestPost parameters:nil prepareExecute:^{
//                
//            } success:^(NSURLSessionDataTask *task, id responseObject) {
//                if ([responseObject[@"code"] isEqualToString:@"0"]) {
//                    //更新评论数据源
//                    NSString *urlStr = [NSString stringWithFormat:@"%@/comment/getConmentAll.do?id=%@&start=0&limit=6",mPrefixUrl,self.info_id];
//                    [[HttpClient defaultClient]requestWithPath:urlStr method:0 parameters:nil prepareExecute:^{
//                        
//                    } success:^(NSURLSessionDataTask *task, id responseObject) {
//                        [SVProgressHUD dismiss];//结束动画
//                        NSArray *arr = responseObject[@"result"];
//                        NSMutableArray *mArr = [NSMutableArray array];
//                        for (NSDictionary *dic in arr) {
//                            YYCommentInfoModel *infoModel = [YYCommentInfoModel mj_objectWithKeyValues:dic];
//                            [mArr addObject:infoModel];
//                        }
//                        self.commentInfoModels  = mArr;
//                        if (self.commentInfoModels.count>0) {
//                            start = self.commentInfoModels.count;
//                        }//更新加载起始位置
//                        NSInteger count = [self.commentCountLabel.text integerValue];
//                        count += 1;
//                        self.commentCountLabel.text = [NSString stringWithFormat:@"%ld",count];//评论数加一
//                        [self.tableView reloadData];
//                        self.commentField.text = nil;
//                        self.commentField.placeholder = @"说点什么吧";
//                        self.commentField.imagePlaceholder = @"writing";
//                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                        [SVProgressHUD showErrorWithStatus:@"评论已上传,请下拉刷新"];
//                        return ;
//                    }];
//                }else{
//                    [SVProgressHUD showErrorWithStatus:@"评论未成功，请稍后再试"];
//                }
//            } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                [SVProgressHUD showErrorWithStatus:@"评论未成功，请稍后再试"];
//                return ;
//            }];
        
        }else{
            [self showAlertWithMessage:@"评论内容不能为空，请重新输入"];
        }
        return NO;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<45*kiphone6) {
        size.height = 45*kiphone6;
    }
    if (size.height>85*kiphone6) {
        size.height = 85*kiphone6;
        textView.scrollEnabled = true;   // 允许滚动
        textView.frame = CGRectMake(frame.origin.x, frame.origin.y-(size.height-frame.size.height), frame.size.width, size.height);
        return;
    }
    textView.scrollEnabled = false;   // 不允许滚动
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y-(size.height-frame.size.height), frame.size.width, size.height);
 
}
//弹出alert
-(void)showAlertWithMessage:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    //            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    //            [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
