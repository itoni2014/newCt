

#import "ChartSettingView.h"
#import "DetailChartView.h"
#import "ChartBox.h"
//#import "TechnicalSetting.h"

@interface ChartSettingView()
{
    CGFloat topBarHeight;
    
    //テクニカル指標の設定値の一時保存Dictionary
    NSMutableDictionary *tempValueMutableDic;
    //足種選択インデックスの一時保存Dictionary
    NSMutableDictionary *ashiSegmentSelectedMutableDic;


    /* 足種とナンバーピッカーを表示するビュー */
    UIView *settingView;
    /* テクニカル指標選択segment */
    UISegmentedControl *techSegment;
    /* 足種選択segment */
    UISegmentedControl *ashiSegment;
//    /* ナンバーピッカー */
//    NumberPickerModel *numberModel1;
//    UIOrderNumberPickerCustom *numNumberPicker1;
//    /* ナンバーピッカー */
//    NumberPickerModel *numberModel2;
//    UIOrderNumberPickerCustom *numNumberPicker2;
//    /* ナンバーピッカー */
//    NumberPickerModel *numberModel3;
//    UIOrderNumberPickerCustom *numNumberPicker3;
//    /* ナンバーピッカー */
//    NumberPickerModel *numberModel4;
//    UIOrderNumberPickerCustom *numNumberPicker4;
    
    NSInteger nowSelectedIndex_tech;
    NSInteger nowSelectedIndex_ashi;
}
@end

@implementation ChartSettingView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithRed:238/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];

        [self.layer setBorderWidth: 1.0];
        [self.layer setCornerRadius:5.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderColor:[[UIColor colorWithRed:205/255.0 green:201/255.0 blue:201/255.0 alpha:1.0] CGColor]];

        tempValueMutableDic = [[ChartBox sharedInstance].technicalValueDic mutableCopy];
        ashiSegmentSelectedMutableDic = [ @{ @"ma"        : @"3",
                                             @"bollinger" : @"3",
                                             @"itimoku"   : @"3",
                                             @"rsi"       : @"3",
                                             @"macd"      : @"3",
                                             @"stochas"   : @"3", } mutableCopy ];
        
        
        
        topBarHeight = frame.size.height/9.0;
//        bottomBarPositionY = frame.size.height*0.87;
        
        
        UIScrollView *scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, topBarHeight)];
        [scrollview setShowsHorizontalScrollIndicator:NO];
        [self addSubview:scrollview];
        
        techSegment = [[UISegmentedControl alloc] initWithItems:  [ChartBox sharedInstance].technicalNameArray ];
        techSegment.frame = CGRectMake(0, 0, scrollview.frame.size.width * 1.3, scrollview.frame.size.height);
        [techSegment addTarget:self action:@selector( changeTechValue: ) forControlEvents:UIControlEventValueChanged];
        techSegment.selectedSegmentIndex = 0;
        nowSelectedIndex_tech = techSegment.selectedSegmentIndex;
        scrollview.contentSize = techSegment.frame.size;
//        techSegment.tintColor = [UIColor clearColor];
        [scrollview addSubview:techSegment];
        
        //足種とナンバーピッカーを初期化
        [self initSettingView];
        
        //閉じるボタン、初期値ボタン、保存ボタンを初期化
        [self initBottomBar];
        
    }
    
    return self;
}

#pragma mark - Button Tapped Methods

//初期値に戻すボタン・テクニカルSegment・足種Segment
- (void)changeTechValue: (id)sender{
    
    //設定値を一時保存
    [self saveSettingValues];
    
    
    NSDictionary *dictionary;
    if([ sender isKindOfClass:[UIButton class] ]){ //初期値に戻すボタン押下
        dictionary = [ChartBox sharedInstance].technicalDefaultValueDic;
        
    }
    else{
        if(sender == techSegment){//テクニカル指標押下
            
            //各指標ラインのラベルを変更
            [self updateAshiLabels];

        }
        
        if(sender == ashiSegment){//足種選択押下
            
            [self saveAshiSelectedIndex];
            
        }
        
        dictionary = tempValueMutableDic.copy;
    }
    

    //設定値を再表示
    [self updateSettingValues: dictionary];
    
    nowSelectedIndex_tech = techSegment.selectedSegmentIndex;
    nowSelectedIndex_ashi = ashiSegment.selectedSegmentIndex;

}


