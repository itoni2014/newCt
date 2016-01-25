

#import "DetailChartView.h"
#import "ChartSettingView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
#import "DetailChartMainView.h"
#import "DetailChartSubView.h"
#import "DetailChartDatetimeView.h"
#import "DetailChartCandlestickView.h"
#import "ChartMovAvgView.h"
#import "ChartBollingerView.h"
#import "ChartIchimokuView.h"
#import "ChartRsiView.h"
#import "ChartMacdView.h"
#import "ChartStochasView.h"
#import "ChartVolumeView.h"
#import "FourPricesView.h"
#import "ChartNamesView.h"
#import "SubChartNamesView.h"
//#import "DropDownListView.h"

@interface DetailChartView()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    /* 詳細チャート・メイン */
    DetailChartMainView *chartMainView;
    /* 詳細チャート・ローソク */
    DetailChartCandlestickView *chartCandlestickView;
    /* 詳細チャート・サブ */
    DetailChartSubView *chartSubView;
    /* 詳細チャート・X軸（日付時間） */
    DetailChartDatetimeView *chartDatetimeView;
    /* 詳細チャート・移動平均 */
    ChartMovAvgView *chartMovAvgView;
    /* 詳細チャート・ボリンジャー */
    ChartBollingerView *bollingerView;
    /* 詳細チャート・一目均衡表 */
    ChartIchimokuView *ichimokuView;
    /* 詳細チャート・RSI */
    ChartRsiView *rsiView;
    /* 詳細チャート・MACD */
    ChartMacdView *macdView;
    /* 詳細チャート・Sストキャス */
    ChartStochasView *stochasView;
    /* 詳細チャート・出来高 */
    ChartVolumeView *volumeView;
    /* メインテクニカル名称ビュー */
    ChartNamesView *chartNamesView;
    /* サブテクニカル名称ビュー */
    SubChartNamesView *subChartNamesView;
    /* テクニカルメニュー */
    UIView *technicalMenuView;
    /* オプションメニュー */
    UIView *optionMenuView;
    /* X軸カーソルビュー */
    UIView *xCursorView;
    /* X軸カーソルボタン */
    UIButton *xCursorButton;
    /* Y軸カーソルビュー */
    UIView *ycursorView;
    /* Y軸カーソルボタン */
    UIButton *yCursorButton;
    /* 四本値ビュー */
    FourPricesView *fourPricesView;
    /* ヘッダービュー */
    UIView *topBarView;
    /* フッタービュー */
    UIView *bottomBarView;
    /* チャートグループビュー */
    UIView *chartArea;
    /* 指数選択 */
    UITableView *indexTableView;
    /* 限月選択 */
    UITableView *tsukiTableView;
    /* 足種選択 */
    UITableView *ashiTableView;
    /* テクニカルメニュー */
    UITableView *technicalMenuTableView;
    /* オプションメニュー */
    UITableView *optionMenuTableView;
    /* 指数選択ボタン */
    UIButton *indexNameButton;
    /* 限月選択ボタン */
    UIButton *tsukiButton;
    
    UIPanGestureRecognizer *panGestureRecognizerFourPrices;
    UIPanGestureRecognizer *panGestureRecognizerPriceIndicator;

    
    CGPoint floatPriceViewCurrentLocation;
    CGPoint fourPricesViewNowLocation;
    
    CGFloat bottomBarHeight;
//    ChartMemoryManager *chartMemoryManager;

    UIActivityIndicatorView* activityIndicatorView;
}
@end

