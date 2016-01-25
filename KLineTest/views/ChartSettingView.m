

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
        
    }
    
    return self;
}


@end
