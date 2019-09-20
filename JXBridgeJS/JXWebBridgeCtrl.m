//
//  JXWebBridgeCtrl.m
//  JXBridgeJS
//
//  Created by JosephXuan on 2019/9/20.
//  Copyright © 2019 JosephXuan. All rights reserved.
//

#import "JXWebBridgeCtrl.h"
#import <WebKit/WKWebView.h>//web
#import <WebKit/WebKit.h>//web
#import <AssetsLibrary/AssetsLibrary.h>//相册
#import <Photos/Photos.h>//相册
#import <CoreLocation/CoreLocation.h>//定位
@interface JXWebBridgeCtrl ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UIImagePickerControllerDelegate,UIAlertViewDelegate>


@property (nonatomic, strong) WKWebView *webView;
@property (strong, nonatomic) NSArray *JSArray;
@property (nonatomic,strong) UIProgressView *progressView;


/** 解决回退刷新问题 */
@property (strong, nonatomic) WKNavigation *backNavigation;


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>图片裁剪
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) NSMutableArray *selectedAssets;
/** 照片最多选择数 */
@property (copy, nonatomic) NSString *maxSeletedCount;
/** 上传 图片裁剪 宽 */
@property (copy, nonatomic) NSString *thirdStr;
/** 上传 图片裁剪 高 */
@property (copy, nonatomic) NSString *fourStr;

//......上传视频
@property (assign, nonatomic) int seltedType;

/** 显示隐藏导航栏 1:隐藏 2:展示*/
@property (strong, nonatomic) NSString *isHideNavStr;
/** 原生返回 */
@property (strong, nonatomic) NSString *modularReturn;

@end

@implementation JXWebBridgeCtrl
//js交互事件可以与H5端整理成文档并记录下来
-(NSArray *)JSArray{
    if(!_JSArray){
        _JSArray=[NSArray arrayWithObjects:@"veappNavShowHide",@"appJumpDetails",@"appShareModular",@"scratchCard",@"appFromToIdSource",@"appShareMini",@"appShareMiniStorage",@"veNavSignalBgcolor2",@"moreBtnIsShow",@"appCallBackPage",@"appSelectMapLocation",@"appAlbumPage",@"appTimeWheel",@"appBindPhone",@"appVerifyPhone",@"appChangeBindPhone",@"appNewPage",@"appWebLoadUrl",@"webRefresh",@"appFinish",@"appSystemDialog",@"appAlbumVideo",@"appSqlSave",@"appSqlGet",@"appSqlClear",@"appWebCacheClear",@"appWheelPop",@"appSqlRemoveItem",@"appCallCustomer", @"appVenueAdress",@"veCallService",@"appAlbumPage2",@"appVideoPlay",@"appCallbcakLogin",@"stepNumber",@"appArticleType",@"vesignOutSignin",@"modularReturn",@"cancellationNewHtml",@"appAllLikeList",@"appAllReplyDiscuss",@"appSeeAllDiscuss",@"veScan",@"appTMCodeScan",@"appTMWxPay",@"imgAlbum",@"appLocate",@"appLocateOnce",@"pageReturn",@"appTMAlipayPay",nil];
        
        //
    }
    return _JSArray;
}
-(UIProgressView *)progressView {
    if (!_progressView) {
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [_progressView setFrame:CGRectMake(0,88, self.view.frame.size.width, 1)];
        //设置进度条颜色
        [_progressView setTintColor:[UIColor colorWithRed:0.400 green:0.863 blue:0.133 alpha:1.000]];
        
        
    }
    return _progressView;
}