//閉じるボタン
- (void)closeBtnTapped: (id)sender{
    [self.detailChartView.settingButton setEnabled:YES];
    [self removeFromSuperview];
}


//保存ボタン
- (void)saveBtnTapped: (id)sender{
    [self saveSettingValues];
    
    [ChartBox sharedInstance].technicalValueDic = [tempValueMutableDic copy];
//    [[NSUserDefaults standardUserDefaults] setObject:[tempValueMutableDic copy] forKey:@"TechnicalIndicatorValue"];
    

//    [self.detailChartView.managerViewController.chartView saveTechnicalSettings];
//
//    
////    [self.detailChartView redrawChart:YES];
//    [self.detailChartView.managerViewController.chartView updateCharts];

    [self.detailChartView.settingButton setEnabled:YES];
    [self removeFromSuperview];
    

}

#pragma mark - ビューの初期化

- (void)initBottomBar{
    CGFloat btnWidth = self.frame.size.width/4;
    CGFloat bottomBarPositionY = self.frame.size.height - topBarHeight-4;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(self.frame.size.width/10, bottomBarPositionY, btnWidth, topBarHeight);
    [closeButton setTitle:@"閉じる" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 6.f;
    closeButton.layer.borderWidth = 1.0;
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    closeButton.tag = 11;
    [closeButton addTarget:self action:@selector(closeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    UIButton *initValueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    initValueButton.frame = CGRectMake(self.frame.size.width/10, bottomBarPositionY, btnWidth, topBarHeight);
    [initValueButton setTitle:@"初期値に戻す" forState:UIControlStateNormal];
    [initValueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    initValueButton.layer.cornerRadius = 6.f;
    initValueButton.layer.borderWidth = 1.0;
    [initValueButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [initValueButton setCenter:CGPointMake(self.frame.size.width/2, initValueButton.center.y)];
    initValueButton.tag = 12;
    [initValueButton addTarget:self action:@selector( changeTechValue: ) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:initValueButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(self.frame.size.width - btnWidth - self.frame.size.width/10, bottomBarPositionY, btnWidth, topBarHeight);
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveButton.layer.cornerRadius = 6.f;
    saveButton.layer.borderWidth = 1.0;
    [saveButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    saveButton.tag = 13;
    [saveButton addTarget:self action:@selector(saveBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];
}

- (void)initSettingView{
    settingView = [[UIView alloc]initWithFrame:CGRectMake(0, topBarHeight, self.frame.size.width, self.frame.size.height - topBarHeight - topBarHeight)];
    [self addSubview: settingView];

    ashiSegment = [[UISegmentedControl alloc] initWithItems: [ChartBox sharedInstance].ashiNameArray];
    ashiSegment.frame = CGRectMake(settingView.frame.size.width * 0.08, topBarHeight * 0.3, settingView.frame.size.width * 0.8, topBarHeight * 1.1);
    [ashiSegment addTarget:self action:@selector( changeTechValue: ) forControlEvents:UIControlEventValueChanged];
    ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"ma"] integerValue];
    nowSelectedIndex_ashi = ashiSegment.selectedSegmentIndex;
    [settingView addSubview:ashiSegment];

    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame: CGRectMake(0, ashiSegment.frame.origin.y + ashiSegment.frame.size.height+2, settingView.frame.size.width, settingView.frame.size.height - (ashiSegment.frame.origin.y + ashiSegment.frame.size.height+2)) ];
    scrollview.contentSize = CGSizeMake( scrollview.frame.size.width, scrollview.frame.size.height + 0.5);
    
    [settingView addSubview:scrollview];
    
    CGFloat labelX = settingView.frame.size.width * 0.12;
    CGFloat labelHaba = settingView.frame.size.width * 0.18;

    
    UIView *label4View = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollview.frame.size.width, scrollview.frame.size.height)];
    label4View.tag = 99;
    label4View.backgroundColor = [UIColor clearColor];
    label4View.hidden = YES;
    [scrollview addSubview:label4View];


    //////////////////////////////////////////////////////////////////
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(labelX, settingView.frame.size.height * 0.1, labelHaba, 20)];
    label1.text = [ChartBox sharedInstance].ma_labelTextArray[0];
    label1.font = [UIFont systemFontOfSize:12.0];
    label1.textColor = [UIColor greenColor];
    label1.tag = 1;
    [scrollview addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(labelX, label1.frame.origin.y + label1.frame.size.height * 1.8, labelHaba, 20)];
    label2.text = [ChartBox sharedInstance].ma_labelTextArray[1];
    label2.font = [UIFont systemFontOfSize:12.0];
    label2.textColor = [UIColor yellowColor];
    label2.tag = 2;
    [scrollview addSubview:label2];

    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(labelX, label2.frame.origin.y + label2.frame.size.height * 1.8, labelHaba, 20)];
    label3.text = [ChartBox sharedInstance].ma_labelTextArray[2];
    label3.font = [UIFont systemFontOfSize:12.0];
    label3.textColor = [UIColor blackColor];
    label3.tag = 3;
    [scrollview addSubview:label3];

    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(labelX, label3.frame.origin.y + label3.frame.size.height * 1.8, labelHaba, 20)];
    label4.text = @"label4";
    label4.font = [UIFont systemFontOfSize:12.0];
    label4.textColor = [UIColor blackColor];
    label4.tag = 4;
    [label4View addSubview:label4];
    //////////////////////////////////////////////////////////////////

    
    
    

    CGRect rect1 = CGRectMake(labelX+labelHaba*1.3, label1.frame.origin.y, 230, 31);
    CGRect rect2 = CGRectMake(labelX+labelHaba*1.3, label2.frame.origin.y, 230, 31);
    CGRect rect3 = CGRectMake(labelX+labelHaba*1.3, label3.frame.origin.y, 230, 31);
    CGRect rect4 = CGRectMake(labelX+labelHaba*1.3, label4.frame.origin.y, 230, 31);
    
    
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    
//    //パラメータ設定
//    numberModel1 = [[NumberPickerModel alloc] init];
//    numberModel1.numberPickerType = UIOrderNumberPickerCustomStyleNumerical;
//    numberModel1.unitValue = @"1";//売買単位
//    numberModel1.currentValue = tempValueMutableDic[@"ma_day_s"]; // self.orderNumberPickerValue;//ディフォルト値
//    numberModel1.defaultValue = tempValueMutableDic[@"ma_day_s"];
//    //注文数ナンバーピッカー
//    numNumberPicker1 = [[UIOrderNumberPickerCustom alloc] initWithFrame:rect1];
////    numNumberPicker1.delegate = self;
//    [numNumberPicker1 setRootParentViewController: (UIViewController *)self.detailChartView.managerViewController];
//    [numNumberPicker1 setNumberPickerModel: numberModel1];
//    [scrollview addSubview: numNumberPicker1];
//    numNumberPicker1.center = CGPointMake(numNumberPicker1.center.x, label1.center.y);
//
//    //パラメータ設定
//    numberModel2 = [[NumberPickerModel alloc] init];
//    numberModel2.numberPickerType = UIOrderNumberPickerCustomStyleNumerical;
//    numberModel2.unitValue = @"1";//売買単位
//    numberModel2.currentValue = tempValueMutableDic[@"ma_day_m"]; // self.orderNumberPickerValue;//ディフォルト値
//    numberModel2.defaultValue = tempValueMutableDic[@"ma_day_m"];
//    //注文数ナンバーピッカー
//    numNumberPicker2 = [[UIOrderNumberPickerCustom alloc] initWithFrame:rect2];
////    numNumberPicker2.delegate = self;
//    [numNumberPicker2 setRootParentViewController: (UIViewController *)self.detailChartView.managerViewController];
//    [numNumberPicker2 setNumberPickerModel:numberModel2];
//    [scrollview addSubview: numNumberPicker2];
//    numNumberPicker2.center = CGPointMake(numNumberPicker2.center.x, label2.center.y);
//
//    //パラメータ設定
//    numberModel3 = [[NumberPickerModel alloc] init];
//    numberModel3.numberPickerType = UIOrderNumberPickerCustomStyleNumerical;
//    numberModel3.unitValue = @"1";//売買単位
//    numberModel3.currentValue = tempValueMutableDic[@"ma_day_l"]; // self.orderNumberPickerValue;//ディフォルト値
//    numberModel3.defaultValue = tempValueMutableDic[@"ma_day_l"];
//    //注文数ナンバーピッカー
//    numNumberPicker3 = [[UIOrderNumberPickerCustom alloc] initWithFrame:rect3];
////    numNumberPicker3.delegate = self;
//    [numNumberPicker3 setRootParentViewController: (UIViewController *)self.detailChartView.managerViewController];
//    [numNumberPicker3 setNumberPickerModel:numberModel3];
//    [scrollview addSubview: numNumberPicker3];
//    numNumberPicker3.center = CGPointMake(numNumberPicker3.center.x, label3.center.y);
//    
//    //パラメータ設定
//    numberModel4 = [[NumberPickerModel alloc] init];
//    numberModel4.numberPickerType = UIOrderNumberPickerCustomStyleNumerical;
//    numberModel4.unitValue = @"1";//売買単位
//    numberModel4.currentValue = tempValueMutableDic[@"stochas_4"]; // self.orderNumberPickerValue;//ディフォルト値
//    numberModel4.defaultValue = tempValueMutableDic[@"stochas_4"];
//    //注文数ナンバーピッカー
//    numNumberPicker4 = [[UIOrderNumberPickerCustom alloc] initWithFrame:rect4];
////    numNumberPicker4.delegate = self;
//    [numNumberPicker4 setRootParentViewController: (UIViewController *)self.detailChartView.managerViewController];
//    [numNumberPicker4 setNumberPickerModel:numberModel4];
//    [label4View addSubview: numNumberPicker4];
//    numNumberPicker4.center = CGPointMake(numNumberPicker4.center.x, label4.center.y);
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    
}