@implementation DetailChartView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];

        bottomBarHeight = [[NSString stringWithFormat:@"%.2f", frame.size.height / 10.0] floatValue];

        
        //ヘッダーグループ
        [self initTopBar];

        //チャートグループ
        chartArea = [[UIView alloc]initWithFrame:CGRectMake(0, topBarView.frame.size.height, frame.size.width, frame.size.height - topBarView.frame.size.height - bottomBarHeight)];
        [self addSubview:chartArea];
        

        
        self.chartWidth = chartArea.frame.size.width * 0.86;
        [ChartBox sharedInstance].detailChartViewWidth = self.chartWidth;
        self.scrollContentWidth = ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval) * CANDLESTICK_COUNT_ALL;

        self.chartHeight = chartArea.frame.size.height * 0.88;
        self.datetimeHeight = self.chartHeight * 0.045;
        self.subchartHeight = self.chartHeight * 0.22;
        
        self.subChartStartY = self.subchartHeight * 0.2;
        self.subChartValidHeight = self.subchartHeight - self.subChartStartY;


        //チャートビュー初期化
        [self initChartViews];
        
        [self updateChartsFrame];
        
        [self updateCharts_main];
        
        [self updateChartLabels_sub];
        
        //X軸カーソルビュー
        [self initXCursorView];
        
        //Y軸カーソルビュー
        [self initYcursorView];

        //フッターグループ
        [self initBottomBar];

        //テクニカルメニュー、オプションメニュー作成
        [self initMenu];

        //４本値ビュー
        fourPricesView = [[FourPricesView alloc]initWithFrame:CGRectMake(self.chartWidth - self.chartWidth / 4.0, 2, self.chartWidth / 4.0, self.chartHeight / 5.0) orientation:NO];
        fourPricesView.hidden = YES;
        fourPricesView.userInteractionEnabled = NO;
        [chartArea addSubview: fourPricesView];
        fourPricesViewNowLocation = fourPricesView.center;
        
        activityIndicatorView = [ [UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.chartWidth/2, self.chartHeight/2, 30.0, 30.0)];
        activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
        activityIndicatorView.hidesWhenStopped = NO;
        [self addSubview: activityIndicatorView];
        [activityIndicatorView startAnimating];

    }
    
    return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == indexTableView || tableView == ashiTableView || tableView == tsukiTableView)
        return 1;
    else
        return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == indexTableView){
        return [ChartBox sharedInstance].indexNameArray.count;
    }
    else if(tableView == tsukiTableView){
        return [ChartBox sharedInstance].tsukiArray.count;
    }
    else if(tableView == ashiTableView){
        return [ChartBox sharedInstance].ashiNameArray.count;
    }
    else if(tableView == technicalMenuTableView){
        return section == 0 ? 4 : 5;
    }
    else{
        return section == 0 ? 3 : 2;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionName = @"";
    if(tableView == indexTableView){
        sectionName = @"";
    }
    else if(tableView == ashiTableView){
        sectionName = @"";
    }
    else if(tableView == tsukiTableView){
        sectionName = @"";
    }
    else if(tableView == technicalMenuTableView){
        switch (section){
            case 0:
                sectionName = @"メインチャート";
                break;
            case 1:
                sectionName = @"サブチャート";
                break;
            default:
                break;
        }
    }
    else{
        switch (section){
            case 0:
                sectionName = @"データ表示";
                break;
            case 1:
                sectionName = @"オプション";
                break;
            default:
                break;
        }
        
    }
    
    return sectionName;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == technicalMenuTableView || tableView == optionMenuTableView){
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(0, 0, 320, 22);
        myLabel.font = [UIFont boldSystemFontOfSize:9.0];
        myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        myLabel.textColor = [UIColor whiteColor];
        myLabel.backgroundColor = [UIColor colorWithRed:74/255.0 green:91/255.0 blue:107/255.0 alpha: 0.7 ];
        
        UIView *headerView = [[UIView alloc] init];
        [headerView addSubview:myLabel];
        
        return headerView;
    }
    else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if(tableView == indexTableView){ //指数選択
        cell.textLabel.text = [ChartBox sharedInstance].indexNameArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        
        if([cell.textLabel.text isEqualToString: indexNameButton.titleLabel.text]){
            cell.backgroundColor = [UIColor colorWithRed:101/255.0 green:122/255.0 blue:141/255.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor darkGrayColor];
        }
        
    }
    else if(tableView == tsukiTableView){
        cell.textLabel.text = [ChartBox sharedInstance].tsukiArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        
        if([cell.textLabel.text isEqualToString: tsukiButton.titleLabel.text]){
            cell.backgroundColor = [UIColor colorWithRed:101/255.0 green:122/255.0 blue:141/255.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor darkGrayColor];
        }
        
    }
    else if(tableView == ashiTableView){
        cell.textLabel.text = [ChartBox sharedInstance].ashiNameArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        
        if([cell.textLabel.text isEqualToString: self.ashiButton.titleLabel.text]){
            //            cell.backgroundColor = [UIColor colorWithRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0];
            cell.backgroundColor = [UIColor colorWithRed:101/255.0 green:122/255.0 blue:141/255.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
            
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
        }
        
    }
    else if(tableView == technicalMenuTableView){ //テクニカルメニュー
        cell.textLabel.font = [UIFont systemFontOfSize:9.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        if(indexPath.section == 0) {//メインチャート
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"移動平均";
                    break;
                case 1:
                    cell.textLabel.text = @"ボリンジャー";
                    break;
                case 2:
                    cell.textLabel.text = @"一目均衡表";
                    break;
                case 3:
                    cell.textLabel.text = @"表示なし";
                    break;
                default:
                    break;
            }
            
        }
        else { //サブチャート
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"RSI";
                    break;
                case 1:
                    cell.textLabel.text = @"MACD";
                    break;
                case 2:
                    cell.textLabel.text = @"Sストキャス";
                    break;
                case 3:
                    cell.textLabel.text = @"出来高";
                    break;
                case 4:
                    cell.textLabel.text = @"表示なし";
                    break;
                default:
                    break;
            }
            
        }
    }
    else{ // オプションメニュー
        cell.textLabel.font = [UIFont systemFontOfSize:9.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        if(indexPath.section == 0) { //データ表示
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"4本値";
                    break;
                case 1:
                    cell.textLabel.text = @"全表示";
                    break;
                case 2:
                    cell.textLabel.text = @"表示なし";
                    break;
                    
                default:
                    break;
            }
            
        }
        else { // オプション
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Y軸可変";
                    //                    cell.accessoryType = self.yAxisFixed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 1:
                    cell.textLabel.text = @"Y軸固定";
                    //                    cell.accessoryType = self.yAxisFixed ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                default:
                    break;
            }
            
        }
        
    }
    
    return cell;
    
}

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    //    MessageCell *cell = (MessageCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    if(tableView == ashiTableView){
        return self.ashiButton.frame.size.height;
    }
    else if(tableView == indexTableView){
        return indexNameButton.frame.size.height;
    }
    else if(tableView == tsukiTableView){
        return tsukiButton.frame.size.height;
    }
    else {
        return 32.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //    cell.backgroundColor = [UIColor colorWithHue:0.61 saturation:0.09 brightness:0.99 alpha:1.0];
    
    if(tableView == technicalMenuTableView || tableView == optionMenuTableView){
        cell.backgroundColor = [UIColor clearColor];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == technicalMenuTableView || tableView == optionMenuTableView){
        return 22.0;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == ashiTableView){
        [[ChartBox sharedInstance] clearDetailChartData];
        [self redrawChart: YES];
    }

    
    if(tableView == indexTableView){
        [UIView animateWithDuration:0.3 animations:^{
            [indexTableView setFrame:CGRectMake(indexTableView.frame.origin.x, bottomBarView.frame.origin.y, indexTableView.frame.size.width, indexTableView.frame.size.height)];
            
        } completion:^(BOOL finished) {
            [indexNameButton setTitle: [ChartBox sharedInstance].indexNameArray[indexPath.row] forState:UIControlStateNormal];
        }];
        
    }
    else if(tableView == tsukiTableView){
        [UIView animateWithDuration:0.3 animations:^{
            [tsukiTableView setFrame:CGRectMake(tsukiTableView.frame.origin.x, bottomBarView.frame.origin.y, tsukiTableView.frame.size.width, tsukiTableView.frame.size.height)];
            
        } completion:^(BOOL finished) {
            [tsukiButton setTitle: [ChartBox sharedInstance].tsukiArray[indexPath.row] forState:UIControlStateNormal];
        }];
        
    }
    else if(tableView == ashiTableView){
        
        [UIView animateWithDuration:0.3 animations:^{
            [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, bottomBarView.frame.origin.y, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
            
        } completion:^(BOOL finished) {
            activityIndicatorView.hidden = NO;
            [activityIndicatorView startAnimating];

            [self.ashiButton setTitle: [ChartBox sharedInstance].ashiNameArray[indexPath.row] forState:UIControlStateNormal];
//            switch (indexPath.row) {
//                case 0: //一分足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MINUTES1;
//                    break;
//                case 1: //１０分足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MINUTES10;
//                    break;
//                case 2: //時間足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_TIME;
//                    break;
//                case 3://日足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_DAY;
//                    break;
//                case 4://週足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_WEEK;
//                    break;
//                case 5://月足
//                    [ChartBox sharedInstance].ashiTypeSelected = BAR_TYPE_MONTH;
//                    break;
//                default:
//                    break;
//
//            }
            
//            if(self.managerViewController.ashiSelected.length > 0){
//                [self.managerViewController fetchDataFromYahoo];
//            }
//            [self currentContentsPage];

            
        }];
        
    }
    else if(tableView == technicalMenuTableView){
        if(indexPath.section == 0){//メインチャート
            [ChartBox sharedInstance].needShowMovAvg = NO;
            [ChartBox sharedInstance].needShowBollinger = NO;
            [ChartBox sharedInstance].needShowIchimoku = NO;
            switch (indexPath.row) {
                case 0:
                    [ChartBox sharedInstance].needShowMovAvg = YES;
                    break;
                    
                case 1:
                    [ChartBox sharedInstance].needShowBollinger = YES;
                    
                    break;
                case 2:
                    [ChartBox sharedInstance].needShowIchimoku = YES;
                    
                    break;
                case 3:
                    break;
                    
                default:
                    break;
            }
            
        }
        else if(indexPath.section == 1){//サブチャート
            [ChartBox sharedInstance].needShowSub_rsi = NO;
            [ChartBox sharedInstance].needShowSub_macd = NO, [ChartBox sharedInstance].needShowSub_stochas = NO, [ChartBox sharedInstance].needShowSub_volume = NO;
            [ChartBox sharedInstance].needShowSubChart = NO;
            switch (indexPath.row) {
                case 0: //RSI
                    [ChartBox sharedInstance].needShowSubChart = YES;
                    [ChartBox sharedInstance].needShowSub_rsi = YES;
                    
                    break;
                case 1: //MACD
                    [ChartBox sharedInstance].needShowSubChart = YES;
                    [ChartBox sharedInstance].needShowSub_macd = YES;
                    
                    break;
                case 2: //Sストキャス
                    [ChartBox sharedInstance].needShowSubChart = YES;
                    [ChartBox sharedInstance].needShowSub_stochas = YES;
                    
                    break;
                case 3: //出来高
                    [ChartBox sharedInstance].needShowSubChart = YES;
                    [ChartBox sharedInstance].needShowSub_volume = YES;
                    
                    break;
                case 4: //表示なし
                    break;
                default:
                    break;
            }
            
        }
        
        
        [self closeMenu:technicalMenuView];
    }
    else{
        if(indexPath.section == 0){
            switch (indexPath.row) {
                case 0: //4本値
                    fourPricesView.hidden = YES;
                    xCursorView.hidden = NO;
                    break;
                case 1: //全表示
                    fourPricesView.hidden = NO;
                    xCursorView.hidden = NO;
                    break;
                case 2: //表示なし
                    fourPricesView.hidden = YES;
                    xCursorView.hidden = YES;
                    break;
                default:
                    break;
            }
            
        }
        else if(indexPath.section == 1){
            switch (indexPath.row) {
                case 0: //Y軸可変
                    [ChartBox sharedInstance].yAxisFixed = NO;
                    break;
                case 1: //Y軸固定
                    [ChartBox sharedInstance].yAxisFixed = YES;
                    break;
                default:
                    break;
            }
        }
        
        [self closeMenu:optionMenuView];
    }
    
    
    if(tableView == technicalMenuTableView){
        if(indexPath.section == 0){
            [self updateCharts_main];
        }
        else{
            [self updateChartsFrame];
            [self updateChartLabels_sub];
        }
        
//        if([ChartBox sharedInstance].yAxisFixed){
//            [[ChartBox sharedInstance] getLimitValueInAll];
//        }
//        else{
//            [[ChartBox sharedInstance] getLimitValueInRange: self.scrollView.contentOffset.x];
//        }
        [self redrawChart: YES];
        
        
    }
    else{
        if(indexPath.section == 0){//4本値を表示するか
            
        }
        else{ //Y軸可変・固定
//            if([ChartBox sharedInstance].yAxisFixed){
//                [[ChartBox sharedInstance] getLimitValueInAll];
//            }
//            else{
////                [self getLimitValueInRange];
//                [[ChartBox sharedInstance] getLimitValueInRange: self.scrollView.contentOffset.x];
//            }
            [self redrawChart: YES];
            
        }
        
    }
    
    
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width - scrollView.frame.size.width){
        

        //        NSLog(@"%.1f >>>> %.1f >>>> %.1f", scrollView.contentSize.width,  scrollView.contentOffset.x, scrollView.contentOffset.x + scrollView.frame.size.width );

        
        [self updateFourPrices];

        
        if( [ChartBox sharedInstance].yAxisFixed ){ //Y軸固定
            
            [chartCandlestickView setNeedsDisplay];//高値・安値の更新
            
        }
        else{ //Y軸可変

//            [[ChartBox sharedInstance] getLimitValueInRange: scrollView.contentOffset.x];
            [self redrawChart: NO];

            
            //
            [self changeFloatPriceIndicator];
        }

    }
    
    

}