-(WKWebView *)webView {
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        
        // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
        [self.JSArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [config.userContentController addScriptMessageHandler:self name:obj];
        }];
        //self.view.bounds
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
        _webView.backgroundColor=[UIColor whiteColor];
        
        
        //kvo 添加进度监控
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:NULL];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        // _webView.allowsBackForwardNavigationGestures
        /* 设置代理 (需要设置导航栏)*/
        _webView.navigationDelegate = self;
        _webView.UIDelegate=self;
        
    }
    return _webView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"网页";
    
    UIButton*leftbutton = [UIButton buttonWithType:UIButtonTypeCustom];
  
    [leftbutton addTarget:self action:@selector(left_click:)forControlEvents:UIControlEventTouchUpInside];
    [leftbutton setTitle:@"返回" forState:UIControlStateNormal];
    [leftbutton setTitleColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];
    UIBarButtonItem*item = [[UIBarButtonItem alloc]initWithCustomView:leftbutton];
    self.navigationItem.leftBarButtonItem=item;
    
    
    [self loadWebView];
}
-(void)left_click:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --设置webView
-(void)loadWebView{
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self.view addSubview:self.webView];
    // 链接
    NSString*urlStr=self.linkUrlStr;
    
    
    NSLog(@"当前url链接>>%@",urlStr);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.progressView];
    
    
}