#pragma mark - Other Methods

//各指標ラインのラベルのテキストと色の変更
- (void)updateAshiLabels {
    //各指標のラインラベル
    UILabel *line1Label = (UILabel *)[settingView viewWithTag:1];
    UILabel *line2Label = (UILabel *)[settingView viewWithTag:2];
    UILabel *line3Label = (UILabel *)[settingView viewWithTag:3];
    UILabel *line4Label = (UILabel *)[settingView viewWithTag:4];
    UIView  *line4View  = (UIView *)[settingView viewWithTag:99];

    switch (techSegment.selectedSegmentIndex) {
        case 0://移動平均
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"ma"] integerValue];
            line1Label.textColor = [UIColor colorWithRed:MOVAVG_SHORT_COLOR[0]/255.0 green:MOVAVG_SHORT_COLOR[1]/255.0 blue:MOVAVG_SHORT_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed:MOVAVG_MEDIUM_COLOR[0]/255.0 green:MOVAVG_MEDIUM_COLOR[1]/255.0 blue:MOVAVG_MEDIUM_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed:MOVAVG_LONG_COLOR[0]/255.0 green:MOVAVG_LONG_COLOR[1]/255.0 blue:MOVAVG_LONG_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].ma_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].ma_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].ma_labelTextArray[2];
            line4View.hidden = YES;

            break;
            
        case 1://ボリンジャー
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"bollinger"] integerValue];
            line1Label.textColor = [UIColor colorWithRed: BOLLINGER_MOVE_AVG_COLOR[0]/255.0 green:BOLLINGER_MOVE_AVG_COLOR[1]/255.0 blue:BOLLINGER_MOVE_AVG_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed: BOLLINGER_TOP1_COLOR[0]/255.0 green:BOLLINGER_TOP1_COLOR[1]/255.0 blue:BOLLINGER_TOP1_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed: BOLLINGER_TOP2_COLOR[0]/255.0 green:BOLLINGER_TOP2_COLOR[1]/255.0 blue:BOLLINGER_TOP2_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].bollinger_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].bollinger_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].bollinger_labelTextArray[2];
            line4View.hidden = YES;

            
            break;
            
        case 2://一目均衡表
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"itimoku"] integerValue];
            line1Label.textColor = [UIColor colorWithRed: ITIMOKU_CONVERSION_COLOR[0]/255.0 green:ITIMOKU_CONVERSION_COLOR[1]/255.0 blue:ITIMOKU_CONVERSION_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed: ITIMOKU_BASE_COLOR[0]/255.0 green:ITIMOKU_BASE_COLOR[1]/255.0 blue:ITIMOKU_BASE_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed: ITIMOKU_LEADING_SPAN2_COLOR[0]/255.0 green:ITIMOKU_LEADING_SPAN2_COLOR[1]/255.0 blue:ITIMOKU_LEADING_SPAN2_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].itimoku_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].itimoku_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].itimoku_labelTextArray[2];
            line4View.hidden = YES;

            break;
            
        case 3://RSI
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"rsi"] integerValue];
            line1Label.textColor = [UIColor colorWithRed: RSI_BASE_COLOR[0]/255.0 green:RSI_BASE_COLOR[1]/255.0 blue:RSI_BASE_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed: RSI_OVER_BUY_COLOR[0]/255.0 green:RSI_OVER_BUY_COLOR[1]/255.0 blue:RSI_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed: RSI_OVER_SELL_COLOR[0]/255.0 green:RSI_OVER_SELL_COLOR[1]/255.0 blue:RSI_OVER_SELL_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].rsi_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].rsi_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].rsi_labelTextArray[2];
            line4View.hidden = YES;

            break;
            
        case 4://MACD
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"macd"] integerValue];
            line1Label.textColor = [UIColor colorWithRed: MACD_SIGNAL_COLOR[0]/255.0 green:MACD_SIGNAL_COLOR[1]/255.0 blue:MACD_SIGNAL_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed: MACD_OSCI_LIGHT_COLOR[0]/255.0 green:MACD_OSCI_LIGHT_COLOR[1]/255.0 blue:MACD_OSCI_LIGHT_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed: MACD_OSCI_DARK_COLOR[0]/255.0 green:MACD_OSCI_DARK_COLOR[1]/255.0 blue:MACD_OSCI_DARK_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].macd_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].macd_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].macd_labelTextArray[2];
            line4View.hidden = YES;

            
            break;
            
        case 5://Sストキャス
            ashiSegment.selectedSegmentIndex = [ashiSegmentSelectedMutableDic[@"stochas"] integerValue];
            line1Label.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_D_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_D_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_D_COLOR[2]/255.0 alpha:1.0];
            line2Label.textColor = [UIColor colorWithRed: STOCHAS_SLOW_PER_K_COLOR[0]/255.0 green:STOCHAS_SLOW_PER_K_COLOR[1]/255.0 blue:STOCHAS_SLOW_PER_K_COLOR[2]/255.0 alpha:1.0];
            line3Label.textColor = [UIColor colorWithRed: STOCHAS_OVER_BUY_COLOR[0]/255.0 green:STOCHAS_OVER_BUY_COLOR[1]/255.0 blue:STOCHAS_OVER_BUY_COLOR[2]/255.0 alpha:1.0];
            line4Label.textColor = [UIColor colorWithRed: STOCHAS_OVER_SELL_COLOR[0]/255.0 green:STOCHAS_OVER_SELL_COLOR[1]/255.0 blue:STOCHAS_OVER_SELL_COLOR[2]/255.0 alpha:1.0];
            
            line1Label.text = [ChartBox sharedInstance].stochas_labelTextArray[0];
            line2Label.text = [ChartBox sharedInstance].stochas_labelTextArray[1];
            line3Label.text = [ChartBox sharedInstance].stochas_labelTextArray[2];
            line4Label.text = [ChartBox sharedInstance].stochas_labelTextArray[3];
            line4View.hidden = NO;

            break;
            
        default:
            break;
    }
    
    
}