#pragma mark - Pan Gesture Recognizer

- (void)handlePan:(id)sender {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    CGPoint location = [pan locationInView: chartArea];
    
    if(pan == panGestureRecognizerPriceIndicator){
        if(location.y > 0 && location.y < /*self.chartHeight - self.datetimeHeight*/ chartMainView.frame.size.height){
            floatPriceViewCurrentLocation = location;
            [ycursorView setCenter:CGPointMake(ycursorView.center.x, location.y)];
            [yCursorButton setCenter:CGPointMake(yCursorButton.center.x, location.y)];
            
            [self changeFloatPriceIndicator];
        }
        
    }
    else{ //X軸カーソルビュー(四本値)
        if(location.x > 0 && location.x < self.chartWidth){
            fourPricesView.hidden = NO;
            fourPricesViewNowLocation = location;
            
            [xCursorView setCenter:CGPointMake(location.x, xCursorView.center.y)];
            [xCursorButton setCenter:CGPointMake(location.x, xCursorButton.center.y)];
            if(location.x + fourPricesView.frame.size.width < self.chartWidth){
                [fourPricesView setFrame:CGRectMake(location.x, fourPricesView.frame.origin.y, fourPricesView.frame.size.width, fourPricesView.frame.size.height)];
            }
            
            [self updateFourPrices];
        }
        
    }
    
    
}



#pragma mark - Button Tapped

- (void)settingButtonTapped:(id)sender{
    
//    ChartSettingView *chartSettingView = [[ChartSettingView alloc]initWithFrame: CGRectMake(self.frame.size.width * 0.1, 0, self.frame.size.width * 0.8, self.frame.size.height * 0.85)];
    ChartSettingView *chartSettingView = [[ChartSettingView alloc]initWithFrame: CGRectMake(self.frame.size.width * 0.1, 20,  self.frame.size.height * 0.85, self.frame.size.width * 0.8)];
    chartSettingView.detailChartView = self;

    [self addSubview:chartSettingView];
    [sender setEnabled:NO];

}



- (void)menuButtonTapped: (id)sender{
    UIButton *button = (UIButton *)sender;
    UIView *view;

    if(button.frame.origin.y == 0.0){
//        NSLog(@"technicalメニュー");
        [self bringSubviewToFront:technicalMenuView];
        view = technicalMenuView;
        ((UIButton *)[technicalMenuView viewWithTag:1]).enabled = YES;
        ((UIButton *)[technicalMenuView viewWithTag:2]).enabled = NO;
        

    }
    else{
//        NSLog(@"optionメニュー");
        [self bringSubviewToFront:optionMenuView];
        view = optionMenuView;
        ((UIButton *)[optionMenuView viewWithTag:1]).enabled = NO;
        ((UIButton *)[optionMenuView viewWithTag:2]).enabled = YES;

    }

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         if(view.center.x == 50.f){

                             if(button.frame.origin.y == 0.0)
                                 [view setCenter:CGPointMake(-26.0, technicalMenuView.center.y)];
                             else
                                 [view setCenter:CGPointMake(-26.0, optionMenuView.center.y)];

                             ((UIButton *)[technicalMenuView viewWithTag:1]).enabled = YES;
                             ((UIButton *)[technicalMenuView viewWithTag:2]).enabled = YES;
                             ((UIButton *)[optionMenuView viewWithTag:1]).enabled = YES;
                             ((UIButton *)[optionMenuView viewWithTag:2]).enabled = YES;

                         }
                         else{
                             if(button.frame.origin.y == 0.0)
                                 [view setCenter:CGPointMake(50.0, technicalMenuView.center.y)];
                             else
                                 [view setCenter:CGPointMake(50.0, optionMenuView.center.y)];
                             
                         }
                     
                     } completion:^(BOOL finished) {
                         
                     }];
    

    
}

