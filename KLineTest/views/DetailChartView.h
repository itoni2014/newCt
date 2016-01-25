//
//  DetailChartView.h
//  sec
//
//  Created by ias_sec on 2015/11/24.
//
//

#import <UIKit/UIKit.h>
//#import "ContentsPageBaseView.h"



//@class ContentsManagerViewController;
@class ContentsPageManagerViewController;

@interface DetailChartView :  UIView


@property (strong, nonatomic) UIScrollView *scrollView;

//足種選択ボタン
@property (strong, nonatomic) UIButton *ashiButton;


@property CGFloat chartWidth;
@property CGFloat scrollContentWidth;
@property CGFloat chartHeight;
@property CGFloat subchartHeight;
@property CGFloat datetimeHeight;
@property CGFloat subChartStartY;
@property CGFloat subChartValidHeight;

@property (strong, nonatomic) UIButton *settingButton;


//再描画
- (void)redrawChart: (BOOL)needNewData;

//銘柄名等更新
- (void)updateBottomBarNm: (NSString *)nm Cd: (NSString *)cd ex: (NSString *)exNm;

//チャートの表示・非表示を再設定
- (void)updateChartsVisibility;

@end