//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if(self.webView.estimatedProgress >=1.0f) {
            [self.progressView setProgress:1.0f animated:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.progressView setProgress:0.0f animated:NO];
                self.progressView.hidden = YES;
                
            });
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            if(self.navigationController)
                self.title = self.webView.title;
            NSLog(@"%@",self.title);
          
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - WKNavigationDelegate
// 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
}
// 加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    if ([self.backNavigation isEqual:navigation]) {
        // 这次的加载是点击返回产生的，刷新
        // [self reloadWeb];
        [self H5Refresh];
        self.backNavigation  = nil;
    }
    //每次掉刷新
    [self H5Refresh];
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"当内容开始返回时调用");
    
}
// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载超时");
    NSLog(@"%@",error);
}
//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"跳转失败");
}
//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"在发送请求之前，决定是否跳转");
    if (navigationAction.navigationType==WKNavigationTypeBackForward) {                  //判断是返回类型
        if ([self.webView canGoBack]) {
           
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 拦截警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    // NSLog(@"拦截警告框");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    /*
     */
}
#pragma mark - WKScriptMessageHandler （js调用原生）
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //,message.frameInfo
    NSLog(@"name:%@\n body:%@\n frameInfo:",message.name,message.body);
    //vesignOutSignin 退出登录
    
    if ([message.name isEqualToString:@"modularReturn"]) {
        //点击返回直接关闭页面
    }if ([message.name isEqualToString:@"cancellationNewHtml"]) {
        //注销webView重新加载链接
        NSString *linkStr= message.body[0];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkStr]]];
    }if ([message.name isEqualToString:@"appAllLikeList"]) {
        //点赞列表
    }if ([message.name isEqualToString:@"appAllReplyDiscuss"]) {
        //全部回复
    }if ([message.name isEqualToString:@"appSeeAllDiscuss"]) {
        //全部评论
    }if ([message.name isEqualToString:@"veScan"]) {
        //扫一扫
    }if ([message.name isEqualToString:@"appTMCodeScan"]) {
        //扫一扫
        //扫描成功后回调给H5数据
        NSString *str=@"扫描出来的数据";
        NSString *jscript = [NSString stringWithFormat:@"appTMCodeScanResult ('%@')",str];
        NSLog(@"%@",jscript);
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"h5提交成功");
                // [self performSelector:@selector(reloadWeb) withObject:nil/*可传任意类型参数*/ afterDelay:3.0];
            }else{
                // SVHUD_ERROR(@"出错了,请再试");
            }
        }];
        
    }if ([message.name isEqualToString:@"appTMWxPay"]) {
        //微信支付
        /*
         body
         outTradeNo
         totalFee
         */
        /*
        NSString *oneStr= message.body[0];
        NSString *twoStr= message.body[1];
        NSString *threeStr= message.body[2];
        */
        //[self goToLoadOrderWxWith:oneStr withTradeNo:twoStr withTotalFeeStr:threeStr withPayType:2];
    }if ([message.name isEqualToString:@"appTMAlipayPay"]) {
        //支付宝支付
        /*
         body
         outTradeNo
         totalFee
         */
        /*
        NSString *oneStr= message.body[0];
        NSString *twoStr= message.body[1];
        NSString *threeStr= message.body[2];
        */
       // [self goToLoadOrderWxWith:oneStr withTradeNo:twoStr withTotalFeeStr:threeStr withPayType:6];
    }
    
    if ([message.name isEqualToString:@"vesignOutSignin"]) {
        
      //  [self hideGuidView];
        
    }if ([message.name isEqualToString:@"veappNavShowHide"]) {
        NSLog(@"%@",message.body);
        NSString *oneStr= message.body[0];
        self.isHideNavStr=oneStr;
        if ([oneStr isEqualToString:@"1"]) {
            //1隐藏
        }else{
            //2显示
           
        }
        
        
    }if ([message.name isEqualToString:@"moreBtnIsShow"]) {
        NSString *str=  message.body[0];
        if ([str integerValue]==1) {
            //展示分享按钮
        }else{
            //隐藏分享按钮
        }
    }
    
    if ([message.name isEqualToString:@"appJumpDetails"]) {
        /*
         跳转详情交互  数组长度为 3
         fromTo,
         fromId,
         orderId,
         msgState,
         keyword,
         */
        
        
    }if ( [message.name isEqualToString:@"appShareModular"]) {
        //主动调链接 h5 调用
        /*
         shareTitle,
         shareDesc,
         shareLink,
         shareImg
         */
//        NSString *shareTitleStr=message.body[0];
//        NSString *shareDescStr=message.body[1];
//        NSString *shareLinkStr=message.body[2];
//        NSString *shareImg=message.body[3];
        
    }
    if ([message.name isEqualToString:@"scratchCard"]) {
        //保存分享链接 自己点分享
        /*
         shareTitle,
         shareDesc,
         shareLink,
         shareImg
         */
    }if ([message.name isEqualToString:@"appFromToIdSource"]) {
        //
       // NSString *fromToStr=message.body[0]
        //
       // NSString *fromIdStr=message.body[1];
        
        
    } if ([message.name isEqualToString:@"appShareMini"]) {
        //分享小程序 h5调用
        /*
         shareTitle,
         shareDesc,
         shareLink,
         shareImg,
         wxPath
         */
        /*
        // 分享标题
        NSString *titleStr=message.body[0];
        // 分享描述
        NSString *desStr=message.body[1];
        // 分享链接
        NSString *linkStr=message.body[2];
        // 分享缩略图
        NSString *imgStr=message.body[3];
        // 小程序分享路径
        NSString *minPath=message.body[4];
         */
    }if ([message.name isEqualToString:@"appShareMiniStorage"]) {
        //保存分享小程序 原生界面点分享
        /*
         shareTitle,
         shareDesc,
         shareLink,
         shareImg,
         wxMiniAppPath
         */
    }if ([message.name isEqualToString:@"appVideoPlay"]) {
        //点击播放视频
//        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://qiniu.xxx.com/%@",message.body[0]]]]];
    }if ([message.name isEqualToString:@"veNavSignalBgcolor2"]) {
        //状态栏 + 导航栏背景颜色
        /** 1:黑色 2:白色*/
        //NSString *oneStr= message.body[0];
        
        
    }
    if ([message.name isEqualToString:@"appCallBackPage"]) {
        //返回
        //[self onBackBaseCtrl];
        //appCallBackPage
    }if ([message.name isEqualToString:@"appArticleType"]) {
        //跳文章类型列表
     
        
    }
    if ([message.name isEqualToString:@"appCallbcakLogin"]) {
        //调用登录
      
        
    }if ([message.name isEqualToString:@"stepNumber"]) {
        //步数
        
        
    }if ([message.name isEqualToString:@"imgAlbum"]) {
        //上传图片
        //data为一张一张的图片 七牛名称
        /** 最多传几张 */
        NSString *oneStr= message.body[0];
        self.maxSeletedCount=oneStr;
        /** 是否裁剪 0:不裁剪 1:裁剪 */
        NSString *twoStr= message.body[1];
        if ([twoStr isEqualToString:@"1"]) {
            /** 裁剪 裁剪宽 */
            NSString *thirdStr= message.body[2];
            self.thirdStr=thirdStr;
            /** 裁剪 裁剪高 */
            NSString *fourStr= message.body[3];
            self.fourStr=fourStr;
        }
       // [self takePhoto];
        
    }if ([message.name isEqualToString:@"appSelectMapLocation"]) {
        //选择地址
        //选择完毕之后回调给H5数据
        //【详细位置，名称，Longitude，latitude】上传
        NSString *jscript = [NSString stringWithFormat:@"appSelectMapLocationResult('%@','%@','%@','%@')",@"",@"",@"",@""];
        NSLog(@"上传 地址 >>>%@",jscript);
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
            //NSLog(@"%@>>%@",object,error);
        }];
    }if ([message.name isEqualToString:@"appTimeWheel"]) {
        //调用时间轴
        //选择完毕之后回调给H5数据
        NSString *jscript = [NSString stringWithFormat:@"appTimeWeelResult('%@')",@"2019-01-01"];
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
           // NSLog(@"%@>>%@",object,error);
        }];
    }if ([message.name isEqualToString:@"appBindPhone"]) {
        //调用绑定手机号
        //绑定手机号 绑定成功后回调给H5数据
        NSString *jscript = [NSString stringWithFormat:@"appBindPhoneSuccess('%@')",@"xxxxxxxxxxx"];
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
            //NSLog(@"%@>>%@",object,error);
        }];
        
    }if ([message.name isEqualToString:@"appVerifyPhone"]) {
        //验证原手机号
        //验证原手机号上传 绑定成功后回调给H5数据
        NSString *jscript = [NSString stringWithFormat:@"appVerifyPhoneSuccess('%@')",@"xxxxxxxxxxx"];
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
           // NSLog(@"%@>>%@",object,error);
        }];
    }if ([message.name isEqualToString:@"appChangeBindPhone"]) {
        //换绑手机号
        //先验证原手机号
        //验证成功回调   -成功后回调给H5数据
        NSString *jscript = [NSString stringWithFormat:@"appChangeBindPhoneSuccess('%@')",@"xxxxxxxxxxx"];
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
           // NSLog(@"%@>>%@",object,error);
        }];
    }if([message.name isEqualToString:@"veCallService"]){
        //打电话联系客服
        
        
    }if ([message.name isEqualToString:@"appNewPage"]) {
        //跳转界面
       
    }if ([message.name isEqualToString:@"appWebLoadUrl"]) {
        //加载新链接
        NSString *oneStr= message.body[0];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:oneStr]]];
    }if ([message.name isEqualToString:@"webRefresh"]) {
        //刷新当前界面
        [self reloadWebForSysTeam];
    }if ([message.name isEqualToString:@"appFinish"]) {
        //返回
        [self.navigationController popViewControllerAnimated:YES];
    }if([message.name isEqualToString:@"appSystemDialog"]){
        //弹窗
        /*
         1：title     （如果传 ""）则title会隐藏
         2：内容
         3：取消按钮是否显示      "0"：隐藏；"1" 显示；
         4：确认按钮显示文案
         */
        /*
        NSString *oneStr= message.body[0];
        NSString *twoStr= message.body[1];
        NSString *threeStr= message.body[2];
        // NSString *fourStr= message.body[3];
        */
    }if([message.name isEqualToString:@"appAlbumVideo"]){
        //本地相册视频
        self.seltedType=2;
        //[self takePhoto];
        
    }if ([message.name isEqualToString:@"appCallCustomer"]) {
        //打电话
        NSString *phoneStr=message.body[0];
        // NSLog(@"%@",phoneStr);
        phoneStr= [NSString stringWithFormat:@"%@%@",@"tel://",phoneStr];
        
    }if ([message.name isEqualToString:@"appVenueAdress"]) {
        //地图
        /*
        NSString *addressStr=  message.body[0];
        NSString *latitudeStr= message.body[1];
        NSString *longitudeStr= message.body[2];
        */
    }if([message.name isEqualToString:@"appSqlSave"]){
        //本地存储
        //        1：key
        //        2：value
        /*
        NSString *oneStr= message.body[0];
        NSString *twoStr= message.body[1];
        NSString *woneStr=[NSString stringWithFormat:@"web_%@",oneStr];
        UDSETOBJ(twoStr, woneStr)
        */
    }if([message.name isEqualToString:@"appSqlGet"]){
        //获取本地存储的值
        //        参数：
        //        1：key
        /*
        NSString *oneStr= message.body[0];
        NSString *woneStr=[NSString stringWithFormat:@"web_%@",oneStr];
        NSString *keyStr= UDOBJ(woneStr);
        if (![keyStr isNotEmpty]) {
            keyStr=@"";
        }
        NSString *jscript = [NSString stringWithFormat:@"appSqlGetResult('%@')",keyStr];
        //
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
            NSLog(@"%@>>%@",object,error);
        }];
         */
        
    }if ([message.name isEqualToString:@"appSqlRemoveItem"]) {
        //清除某一个key值
        NSString *oneStr= message.body[0];
        NSString *woneStr=[NSString stringWithFormat:@"web_%@",oneStr];
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        NSArray *keysArr =[dict allKeys];
        
        for (id keyStr in keysArr) {
            if ([keyStr isKindOfClass:[NSString class]]) {
                
                NSString * keysStr=(NSString *)keyStr;
                
                if([keysStr isEqualToString:woneStr]){
                  //  NSLog(@"%@>>%@",keysStr,woneStr);
                    [defs removeObjectForKey:keysStr];
                }
            }
        }
    }if([message.name isEqualToString:@"appSqlClear"]){
        //清除 nsuerdefault本次存储数据
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        
        NSDictionary * dict = [defs dictionaryRepresentation];
        NSArray *keysArr =[dict allKeys];
        
        for (id keyStr in keysArr) {
            if ([keyStr isKindOfClass:[NSString class]]) {
                NSString * keysStr=(NSString *)keyStr;
                
                if ([keysStr hasPrefix:@"web_"]) {
                    [defs removeObjectForKey:keysStr];
                }
            }
            
        }
    }if([message.name isEqualToString:@"appWebCacheClear"]){
        //清空webView本地缓存
       // [Tools cleanWebCache];
    }if ([message.name isEqualToString:@"appAlbumPage"]) {
        //点击放大
    }if ([message.name isEqualToString:@"appAlbumPage2"]) {
        //点击放大
    }if ([message.name isEqualToString:@"appWheelPop"]) {
        //滚轮
        
    }if ([message.name isEqualToString:@"appLocate"]) {//持续定位
        
    }if ([message.name isEqualToString:@"appLocateOnce"]) {
        //定位一次
        CLLocation *currentLocation;
        //详细位置
        NSString *detailAddressStr=@"";
        //名称
        NSString *addressStr=@"";
        // longitude 经度
        NSString *  longitude= [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        // latitude 纬度
        NSString * latitude= [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        if([longitude integerValue]==0){
            longitude=@"";
        }
        if ([latitude integerValue]==0) {
            latitude=@"";
        }
        NSLog(@"经纬度>>%@",longitude);
        //【详细位置，名称，Longitude，latitude】上传
        NSString *jscript = [NSString stringWithFormat:@"appLocateResult('%@','%@','%@','%@')",detailAddressStr,addressStr,longitude,latitude];
        // 调用JS代码
        [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
           // NSLog(@"%@>>%@",object,error);
        }];
        
        
    }if ([message.name isEqualToString:@"pageReturn"]) {
        
        NSString *loadStr= message.body;
        
        if ([loadStr isEqualToString:@"1"]) {
            [self.webView goBack];
            WKNavigation *backNavigation = [self.webView goBack];
            self.backNavigation=backNavigation;
        }
        
    }
    
}
#pragma mark --原生刷新
-(void)reloadWebForSysTeam {
    [self.webView reload];
}

-(void)H5Refresh{
    //此处为H5的刷新数据方法，用以刷新H5数据，与H5端定义为此方法；
    NSString *jscript = [NSString stringWithFormat:@"webRefresh('%@')",@""];
    // 调用JS代码
    [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
       // NSLog(@"%@>>%@",object,error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    [[self JSArray]enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:obj];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