//足種選択ボタン
- (void)ashiButtonTapped{
    if([self needCloseTheView]){
        return;
    }

    [ashiTableView reloadData];
    
    NSTimeInterval duration;
    if(ashiTableView.frame.origin.y == bottomBarView.frame.origin.y){
        duration = 0.4;
    }
    else{
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration animations:^{
        if(ashiTableView.frame.origin.y == bottomBarView.frame.origin.y){
            CGRect rect = CGRectMake(ashiTableView.frame.origin.x, bottomBarView.frame.origin.y - ashiTableView.frame.size.height, ashiTableView.frame.size.width, ashiTableView.frame.size.height);
            [ashiTableView setFrame: rect];
        }
        else{
            [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, bottomBarView.frame.origin.y, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
        }
        
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}

//指数選択ボタン
- (void)indexButtonTapped: (UIButton *)button{
    if([self needCloseTheView]){
        return;
    }

    [indexTableView reloadData];
    
    NSTimeInterval duration;
    if(indexTableView.frame.origin.y == bottomBarView.frame.origin.y){
        duration = 0.4;
    }
    else{
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration animations:^{
        if(indexTableView.frame.origin.y == bottomBarView.frame.origin.y){
            CGRect rect = CGRectMake(indexTableView.frame.origin.x, bottomBarView.frame.origin.y - indexTableView.frame.size.height, indexTableView.frame.size.width, indexTableView.frame.size.height);
            [indexTableView setFrame: rect];
        }
        else{
            [indexTableView setFrame:CGRectMake(indexTableView.frame.origin.x, bottomBarView.frame.origin.y, indexTableView.frame.size.width, indexTableView.frame.size.height)];
        }
        
        
    } completion:^(BOOL finished) {
        
        
    }];
}

//限月選択ボタン
- (void)tsukiButtonTapped: (UIButton *)button{
    if([self needCloseTheView]){
        return;
    }
    
    [tsukiTableView reloadData];
    
    NSTimeInterval duration;
    if(tsukiTableView.frame.origin.y == bottomBarView.frame.origin.y){
        duration = 0.4;
    }
    else{
        duration = 0.3;
    }
    
    [UIView animateWithDuration:duration animations:^{
        if(tsukiTableView.frame.origin.y == bottomBarView.frame.origin.y){
            CGRect rect = CGRectMake(tsukiTableView.frame.origin.x, bottomBarView.frame.origin.y - tsukiTableView.frame.size.height, tsukiTableView.frame.size.width, tsukiTableView.frame.size.height);
            [tsukiTableView setFrame: rect];
        }
        else{
            [tsukiTableView setFrame:CGRectMake(tsukiTableView.frame.origin.x, bottomBarView.frame.origin.y, tsukiTableView.frame.size.width, tsukiTableView.frame.size.height)];
        }
        
        
    } completion:^(BOOL finished) {
        
        
    }];
}

//画面回転
- (void)changeOrientationButtonTapped{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//    [self.managerViewController updateChartVisible:NO];
//    [self.managerViewController switchChart:NO];

}

- (void)subviewButtonTapped: (UIButton *)button{
    if(button.tag == 1)
        return;
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//    [self.managerViewController updateChartVisible:NO];
//    [self.managerViewController switchChart:NO];
//    [self.managerViewController pagerButtonSelected: button];
    
}

- (void)changeSubview: (id)sender{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if(segment.selectedSegmentIndex == 0){
        NSLog(@"チャート");
    }
    else if(segment.selectedSegmentIndex == 1){
        NSLog(@"注文");
        
        UIButton *button = [[UIButton alloc]init];
        button.tag = 1;
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//        [self.managerViewController updateChartVisible:NO];
//        [self.managerViewController switchChart:NO];
        
//        [self.managerViewController pagerButtonSelected: button];
        
        
    }
    
    
}

//
//#pragma mark -
//#pragma mark 基盤からの戻り
//- (void)responseEvent:(EventResponseModel *)eventResponseModel {
//    
//    if (!eventResponseModel) {
//        return;
//    }
//    
//    if ([eventResponseModel.status isEqualToString:STATUS_NG]) {
//        return;
//    }
//    
//    
//    
//    /** チャート株式・先物OP（過去） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OW_FUT_IDX_CHA]] ) {
//        
//        //チャートデータ関連
//        if(chartMemoryManager == nil)
//            chartMemoryManager = [[ChartMemoryManager alloc] init];
//        
//        NSMutableArray *mutableArray;
//        
//        if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES1]){
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MINUTES10]){
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_TIME]){
//            
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_DAY]){
//            mutableArray = [chartMemoryManager selectOhlcHisDay];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_WEEK]){
//            mutableArray = [chartMemoryManager selectOhlcHisWeek];
//        }
//        else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString: BAR_TYPE_MONTH]){
//            mutableArray = [chartMemoryManager selectOhlcHisOth];
//        }
//        
//        
//        
//        for(OhlcModel *ohlcModel in mutableArray){
//            OhlcBean *bean = [[OhlcBean alloc]init];
//            bean.fourValuesDate = ohlcModel.date;//日付
//            bean.fourValuesTime = ohlcModel.time;//時刻
//            bean.openPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.openPrice]; //始値
//            bean.highPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.highPrice]; //高値
//            bean.lowPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.lowPrice]; //安値
//            bean.closePrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.closePrice]; //終値
//            bean.turnover = [ohlcModel.turnover integerValue]; //出来高
//            bean.previousOpenPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousOpenPrice]; //前日始値
//            bean.previousHighPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousHighPrice]; //前日高値
//            bean.previousLowPrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousLowPrice]; //前日安値
//            bean.previousClosePrice = [[NSDecimalNumber alloc] initWithString: ohlcModel.previousClosePrice]; //前日終値
//            
//            [[ChartBox sharedInstance].ohlcMutableArray addObject:bean];
//        }
//        
//        
//        NSLog(@"チャート過去(株式・先物) 情報取得：%ld件", [ChartBox sharedInstance].ohlcMutableArray.count);
//        
//        
//        
//        if([ChartBox sharedInstance].ohlcMutableArray.count == 0){
//            NSString *message = @"チャート情報を取得できません。描画終了";
//            NSLog( @"%@", message );
//            
//            //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
//            //            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//            
//        }
//        else{
//            [self.managerViewController.dChartView redrawChart: YES];
//
//        }
//        
//        
//        
//        
//    }
//    
//    /** チャート株式・先物OP（リアル） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OX_FUT_IDX_CHA] ] ) {
//        NSLog(@"チャートリアル(株式・先物) 情報が届いた");
//    }
//    
//    /** チャート指数（過去） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OY] ] ) {
//        NSLog(@"チャート過去(指数) 情報が届いた");
//    }
//    
//    /** チャート指数（リアル） */
//    if ( [eventResponseModel.tag isEqualToString: [IdentifierTagFuturesIdxChart toString:ID_TAG_OZ] ] ) {
//        NSLog(@"チャートリアル(指数) 情報が届いた");
//    }
//    
//    //TICK
//    
//    
//    
//    
//    
//}
//
//- (void)currentContentsPage {
//    [super currentContentsPage];
//    NSDictionary *sendInformationDictionary = @{COMMODITY_KUBUN:self.commodityKubun, //商品区分
//                                                COMMODITY_CODE: self.commodityCode, //商品コード
//                                                BARTYPE_KUBUN: [ChartBox sharedInstance].ashiTypeSelected, //足区分
//                                                ISSUE_CODE: self.issueCode, //銘柄コード
//                                                EX_CODE: self.exCode}; //取引所コード
//    
//    //チャート情報取得
//    [self requestEvent:START sendInformation:sendInformationDictionary sendInformationList:nil];
//    
//    //銘柄情報取得
//    NSArray *requestDataList = [[NSArray alloc]initWithObjects:sendInformationDictionary, nil];
//    [self requestEvent:START_NEXT1 sendInformation:nil sendInformationList:requestDataList];
//    
//}
//
//
//- (void)eliminated {
////    [self clearDrawInfo];
//    [self requestEvent:FINISH sendInformation:nil sendInformationList:nil];
//    
//}
//
//
//- (NSString *)screenId {
//    super.screenId = S2006_2;
//    return super.screenId;
//}


#pragma mark - ビューの初期化

//ヘッダーグループを生成
- (void)initTopBar{
    topBarView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, self.frame.size.width, 32)];
    topBarView.backgroundColor = [UIColor colorWithRed:102/255.0 green:171/255.0 blue:215/255.0 alpha:1.0];
    
    CGFloat btnWidth = 60.f;
    for(NSString *name in [ChartBox sharedInstance].subviewNameArray){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle: name forState:UIControlStateNormal];
        button.tag = [[ChartBox sharedInstance].subviewNameArray indexOfObject:name] + 1;
        [button setTitle:name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(60 + btnWidth * [[ChartBox sharedInstance].subviewNameArray indexOfObject:name] * 1.2, 12, btnWidth, 20);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button addTarget:self action:@selector(subviewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [topBarView addSubview:button];
        
    }
    
    //    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems: [ChartBox sharedInstance].subviewNameArray ];
    //    segment.frame = CGRectMake(70, 0, topBarView.frame.size.width * 0.55, topBarView.frame.size.height);
    //    [segment addTarget:self action:@selector(changeSubview:) forControlEvents:UIControlEventValueChanged];
    //    segment.selectedSegmentIndex = 0;
    //    //        segment.tintColor = [UIColor clearColor];
    //    [topBarView addSubview:segment];
    
    
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    homeBtn.frame = CGRectMake(self.frame.size.width-60, 5, 22, 22);
    [homeBtn setBackgroundImage:[UIImage imageNamed:@"icon_navi_home@2x.png"] forState:UIControlStateNormal];
    [topBarView addSubview:homeBtn];
    
    
    [self addSubview:topBarView];
    
}