- (void)saveAshiSelectedIndex{
    switch (techSegment.selectedSegmentIndex) {
        case 0:
            ashiSegmentSelectedMutableDic[@"ma"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
        case 1:
            ashiSegmentSelectedMutableDic[@"bollinger"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
        case 2:
            ashiSegmentSelectedMutableDic[@"itimoku"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
        case 3:
            ashiSegmentSelectedMutableDic[@"rsi"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
        case 4:
            ashiSegmentSelectedMutableDic[@"macd"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
        case 5:
            ashiSegmentSelectedMutableDic[@"stochas"] = [NSString stringWithFormat:@"%ld", ashiSegment.selectedSegmentIndex];
            break;
            
        default:
            break;
    }

}

//各指標、各足種の設定値を再表示
- (void)updateSettingValues: (NSDictionary *)dictionary{

    switch (techSegment.selectedSegmentIndex) {
        case 0: //移動平均
        {
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_1min_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_1min_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_1min_l"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_10min_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_10min_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_10min_l"]];
//                    
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_hour_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_hour_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_hour_l"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_day_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_day_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_day_l"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_week_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_week_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_week_l"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"ma_month_s"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"ma_month_m"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"ma_month_l"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            
            break;
            
        case 1://ボリンジャー
        {
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_1min_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_1min_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_1min_2"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_10min_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_10min_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_10min_2"]];
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_hour_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_hour_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_hour_2"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_day_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_day_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_day_2"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_week_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_week_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_week_2"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"bollinger_month_ma"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"bollinger_month_1"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"bollinger_month_2"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            break;
            
        case 2://一目均衡表
        {
            
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_1min_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_1min_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_1min_span"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_10min_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_10min_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_10min_span"]];
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_hour_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_hour_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_hour_span"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_day_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_day_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_day_span"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_week_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_week_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_week_span"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"itimoku_month_convert"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"itimoku_month_base"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"itimoku_month_span"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            
            break;
            
            
        case 3://RSI
        {
            
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_1min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_1min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_1min_3"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_10min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_10min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_10min_3"]];
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_hour_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_hour_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_hour_3"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_day_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_day_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_day_3"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_week_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_week_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_week_3"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"rsi_month_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"rsi_month_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"rsi_month_3"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            
            
            break;
            
        case 4://MACD
        {
            
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_1min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_1min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_1min_3"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_10min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_10min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_10min_3"]];
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_hour_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_hour_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_hour_3"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_day_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_day_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_day_3"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_week_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_week_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_week_3"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"macd_month_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"macd_month_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"macd_month_3"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            
            
            
            break;
            
        case 5://Sストキャス
        {
            
//            switch (ashiSegment.selectedSegmentIndex) {
//                case 0: //1分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_1min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_1min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_1min_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_1min_4"]];
//                    
//                    break;
//                case 1: //10分足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_10min_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_10min_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_10min_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_10min_4"]];
//                    
//                    break;
//                case 2: //時間足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_hour_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_hour_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_hour_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_hour_4"]];
//                    
//                    break;
//                case 3: //日足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_day_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_day_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_day_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_day_4"]];
//                    
//                    break;
//                case 4: //週足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_week_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_week_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_week_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_week_4"]];
//                    
//                    break;
//                case 5: //月足
//                    [numNumberPicker1 setupInputValue: dictionary[@"stochas_month_1"]];
//                    [numNumberPicker2 setupInputValue: dictionary[@"stochas_month_2"]];
//                    [numNumberPicker3 setupInputValue: dictionary[@"stochas_month_3"]];
//                    [numNumberPicker4 setupInputValue: dictionary[@"stochas_month_4"]];
//                    
//                    break;
//                default:
//                    break;
//            }
            
        }
            break;
            
        default:
            break;
    }
}