//チャートビューを生成
- (void)initChartViews{
    //テクニカル名称
    chartNamesView = [[ChartNamesView alloc]initWithFrame:CGRectMake(120, 0, self.chartWidth/6, self.chartHeight/2.5) orientation:NO];
    [chartArea addSubview:chartNamesView];
    
    subChartNamesView = [[SubChartNamesView alloc]initWithFrame:CGRectMake(0, self.chartHeight - self.subchartHeight - self.datetimeHeight, self.chartWidth / 6, self.subchartHeight + self.datetimeHeight) orientation:NO];
    [chartArea addSubview:subChartNamesView];

    //チャートメイン
    chartMainView = [[DetailChartMainView alloc] init];
    chartMainView.backgroundColor = [UIColor clearColor];
    chartMainView.detail = self;
    [chartArea addSubview:chartMainView];

    //チャートサブ
    CGRect subFrame = CGRectMake(0, self.chartHeight - self.subchartHeight - self.datetimeHeight, self.frame.size.width, self.subchartHeight);
    chartSubView = [[DetailChartSubView alloc] initWithFrame:subFrame];
    chartSubView.backgroundColor = [UIColor clearColor];
    chartSubView.detail = self;
    [chartArea addSubview:chartSubView];
    
    
    //ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.chartWidth, self.chartHeight)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    [chartArea addSubview:self.scrollView];
//    NSLog(@">>>>>>>%.2f, %.2f", self.scrollContentWidth, self.scrollView.frame.size.width);
    [self.scrollView setContentSize:CGSizeMake(self.scrollContentWidth, self.scrollView.frame.size.height)];
    self.scrollView.contentOffset = CGPointMake(self.scrollContentWidth - self.scrollView.frame.size.width, 0);
//    NSLog(@">>>>>>>>>>%.2f, %.2f", self.scrollView.contentSize.width, self.scrollView.frame.size.width);

    
    
    //NSLog(@"%.3f---%.3f---%.4f---%.4f", [ChartBox sharedInstance].candleStickBodyWidth, [ChartBox sharedInstance].candleStickInterval, contentWidth, self.scrollView.frame.size.width);
    //        NSLog(@"%.3f---%.3f---%.0f---%.0f", [ChartBox sharedInstance].str1.floatValue, [ChartBox sharedInstance].str2.floatValue, contentWidth, self.scrollView.frame.size.width);
    
    
    //ローソク
    chartCandlestickView = [[DetailChartCandlestickView alloc]init];
    chartCandlestickView.backgroundColor = [UIColor clearColor];
    chartCandlestickView.detail = self;
    [self.scrollView addSubview:chartCandlestickView];
    
    //移動平均
    chartMovAvgView = [[ChartMovAvgView alloc]init];
    chartMovAvgView.backgroundColor = [UIColor clearColor];
    chartMovAvgView.detail = self;
    [self.scrollView addSubview:chartMovAvgView];
    
    //ボリンジャー
    bollingerView = [[ChartBollingerView alloc]init];
    bollingerView.backgroundColor = [UIColor clearColor];
    bollingerView.detail = self;
    [self.scrollView addSubview:bollingerView];
    
    //一目均衡表
    ichimokuView = [[ChartIchimokuView alloc]init];
    ichimokuView.backgroundColor = [UIColor clearColor];
    ichimokuView.detail = self;
    [self.scrollView addSubview:ichimokuView];
    
    
    
    CGRect subContentFrame = CGRectMake(0, self.chartHeight - self.subchartHeight - self.datetimeHeight, self.scrollContentWidth, self.subchartHeight);

    //RSI
    rsiView = [[ChartRsiView alloc] initWithFrame:subContentFrame];
    rsiView.backgroundColor = [UIColor clearColor];
    rsiView.detail = self;
    [self.scrollView addSubview:rsiView];
    
    //MACD
    macdView = [[ChartMacdView alloc] initWithFrame:subContentFrame];
    macdView.backgroundColor = [UIColor clearColor];
    macdView.detail = self;
    [self.scrollView addSubview:macdView];
    
    //Sストキャス
    stochasView = [[ChartStochasView alloc] initWithFrame:subContentFrame];
    stochasView.backgroundColor = [UIColor clearColor];
    stochasView.detail = self;
    [self.scrollView addSubview:stochasView];
    
    //出来高
    volumeView = [[ChartVolumeView alloc] initWithFrame:subContentFrame];
    volumeView.backgroundColor = [UIColor clearColor];
    volumeView.detail = self;
    [self.scrollView addSubview:volumeView];
    
    //日付時間
    chartDatetimeView = [[DetailChartDatetimeView alloc]initWithFrame:CGRectMake(0, self.chartHeight - self.datetimeHeight, self.scrollContentWidth, self.datetimeHeight)];
    chartDatetimeView.backgroundColor = [UIColor clearColor];
    chartDatetimeView.detail = self;
    [self.scrollView addSubview:chartDatetimeView];

}


//フッターグループを生成
- (void)initBottomBar{
//    CGFloat barViewHeight = [[NSString stringWithFormat:@"%.2f", self.frame.size.height / 10.0] floatValue];
    UIFont *font = [UIFont systemFontOfSize:12.0];
    
    bottomBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - bottomBarHeight, self.frame.size.width, bottomBarHeight)];
    bottomBarView.backgroundColor = [UIColor colorWithRed:102/255.0 green:171/255.0 blue:215/255.0 alpha:1.0];
    
    
    CGRect ashiRect = CGRectMake(bottomBarView.frame.size.width * 0.55, 0, bottomBarView.frame.size.width*0.14, bottomBarView.frame.size.height);
    
    
    
    //    int viewHeight = 30*SIZE;
    //    UIView *viewMenu = [[UIView alloc]initWithFrame: ashiRect/*CGRectMake(0, self.frame.size.height-viewHeight, self.frame.size.width, viewHeight)*/];
    //    [self addSubview:viewMenu];
    
    //    chooseArray = [NSMutableArray arrayWithArray:@[ @[@"日足", @"週足", @"月足"], ]];
    //    DropDownListView * dropDownView = [[DropDownListView alloc] initWithFrame: ashiRect dataSource:self delegate: self backColor: @"white" size:CGRectMake(0, 3, ashiRect.size.width, ashiRect.size.height-3)];
    //    dropDownView.buttonView = viewMenu;
    //    dropDownView.editJuge = YES;
    //    dropDownView.mSuperView = self;
    //
    //    [barView addSubview:dropDownView];
    
    
    //銘柄名
    UILabel *issueNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, bottomBarView.frame.size.width * 0.1, bottomBarView.frame.size.height)];
    issueNameLabel.textColor = [UIColor whiteColor];
    issueNameLabel.text = @"銘柄名";
    issueNameLabel.tag = 1;
    issueNameLabel.font = [UIFont systemFontOfSize:14.0];
    [bottomBarView addSubview:issueNameLabel];
//    if([COMMODITY_KUBUN_IDX isEqualToString:self.commodityKubun]){
//        issueNameLabel.hidden = YES;//指数の場合非表示
//    }
//    else{
//        issueNameLabel.hidden = NO;
//    }
    
    
    //銘柄コード 
    UILabel *issueCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(issueNameLabel.frame.origin.x + issueNameLabel.frame.size.width + 5, 0, bottomBarView.frame.size.width * 0.08, bottomBarView.frame.size.height)];
    issueCodeLabel.textColor = [UIColor whiteColor];
    issueCodeLabel.text = @"銘柄コード";
    issueCodeLabel.tag = 2;
    issueCodeLabel.font = [UIFont systemFontOfSize:14.0];
    [bottomBarView addSubview:issueCodeLabel];
    
//    if([COMMODITY_KUBUN_FUTURES isEqualToString:self.commodityKubun] || [COMMODITY_CODE_MINI isEqualToString:self.commodityKubun] || [COMMODITY_KUBUN_IDX isEqualToString:self.commodityKubun]){
//        issueCodeLabel.hidden = YES;//先物、先物ミニ、指数
//    }
//    else{
//        issueCodeLabel.hidden = NO;
//    }
    
    //所属市場
    UILabel *issueMarketLabel =[[UILabel alloc]initWithFrame:CGRectMake(issueCodeLabel.frame.origin.x + issueCodeLabel.frame.size.width + 5, 0, bottomBarView.frame.size.width * 0.08, bottomBarView.frame.size.height)];
    issueMarketLabel.textColor = [UIColor whiteColor];
    issueMarketLabel.text = @"市場";
    issueMarketLabel.tag = 3;
    issueMarketLabel.font = [UIFont systemFontOfSize:14.0];
    [bottomBarView addSubview:issueMarketLabel];
//    if([COMMODITY_KUBUN_IDX isEqualToString:self.commodityKubun]){
//        issueMarketLabel.hidden = YES;//指数の場合非表示
//    }
//    else{
//        issueMarketLabel.hidden = NO;
//    }

    
    //指数選択
    indexNameButton = [[UIButton alloc]initWithFrame:CGRectMake(issueMarketLabel.frame.origin.x + issueMarketLabel.frame.size.width + 5, 2, ashiRect.size.width * 1.2, bottomBarView.frame.size.height - 4)];
    [indexNameButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_white.png"] forState:UIControlStateNormal];
    [indexNameButton setTitle: [ChartBox sharedInstance].indexNameArray[0] forState:UIControlStateNormal];
    [indexNameButton.titleLabel setFont:font];
    [indexNameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [indexNameButton addTarget:self action:@selector( indexButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:indexNameButton];
    
    indexTableView = [[UITableView alloc]initWithFrame: CGRectMake(indexNameButton.frame.origin.x, bottomBarView.frame.origin.y, indexNameButton.frame.size.width, indexNameButton.frame.size.height * [ChartBox sharedInstance].indexNameArray.count)];
    indexTableView.delegate = self;
    indexTableView.dataSource = self;
    [indexTableView.layer setBorderWidth: 1.0];
    [indexTableView.layer setCornerRadius:4.0f];
    [indexTableView.layer setMasksToBounds:YES];
    [indexTableView.layer setBorderColor:[[UIColor blackColor] CGColor]];
//    [self insertSubview:indexTableView belowSubview:bottomBarView];
    [self addSubview:indexTableView];
//    if([COMMODITY_KUBUN_IDX isEqualToString:self.commodityKubun]){
//        indexNameButton.hidden = NO;//指数の場合表示
//        indexTableView.hidden = NO;
//    }
//    else{
//        indexNameButton.hidden = YES;
//        indexTableView.hidden = YES;
//    }
    
    
    //限月選択ボタン
    tsukiButton = [[UIButton alloc]initWithFrame:CGRectMake(indexNameButton.frame.origin.x + indexNameButton.frame.size.width + 5, 2, ashiRect.size.width*0.7, bottomBarView.frame.size.height - 4)];
    [tsukiButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_white.png"] forState:UIControlStateNormal];
    [tsukiButton setTitle: [ChartBox sharedInstance].tsukiArray[0] forState:UIControlStateNormal];
    [tsukiButton.titleLabel setFont:font];
    [tsukiButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [tsukiButton addTarget:self action:@selector( tsukiButtonTapped: ) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:tsukiButton];
    
    tsukiTableView = [[UITableView alloc]initWithFrame: CGRectMake(tsukiButton.frame.origin.x, bottomBarView.frame.origin.y, tsukiButton.frame.size.width, tsukiButton.frame.size.height * [ChartBox sharedInstance].tsukiArray.count)];
    tsukiTableView.delegate = self;
    tsukiTableView.dataSource = self;
    [tsukiTableView.layer setBorderWidth: 1.0];
    [tsukiTableView.layer setCornerRadius:4.0f];
    [tsukiTableView.layer setMasksToBounds:YES];
    [tsukiTableView.layer setBorderColor:[[UIColor blackColor] CGColor]];
//    [self insertSubview:tsukiTableView belowSubview:bottomBarView];
    [self addSubview:tsukiTableView];
//    if([COMMODITY_KUBUN_FUTURES isEqualToString:self.commodityKubun] || [COMMODITY_CODE_MINI isEqualToString:self.commodityKubun]){
//        //先物、先物ミニの場合表示
//        tsukiButton.hidden = NO;
//        tsukiTableView.hidden = NO;
//    }
//    else{
//        tsukiButton.hidden = YES;
//        tsukiTableView.hidden = YES;
//    }
    
    
    
    //足種選択ボタン
    self.ashiButton = [[UIButton alloc]initWithFrame: CGRectMake(tsukiButton.frame.origin.x + tsukiButton.frame.size.width * 1.3, 2, ashiRect.size.width * 0.8, bottomBarView.frame.size.height - 4)];
    [self.ashiButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_white.png"] forState:UIControlStateNormal];
    [self.ashiButton setTitle: [ChartBox sharedInstance].ashiNameArray[3] forState:UIControlStateNormal];
    [self.ashiButton.titleLabel setFont:font];
    [self.ashiButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.ashiButton addTarget:self action:@selector(ashiButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview: self.ashiButton];
    
    //足種選択
    ashiTableView = [[UITableView alloc]initWithFrame: CGRectMake(self.ashiButton.frame.origin.x, bottomBarView.frame.origin.y, self.ashiButton.frame.size.width, self.ashiButton.frame.size.height * [ChartBox sharedInstance].ashiNameArray.count)];
    ashiTableView.delegate = self;
    ashiTableView.dataSource = self;
    [ashiTableView.layer setBorderWidth: 1.0];
    [ashiTableView.layer setCornerRadius:4.0f];
    [ashiTableView.layer setMasksToBounds:YES];
    [ashiTableView.layer setBorderColor:[[UIColor blackColor] CGColor]];
//    [self insertSubview:ashiTableView belowSubview:bottomBarView];
    [self addSubview:ashiTableView];
    
    
    
    
    //設定ボタン
    self.settingButton = [[UIButton alloc]initWithFrame:CGRectMake(self.ashiButton.frame.origin.x + self.ashiButton.frame.size.width * 1.3, 2, ashiRect.size.width, ashiRect.size.height - 4)];
    [self.settingButton setTitle:@"設定" forState:UIControlStateNormal];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_white.png"] forState:UIControlStateNormal];
    [self.settingButton setImage: [UIImage imageNamed:@"icon_setting_chart_button@2x.png"] forState:UIControlStateNormal];
    self.settingButton.imageEdgeInsets = UIEdgeInsetsMake(self.settingButton.frame.size.height*0.1, self.settingButton.frame.size.width*0.1, self.settingButton.frame.size.height*0.1, self.settingButton.frame.size.width*0.2);
    //    self.settingButton.layer.cornerRadius = 5;
    
    [self.settingButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.settingButton.titleLabel setFont:font];
    [self.settingButton addTarget:self action:@selector(settingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:self.settingButton];
    
    
    UIButton *changeOrientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeOrientationButton setBackgroundImage:[UIImage imageNamed:@"button_screenlandscape.png"] forState:UIControlStateNormal];
    changeOrientationButton.frame = CGRectMake(bottomBarView.frame.size.width - 50, 2, self.ashiButton.frame.size.height, self.ashiButton.frame.size.height);
    [changeOrientationButton addTarget:self action:@selector(changeOrientationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:changeOrientationButton];
    
    
    [self addSubview:bottomBarView];

}

- (void)initMenu{
    //テクニカルメニュー
    technicalMenuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, self.chartHeight * 0.9)];
    technicalMenuView.backgroundColor = [UIColor clearColor];
    [chartArea addSubview:technicalMenuView];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"menu_technical_305699.png"]];
    img.frame = technicalMenuView.frame;
    [technicalMenuView addSubview:img];
    
    UIButton *technicalMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    technicalMenuButton.backgroundColor = [UIColor clearColor];// colorWithRed:0/255.0 green:255/255.0 blue:0/255.0 alpha:0.3];
    technicalMenuButton.frame = CGRectMake(75, 0, 100-75, 63);
    technicalMenuButton.tag = 1;
    [technicalMenuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [technicalMenuView addSubview: technicalMenuButton];
    
    UIButton *hiddenButton1 = [UIButton buttonWithType:UIButtonTypeSystem];
    hiddenButton1.backgroundColor = [UIColor clearColor];
    hiddenButton1.frame = CGRectMake(75, 63, 100-75, 63);
    hiddenButton1.tag = 2;
    [hiddenButton1 addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [technicalMenuView addSubview: hiddenButton1];
    
    technicalMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 76, technicalMenuView.frame.size.height)];
    technicalMenuTableView.dataSource = self;
    technicalMenuTableView.delegate = self;
    //        technicalMenuTableView.backgroundColor = [UIColor colorWithHue:0.61 saturation:0.09 brightness:0.99 alpha:1.0];
    technicalMenuTableView.backgroundColor = [UIColor clearColor];
    [technicalMenuView addSubview:technicalMenuTableView];
    

    [technicalMenuView setCenter: CGPointMake(-26.0, technicalMenuView.center.y)];
    
    
    //オプションメニュー
    optionMenuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, self.chartHeight * 0.9)];
    optionMenuView.backgroundColor = [UIColor clearColor];
    [chartArea addSubview:optionMenuView];
    UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"menu_option_305699.png"]];
    iv.frame = optionMenuView.frame;
    [optionMenuView addSubview:iv];

    UIButton *hiddenButton2 = [UIButton buttonWithType:UIButtonTypeSystem];
    hiddenButton2.backgroundColor = [UIColor clearColor];
    hiddenButton2.frame = CGRectMake(75, 0, 100-75, 63);
    hiddenButton2.tag = 1;
    [hiddenButton2 addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [optionMenuView addSubview:hiddenButton2];

    UIButton *optionMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    optionMenuButton.backgroundColor = [UIColor clearColor]; // colorWithRed:0/255.0 green:0/255.0 blue:255/255.0 alpha:0.3];
    optionMenuButton.frame = CGRectMake(75, 63, 100-75, 63);
    optionMenuButton.tag = 2;
    [optionMenuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [optionMenuView addSubview: optionMenuButton];

    
    optionMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 76, optionMenuView.frame.size.height)];
    optionMenuTableView.dataSource = self;
    optionMenuTableView.delegate = self;
    optionMenuTableView.backgroundColor = [UIColor clearColor];
    [optionMenuView addSubview:optionMenuTableView];

    [optionMenuView setCenter: CGPointMake(-26.0, optionMenuView.center.y)];

}