//各指標、各足種の設定値を一時保存
- (void)saveSettingValues{
    
    switch (nowSelectedIndex_tech) {
        case 0://移動平均

//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"ma_1min_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_1min_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_1min_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 1: //10分足
//                    tempValueMutableDic[@"ma_10min_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_10min_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_10min_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 2: //時間足
//                    tempValueMutableDic[@"ma_hour_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_hour_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_hour_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 3: //日足
//                    tempValueMutableDic[@"ma_day_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_day_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_day_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 4: //週足
//                    tempValueMutableDic[@"ma_week_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_week_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_week_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 5: //月足
//                    tempValueMutableDic[@"ma_month_s"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"ma_month_m"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"ma_month_l"] = numNumberPicker3.inputValueString;
//                    break;
//
//                default:
//                    break;
//            }
            break;

        case 1://ボリンジャー

//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"bollinger_1min_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_1min_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_1min_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 1: //10分足
//                    tempValueMutableDic[@"bollinger_10min_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_10min_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_10min_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 2: //時間足
//                    tempValueMutableDic[@"bollinger_hour_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_hour_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_hour_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 3: //日足
//                    tempValueMutableDic[@"bollinger_day_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_day_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_day_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 4: //週足
//                    tempValueMutableDic[@"bollinger_week_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_week_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_week_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                case 5: //月足
//                    tempValueMutableDic[@"bollinger_month_ma"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"bollinger_month_1"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"bollinger_month_2"] = numNumberPicker3.inputValueString;
//                    break;
//
//                default:
//                    break;
//            }


            break;
        case 2://一目均衡表

//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"itimoku_1min_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_1min_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_1min_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 1: //10分足
//                    tempValueMutableDic[@"itimoku_10min_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_10min_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_10min_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 2: //時間足
//                    tempValueMutableDic[@"itimoku_hour_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_hour_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_hour_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 3: //日足
//                    tempValueMutableDic[@"itimoku_day_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_day_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_day_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 4: //週足
//                    tempValueMutableDic[@"itimoku_week_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_week_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_week_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 5: //月足
//                    tempValueMutableDic[@"itimoku_month_convert"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"itimoku_month_base"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"itimoku_month_span"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                default:
//                    break;
//            }


            break;

        case 3://RSI


//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"rsi_1min_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_1min_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_1min_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 1: //10分足
//                    tempValueMutableDic[@"rsi_10min_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_10min_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_10min_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 2: //時間足
//                    tempValueMutableDic[@"rsi_hour_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_hour_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_hour_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 3: //日足
//                    tempValueMutableDic[@"rsi_day_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_day_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_day_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 4: //週足
//                    tempValueMutableDic[@"rsi_week_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_week_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_week_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                case 5: //月足
//                    tempValueMutableDic[@"rsi_month_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"rsi_month_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"rsi_month_3"] = numNumberPicker3.inputValueString; //label3.text;
//                    break;
//
//                default:
//                    break;
//            }


            break;

        case 4://MACD
//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"macd_1min_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_1min_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_1min_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                case 1: //10分足
//                    tempValueMutableDic[@"macd_10min_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_10min_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_10min_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                case 2: //時間足
//                    tempValueMutableDic[@"macd_hour_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_hour_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_hour_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                case 3: //日足
//                    tempValueMutableDic[@"macd_day_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_day_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_day_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                case 4: //週足
//                    tempValueMutableDic[@"macd_week_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_week_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_week_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                case 5: //月足
//                    tempValueMutableDic[@"macd_month_1"] = numNumberPicker1.inputValueString; // label1.text;
//                    tempValueMutableDic[@"macd_month_2"] = numNumberPicker2.inputValueString; //label2.text;
//                    tempValueMutableDic[@"macd_month_3"] = numNumberPicker3.inputValueString; //label3.text;
//
//
//                    break;
//                default:
//                    break;
//            }


            break;

        case 5://Sストキャス

//            switch (nowSelectedIndex_ashi) {
//                case 0: //1分足
//                    tempValueMutableDic[@"stochas_1min_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_1min_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_1min_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_1min_4"] = numNumberPicker4.inputValueString;
//                    break;
//
//                case 1: //10分足
//                    tempValueMutableDic[@"stochas_10min_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_10min_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_10min_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_10min_4"] = numNumberPicker4.inputValueString;
//
//
//                    break;
//
//                case 2: //時間足
//                    tempValueMutableDic[@"stochas_hour_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_hour_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_hour_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_hour_4"] = numNumberPicker4.inputValueString;
//
//
//                    break;
//
//                case 3: //日足
//                    tempValueMutableDic[@"stochas_day_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_day_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_day_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_day_4"] = numNumberPicker4.inputValueString;
//
//                    
//                    break;
//                    
//                case 4: //週足
//                    tempValueMutableDic[@"stochas_week_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_week_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_week_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_week_4"] = numNumberPicker4.inputValueString;
//                    
//                    
//                    break;
//                    
//                case 5: //月足
//                    tempValueMutableDic[@"stochas_month_1"] = numNumberPicker1.inputValueString;
//                    tempValueMutableDic[@"stochas_month_2"] = numNumberPicker2.inputValueString;
//                    tempValueMutableDic[@"stochas_month_3"] = numNumberPicker3.inputValueString;
//                    tempValueMutableDic[@"stochas_month_4"] = numNumberPicker4.inputValueString;
//                    break;
//                    
//                default:
//                    break;
//            }
            

            
            break;
            
        default:
            break;

    }

}


@end