//X軸カーソルビュー(四本値)
- (void)initXCursorView{
    //button color : 39, 94, 152 // button : 46 * 55
    CGFloat cursorBtnWidth = [ChartBox sharedInstance].xCursorBtnWidth; //30.0;
    CGFloat cursorBtnHeight = [ChartBox sharedInstance].xCursorBtnHeight * 0.8;
    
    xCursorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.chartHeight - self.datetimeHeight+3, cursorBtnWidth, cursorBtnHeight)];
    [xCursorButton setBackgroundImage:[UIImage imageNamed:@"parts_chart_cursor_x@2x.png"] forState:UIControlStateNormal];
    xCursorButton.alpha = 0.85;
    [chartArea addSubview:xCursorButton];
    
    panGestureRecognizerFourPrices = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [xCursorButton addGestureRecognizer:panGestureRecognizerFourPrices];

    xCursorView = [[UIView alloc]initWithFrame:CGRectMake(self.chartWidth-cursorBtnWidth/2, 0, cursorBtnWidth, self.chartHeight - self.datetimeHeight + 3 )];
    xCursorView.backgroundColor = [UIColor clearColor];
    xCursorView.userInteractionEnabled = NO;
    [chartArea addSubview: xCursorView];

    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake((cursorBtnWidth-1.6)/2, 0, 1.6, xCursorView.frame.size.height + 2 )];
    lineLabel.backgroundColor = [UIColor colorWithRed:39/255.0 green:94/255.0 blue:152/255.0 alpha:0.85];
    [xCursorView addSubview: lineLabel];

    [xCursorButton setCenter:CGPointMake(xCursorView.center.x, xCursorButton.center.y)];

    
}

//Y軸カーソルビュー
- (void)initYcursorView{
    NSInteger buttonWidth = self.frame.size.width/15;  //62.0; -> 55
    NSInteger viewHeight =  self.frame.size.height/13;  //32.0; -> 31
    
    yCursorButton = [[UIButton alloc]initWithFrame:CGRectMake(self.chartWidth*1.02-2, chartCandlestickView.frame.size.height/2, buttonWidth, viewHeight)];
    [yCursorButton setBackgroundImage:[UIImage imageNamed:@"parts_chart_cursor_y@2x.png"] forState:UIControlStateNormal];
    yCursorButton.alpha = 0.9;
    [chartArea addSubview:yCursorButton];
    
    panGestureRecognizerPriceIndicator = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [yCursorButton addGestureRecognizer:panGestureRecognizerPriceIndicator];

    
    ycursorView = [[UIView alloc]initWithFrame:CGRectMake(0,  chartCandlestickView.frame.size.height/2, self.chartWidth*1.02, viewHeight)];
    ycursorView.backgroundColor = [UIColor clearColor];
    ycursorView.userInteractionEnabled = NO;
    [chartArea addSubview:ycursorView];
    
    //172 110 206
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, ycursorView.frame.size.height/2-1.4/2,ycursorView.frame.size.width, 1.4)];
    lineLabel.backgroundColor = [UIColor colorWithRed:172/255.0 green:110/255.0 blue:206/255.0 alpha:1.0];
    [ycursorView addSubview: lineLabel];
//    lineLabel.center = CGPointMake(lineLabel.center.x, ycursorView.center.y);

    UIButton *priceBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width*0.11, viewHeight*0.2, self.frame.size.width*0.08, viewHeight*0.6)];
    [priceBtn setBackgroundImage:[UIImage imageNamed:@"parts_chart_cursorvalue_ｙ@2x.png"] forState:UIControlStateNormal];
    priceBtn.enabled = NO;
    [priceBtn setTitle: @"0.0" forState: UIControlStateNormal];
    priceBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    priceBtn.tag = 1;
//    priceBtn.center = CGPointMake(priceBtn.center.x, ycursorView.center.y);
    [ycursorView addSubview:priceBtn];
    
}


#pragma mark - Some Other Methods

//チャートのサイズ、表示・非表示を設定
- (void)updateChartsFrame{
    CGFloat mainchartHeight = [ChartBox sharedInstance].needShowSubChart ? (self.chartHeight - self.subchartHeight - self.datetimeHeight) : (self.chartHeight - self.datetimeHeight);
    chartMainView.frame = CGRectMake(0, 0, self.frame.size.width, mainchartHeight);

    CGRect scrollContentFrame = CGRectMake(0, 0, self.scrollContentWidth, mainchartHeight);
    
    chartCandlestickView.frame = scrollContentFrame;
    chartMovAvgView.frame = scrollContentFrame;
    bollingerView.frame = scrollContentFrame;
    ichimokuView.frame = scrollContentFrame;

    
    chartSubView.hidden = ![ChartBox sharedInstance].needShowSubChart;
    rsiView.hidden = ![ChartBox sharedInstance].needShowSub_rsi;
    macdView.hidden = ![ChartBox sharedInstance].needShowSub_macd;
    stochasView.hidden = ![ChartBox sharedInstance].needShowSub_stochas;
    volumeView.hidden = ![ChartBox sharedInstance].needShowSub_volume;

    subChartNamesView.hidden = ![ChartBox sharedInstance].needShowSubChart;

}

//チャートの表示・非表示を再設定
- (void)updateChartsVisibility{
    chartSubView.hidden = ![ChartBox sharedInstance].needShowSubChart;
    
    chartMovAvgView.hidden = ![ChartBox sharedInstance].needShowMovAvg;
    bollingerView.hidden = ![ChartBox sharedInstance].needShowBollinger;
    ichimokuView.hidden = ![ChartBox sharedInstance].needShowIchimoku;

    rsiView.hidden = ![ChartBox sharedInstance].needShowSub_rsi;
    macdView.hidden = ![ChartBox sharedInstance].needShowSub_macd;
    stochasView.hidden = ![ChartBox sharedInstance].needShowSub_stochas;
    volumeView.hidden = ![ChartBox sharedInstance].needShowSub_volume;
    
    subChartNamesView.hidden = ![ChartBox sharedInstance].needShowSubChart;

}

//メインチャートの表示・非表示を設定、ラベルを設定
- (void)updateCharts_main{
    CGFloat mainchartHeight = [ChartBox sharedInstance].needShowSubChart ? (self.chartHeight - self.subchartHeight - self.datetimeHeight) : (self.chartHeight - self.datetimeHeight);
    CGRect scrollContentFrame = CGRectMake(0, 0, self.scrollContentWidth, mainchartHeight);
    CGRect hiddenFrame = CGRectMake(0, 0 - mainchartHeight, self.scrollContentWidth, mainchartHeight);

    if([ChartBox sharedInstance].needShowMovAvg){
        chartMovAvgView.hidden = NO;
        chartMovAvgView.frame = hiddenFrame;
        chartNamesView.hidden = YES;
        
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             chartMovAvgView.frame = scrollContentFrame;

                         } completion:^(BOOL finished) {
                             chartNamesView.hidden = NO;
                         }];
        
    }
    else{
        chartMovAvgView.hidden = YES;
    }

    if([ChartBox sharedInstance].needShowBollinger){
        bollingerView.hidden = NO;
        bollingerView.frame = hiddenFrame;
        chartNamesView.hidden = YES;

        
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             bollingerView.frame = scrollContentFrame;
                             
                         } completion:^(BOOL finished) {
                             chartNamesView.hidden = NO;
                         }];
        
    }
    else{
        bollingerView.hidden = YES;
    }


    if([ChartBox sharedInstance].needShowIchimoku){
        ichimokuView.hidden = NO;
        ichimokuView.frame = hiddenFrame;
        chartNamesView.hidden = YES;

        
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             ichimokuView.frame = scrollContentFrame;
                             
                         } completion:^(BOOL finished) {
                             chartNamesView.hidden = NO;

                         }];
        
    }
    else{
        ichimokuView.hidden = YES;
    }

    

    [self updateChartLabels_main];

}


//サブチャートのラベルを設定
- (void)updateChartLabels_sub{
    if([ChartBox sharedInstance].needShowSub_rsi){
        [subChartNamesView update:1];
    }
    else if([ChartBox sharedInstance].needShowSub_macd){
        [subChartNamesView update:2];
    }
    else if([ChartBox sharedInstance].needShowSub_stochas){
        [subChartNamesView update:3];
    }
    else if([ChartBox sharedInstance].needShowSub_volume){
        [subChartNamesView update:4];
    }
    else{
        [subChartNamesView update:0];
    }
    

}

- (void)updateChartLabels_main{
    if([ChartBox sharedInstance].needShowMovAvg){
        [chartNamesView update:1];
    }
    else if([ChartBox sharedInstance].needShowBollinger){
        [chartNamesView update:2];
    }
    else if([ChartBox sharedInstance].needShowIchimoku){
        [chartNamesView update:3];
    }
    else{
        [chartNamesView update:0];
    }

}

- (void)updateBottomBarNm: (NSString *)nm Cd: (NSString *)cd ex: (NSString *)exNm{
    ((UILabel *)[bottomBarView viewWithTag:1]).text = nm;
    ((UILabel *)[bottomBarView viewWithTag:2]).text = cd;
    ((UILabel *)[bottomBarView viewWithTag:3]).text = exNm;
    
    
}
//再描画
- (void)redrawChart:(BOOL)needNewData{
    if(needNewData){
        [[ChartBox sharedInstance] getDrawChartData];
    }
    
    if([ChartBox sharedInstance].yAxisFixed){
        [[ChartBox sharedInstance] getLimitValueInAll];
    }
    else{
        [[ChartBox sharedInstance] getLimitValueInRange: self.scrollView.contentOffset.x];
    }

    
    [chartMainView setNeedsDisplay];
    
    [chartCandlestickView setNeedsDisplay];

    if([ChartBox sharedInstance].needShowMovAvg)
        [chartMovAvgView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowBollinger)
        [bollingerView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowIchimoku)
        [ichimokuView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowSubChart)
        [chartSubView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowSub_rsi)
        [rsiView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowSub_macd)
        [macdView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowSub_stochas)
        [stochasView setNeedsDisplay];
    
    if([ChartBox sharedInstance].needShowSub_volume)
        [volumeView setNeedsDisplay];


    [chartDatetimeView setNeedsDisplay];
    
    [self updateChartLabels_main];
    [self updateChartLabels_sub];

    activityIndicatorView.hidden = YES;
    [activityIndicatorView stopAnimating];

    [[ChartBox sharedInstance] saveChartSettingOptions];

}



//四本値の表示設定
- (void)updateFourPrices {
    
//    NSInteger xPos = (NSInteger)fourPricesViewNowLocation.x / ([ChartBox sharedInstance].candleStickBodyWidth + [ChartBox sharedInstance].candleStickInterval);
//    if([ChartBox sharedInstance].ohlcMutableArray.count == 0 || [ChartBox sharedInstance].ohlcMutableArray.count - 1 < [ChartBox sharedInstance].currentIdxFrom + xPos){
//        return;
//    }
//    
//    OhlcBean *bean = [[ChartBox sharedInstance].ohlcMutableArray objectAtIndex: [ChartBox sharedInstance].currentIdxFrom + xPos];
//    [fourPricesView updateFourPriceLabels:bean];
    
    NSInteger indexInArray = (fourPricesViewNowLocation.x + self.scrollView.contentOffset.x) / [[ChartBox sharedInstance] getStickUnitWidth];
    NSInteger lackCount = CANDLESTICK_COUNT_ALL - [ChartBox sharedInstance].ohlcMutableArray.count;

    if( indexInArray - lackCount >= 0 && indexInArray - lackCount <= [ChartBox sharedInstance].ohlcMutableArray.count - 1 ){
        
        OhlcBean *bean = [ChartBox sharedInstance].ohlcMutableArray[ indexInArray - lackCount ];
        [fourPricesView updateFourPriceLabels:bean];
    }
    else{
        [fourPricesView clearFourPrices];
    }
    
}


- (void)changeFloatPriceIndicator{
    CGFloat maxPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].maxPriceInAll : [ChartBox sharedInstance].maxPriceInRange;
    CGFloat minPrice = [ChartBox sharedInstance].yAxisFixed ? [ChartBox sharedInstance].minPriceInAll : [ChartBox sharedInstance].minPriceInRange;
    
    CGFloat height = chartMainView.frame.size.height;
    NSString *price = [NSString stringWithFormat: @"%.2f", NOWVALUE_BY_YPOSITION1(yCursorButton.center.y, maxPrice, minPrice, height)];

    [((UIButton *)[ycursorView viewWithTag:1]) setTitle:price forState:UIControlStateNormal];
}

- (void)closeMenu: (UIView *)menuView{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         [menuView setCenter:CGPointMake(-26.0, menuView.center.y)];
                         
                         ((UIButton *)[technicalMenuView viewWithTag:1]).enabled = YES;
                         ((UIButton *)[technicalMenuView viewWithTag:2]).enabled = YES;
                         ((UIButton *)[optionMenuView viewWithTag:1]).enabled = YES;
                         ((UIButton *)[optionMenuView viewWithTag:2]).enabled = YES;
                         
                     } completion:^(BOOL finished) {
                         
                     }];

}


- (BOOL)needCloseTheView{
    if(ashiTableView.frame.origin.y != bottomBarView.frame.origin.y){
        [UIView animateWithDuration:0.3 animations:^{
            [ashiTableView setFrame:CGRectMake(ashiTableView.frame.origin.x, bottomBarView.frame.origin.y, ashiTableView.frame.size.width, ashiTableView.frame.size.height)];
        }];
        return YES;
    }
    if(indexTableView.frame.origin.y != bottomBarView.frame.origin.y){
        [UIView animateWithDuration:0.3 animations:^{
            [indexTableView setFrame:CGRectMake(indexTableView.frame.origin.x, bottomBarView.frame.origin.y, indexTableView.frame.size.width, indexTableView.frame.size.height)];
        }];
        return YES;
    }
    if(tsukiTableView.frame.origin.y != bottomBarView.frame.origin.y){
        [UIView animateWithDuration:0.3 animations:^{
            [tsukiTableView setFrame:CGRectMake(tsukiTableView.frame.origin.x, bottomBarView.frame.origin.y, tsukiTableView.frame.size.width, tsukiTableView.frame.size.height)];
        }];
        return YES;
    }
    
    return NO;
}




//#pragma mark - dropdownList DataSource
//
//-(NSInteger)numberOfSections
//{
//    return [chooseArray count];
//}
//-(NSInteger)numberOfRowsInSection:(NSInteger)section
//{
//    NSArray *arry = chooseArray[section];
//    return [arry count];
//}
//-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
//{
//    return chooseArray[section][index];
//}
//-(NSInteger)defaultShowSection:(NSInteger)section
//{
//    return 0;
//}


//- (void) chooseAtSection:(NSInteger)section index:(NSInteger)index{
//    switch (index) {
//        case 0://日足
//            self.managerViewController.ashiSelected = @"d";
//            break;
//            
//        case 1://週足
//            self.managerViewController.ashiSelected = @"w";
//            break;
//            
//        case 2://月足
//            self.managerViewController.ashiSelected = @"m";
//            break;
//            
//        default:
//            break;
//    }
//    
//    [self.managerViewController fetchDataFromYahoo];
//
//    
//}

@end
