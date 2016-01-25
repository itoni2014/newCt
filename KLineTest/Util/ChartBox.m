#import "ChartBox.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIColor+hex.h"
#import "OhlcBean.h"
//#import "TechnicalSetting.h"


#define KEY_CHART_SETTING @"ChartSettingOptions"

@interface ChartBox()
{
//    TechnicalSetting *technicalSetting;
    NSMutableDictionary *chartSettingMutableDictionary;

}

- (id)initialize;

@end

@implementation ChartBox

/** 移動平均線・短期の描画色 */
float const MOVAVG_SHORT_COLOR[] = { 224, 112, 0 };
/** 移動平均線・中期の描画色 */
float const MOVAVG_MEDIUM_COLOR[] = { 192, 0, 192 };
/** 移動平均線・長期の描画色 */
float const MOVAVG_LONG_COLOR[] = { 0, 100, 0 };
/** ボリンジャー・移動平均の描画色 */
float const BOLLINGER_MOVE_AVG_COLOR[] = {0, 0, 0};
/** ボリンジャー・TOP1の描画色 */
float const BOLLINGER_TOP1_COLOR[] = {0, 0, 255};
/** ボリンジャー・LOW1の描画色 */
float const BOLLINGER_LOW1_COLOR[] = {255, 0, 255};
/** ボリンジャー・TOP2の描画色 */
float const BOLLINGER_TOP2_COLOR[] = {0, 255, 0};
/** ボリンジャー・LOW2の描画色 */
float const BOLLINGER_LOW2_COLOR[] = {255, 0, 0};
/** 一目均衡表・転換線の描画色 */
float const ITIMOKU_CONVERSION_COLOR[] = {192, 0, 192};
/** 一目均衡表・基準線の描画色 */
float const ITIMOKU_BASE_COLOR[] = {224, 112, 0};
/** 一目均衡表・遅行線の描画色 */
float const ITIMOKU_LAGGING_COLOR[] = {190, 190, 190};
/** 一目均衡表・先行スパン1の描画色 */
float const ITIMOKU_LEADING_SPAN1_COLOR[] = {0, 128, 128};
/** 一目均衡表・先行スパン2の描画色 */
float const ITIMOKU_LEADING_SPAN2_COLOR[] = {242, 0, 0};
/** 一目均衡表・雲上の描画色 */
float const ITIMOKU_CLOUD1_COLOR[] = {0, 192, 102};
/** 一目均衡表・雲下の描画色 */
float const ITIMOKU_CLOUD2_COLOR[] = { 255, 127, 0 };
/** RSIの描画色 */
float const RSI_COLOR[] = {224, 112, 0};
/** RSI基準線の描画色 */
float const RSI_BASE_COLOR[] = {190, 190, 190};
/** RSI買われすぎの描画色 */
float const RSI_OVER_BUY_COLOR[] = {255, 0, 0};
/** RSI売られすぎの描画色 */
float const RSI_OVER_SELL_COLOR[] = {190, 190, 190};
/** MACDの描画色 */
float const MACD_COLOR[] = { 192, 0, 192 };
/** シグナルの描画色 */
float const MACD_SIGNAL_COLOR[] = { 224, 112, 0 };
/** OSCI(明)の描画色 */
float const MACD_OSCI_LIGHT_COLOR[] = { 255, 0, 68 };
/** OSCI(暗)の描画色 */
float const MACD_OSCI_DARK_COLOR[] = { 121, 121, 242 };
/** Slow%Dの描画色 */
float const STOCHAS_SLOW_PER_D_COLOR[] = { 0, 100, 0 };
/** Slow%Kの描画色 */
float const STOCHAS_SLOW_PER_K_COLOR[] = { 224, 112, 0 };
/** 買われすぎの描画色 */
float const STOCHAS_OVER_BUY_COLOR[] = { 255, 0, 0 };
/** 売られすぎの描画色 */
float const STOCHAS_OVER_SELL_COLOR[] = { 0, 0, 0 };

+ (ChartBox *)sharedInstance{
    static ChartBox *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[self alloc] initialize];
    });
    
    return sharedSingleton;
}

- (id)initialize{
    if(self == [super init] ){
        //initial something here
        self.technicalNameArray = @[ @"移動平均", @"ボリンジャー", @"一目均衡表", @"RSI", @"MACD", @"Sストキャス" ];
        self.ashiNameArray = @[ @"1分足", @"10分足", @"時間足", @"日足", @"週足", @"月足" ];
        self.mainTechnicalNameArray = @[ @"移動平均", @"ボリンジャー", @"一目均衡表", @"表示なし" ];
        self.subTechnicalNameArray = @[ @"RSI", @"MACD", @"Sストキャス", @"出来高", @"表示なし" ];
        self.subviewNameArray = @[ @"チャート", @"注文", @"気配", @"発注板", @"銘柄詳細" ];
        self.ma_labelTextArray = @[ @"短期", @"中期", @"長期" ];
        self.bollinger_labelTextArray = @[ @"期間", @"標準偏差", @"標準偏差２" ];
        self.itimoku_labelTextArray = @[ @"転換線", @"基準線", @"先行スパン２" ];
        self.rsi_labelTextArray = @[ @"期間", @"売られ過ぎ", @"買われ過ぎ" ];
        self.macd_labelTextArray = @[ @"短期EMA", @"長期EMA", @"シグナル" ];
        self.stochas_labelTextArray = @[ @"高安周期", @"d期間", @"底値ライン(%)", @"高値ライン(%)" ];
        self.indexNameArray = @[@"日経平均", @"TOPIX", @"JPX日経400", @"東証２部", @"日経JQ平均"];
        self.tsukiArray = @[@"15/09",@"15/12",@"15/03",@"16/09",@"17/03",@"17/06"];
        

        self.technicalDefaultValueDic = @{
                                          @"ma_1min_s" : @"5",
                                          @"ma_1min_m" : @"25",
                                          @"ma_1min_l" : @"75",
                                          @"ma_10min_s" : @"5",
                                          @"ma_10min_m" : @"25",
                                          @"ma_10min_l" : @"75",
                                          @"ma_hour_s" : @"5",
                                          @"ma_hour_m" : @"25",
                                          @"ma_hour_l" : @"75",
                                          @"ma_day_s" : @"5",
                                          @"ma_day_m" : @"25",
                                          @"ma_day_l" : @"75",
                                          @"ma_week_s" : @"13",
                                          @"ma_week_m" : @"26",
                                          @"ma_week_l" : @"52",
                                          @"ma_month_s" : @"6",
                                          @"ma_month_m" : @"12",
                                          @"ma_month_l" : @"24",
                                          @"bollinger_1min_ma" : @"25",
                                          @"bollinger_1min_1" :  @"2",
                                          @"bollinger_1min_2" :  @"3",
                                          @"bollinger_10min_ma" : @"25",
                                          @"bollinger_10min_1" :  @"2",
                                          @"bollinger_10min_2" :  @"3",
                                          @"bollinger_hour_ma" : @"25",
                                          @"bollinger_hour_1" :  @"2",
                                          @"bollinger_hour_2" :  @"3",
                                          @"bollinger_day_ma" : @"25",
                                          @"bollinger_day_1" :  @"2",
                                          @"bollinger_day_2" :  @"3",
                                          @"bollinger_week_ma" : @"25",
                                          @"bollinger_week_1" :  @"2",
                                          @"bollinger_week_2" :  @"3",
                                          @"bollinger_month_ma" : @"25",
                                          @"bollinger_month_1" :  @"2",
                                          @"bollinger_month_2" :  @"3",
                                          @"itimoku_1min_convert" : @"5",
                                          @"itimoku_1min_base" : @"25",
                                          @"itimoku_1min_span" : @"75",
                                          @"itimoku_10min_convert" : @"5",
                                          @"itimoku_10min_base" : @"25",
                                          @"itimoku_10min_span" : @"75",
                                          @"itimoku_hour_convert" : @"5",
                                          @"itimoku_hour_base" : @"25",
                                          @"itimoku_hour_span" : @"75",
                                          @"itimoku_day_convert" : @"5",
                                          @"itimoku_day_base" : @"25",
                                          @"itimoku_day_span" : @"75",
                                          @"itimoku_week_convert" : @"13",
                                          @"itimoku_week_base" : @"26",
                                          @"itimoku_week_span" : @"52",
                                          @"itimoku_month_convert" : @"6",
                                          @"itimoku_month_base" : @"12",
                                          @"itimoku_month_span" : @"24",
                                          @"rsi_1min_1" : @"14",
                                          @"rsi_1min_2" : @"20",
                                          @"rsi_1min_3" : @"80",
                                          @"rsi_10min_1" : @"14",
                                          @"rsi_10min_2" : @"20",
                                          @"rsi_10min_3" : @"80",
                                          @"rsi_hour_1" : @"14",
                                          @"rsi_hour_2" : @"20",
                                          @"rsi_hour_3" : @"80",
                                          @"rsi_day_1" : @"14",
                                          @"rsi_day_2" : @"20",
                                          @"rsi_day_3" : @"80",
                                          @"rsi_week_1" : @"14",
                                          @"rsi_week_2" : @"20",
                                          @"rsi_week_3" : @"80",
                                          @"rsi_month_1" : @"14",
                                          @"rsi_month_2" : @"20",
                                          @"rsi_month_3" : @"80",
                                          @"macd_1min_1" : @"12",
                                          @"macd_1min_2" : @"26",
                                          @"macd_1min_3" : @"9",
                                          @"macd_10min_1" : @"12",
                                          @"macd_10min_2" : @"26",
                                          @"macd_10min_3" : @"9",
                                          @"macd_hour_1" : @"12",
                                          @"macd_hour_2" : @"26",
                                          @"macd_hour_3" : @"9",
                                          @"macd_day_1" : @"12",
                                          @"macd_day_2" : @"26",
                                          @"macd_day_3" : @"9",
                                          @"macd_week_1" : @"12",
                                          @"macd_week_2" : @"26",
                                          @"macd_week_3" : @"9",
                                          @"macd_month_1" : @"12",
                                          @"macd_month_2" : @"26",
                                          @"macd_month_3" : @"9",
                                          @"stochas_1min_1" : @"14",
                                          @"stochas_1min_2" : @"3",
                                          @"stochas_1min_3" : @"30",
                                          @"stochas_1min_4" : @"70",
                                          @"stochas_10min_1" : @"14",
                                          @"stochas_10min_2" : @"3",
                                          @"stochas_10min_3" : @"30",
                                          @"stochas_10min_4" : @"70",
                                          @"stochas_hour_1" : @"14",
                                          @"stochas_hour_2" : @"3",
                                          @"stochas_hour_3" : @"30",
                                          @"stochas_hour_4" : @"70",
                                          @"stochas_day_1" : @"14",
                                          @"stochas_day_2" : @"3",
                                          @"stochas_day_3" : @"30",
                                          @"stochas_day_4" : @"70",
                                          @"stochas_week_1" : @"14",
                                          @"stochas_week_2" : @"3",
                                          @"stochas_week_3" : @"30",
                                          @"stochas_week_4" : @"70",
                                          @"stochas_month_1" : @"14",
                                          @"stochas_month_2" : @"3",
                                          @"stochas_month_3" : @"30",
                                          @"stochas_month_4" : @"70",
                            };
        
//        technicalSetting = [TechnicalSetting sharedManager];
        self.technicalValueDic = @{
//                                          @"ma_1min_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"ma_1min_m" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"ma_1min_l" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"ma_10min_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"ma_10min_m" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"ma_10min_l" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"ma_hour_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"ma_hour_m" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"ma_hour_l" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"ma_day_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"ma_day_m" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"ma_day_l" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"ma_week_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"ma_week_m" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"ma_week_l" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"ma_month_s" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_SHORT_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"ma_month_m" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_MEDIUM_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"ma_month_l" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MOVING_AVE_LONG_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"bollinger_1min_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"bollinger_1min_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"bollinger_1min_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"bollinger_10min_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"bollinger_10min_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"bollinger_10min_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"bollinger_hour_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"bollinger_hour_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"bollinger_hour_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"bollinger_day_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"bollinger_day_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_DAILY]).settingValue,
//                                          @"bollinger_day_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_DAILY]).settingValue,
//                                          @"bollinger_week_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"bollinger_week_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"bollinger_week_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"bollinger_month_ma" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"bollinger_month_1" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"bollinger_month_2" :  ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:BOLLINGER_STANDARD_DEVIATION2 and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"itimoku_1min_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"itimoku_1min_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"itimoku_1min_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_EVERY_1MIN]).settingValue,
//                                          @"itimoku_10min_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"itimoku_10min_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"itimoku_10min_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_EVERY_10MIN]).settingValue,
//                                          @"itimoku_hour_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"itimoku_hour_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"itimoku_hour_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_HOURLY]).settingValue,
//                                          @"itimoku_day_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"itimoku_day_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"itimoku_day_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_DAILY]).settingValue,
//                                          @"itimoku_week_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"itimoku_week_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"itimoku_week_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_WEEKLY]).settingValue,
//                                          @"itimoku_month_convert" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_SHORT_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"itimoku_month_base" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_MEDIUM_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"itimoku_month_span" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:ICHIMOKU_LONG_TERM and:BAR_TYPE_MONTHLY]).settingValue,
//                                          @"rsi_1min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"rsi_1min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"rsi_1min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"rsi_10min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"rsi_10min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"rsi_10min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"rsi_hour_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"rsi_hour_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"rsi_hour_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"rsi_day_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"rsi_day_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"rsi_day_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"rsi_week_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"rsi_week_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"rsi_week_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"rsi_month_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_TERM and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"rsi_month_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERSOLD and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"rsi_month_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:RSI_OVERBOUGHT and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"macd_1min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"macd_1min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"macd_1min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"macd_10min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"macd_10min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"macd_10min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"macd_hour_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"macd_hour_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"macd_hour_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"macd_day_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"macd_day_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"macd_day_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"macd_week_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"macd_week_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"macd_week_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"macd_month_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SHORT_TERM and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"macd_month_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_LONG_TERM and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"macd_month_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:MACD_SIGNAL and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"stochas_1min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"stochas_1min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"stochas_1min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"stochas_1min_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_EVERY_1MIN ]).settingValue,
//                                          @"stochas_10min_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"stochas_10min_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"stochas_10min_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"stochas_10min_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_EVERY_10MIN ]).settingValue,
//                                          @"stochas_hour_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"stochas_hour_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"stochas_hour_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"stochas_hour_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_HOURLY ]).settingValue,
//                                          @"stochas_day_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"stochas_day_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"stochas_day_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"stochas_day_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_DAILY ]).settingValue,
//                                          @"stochas_week_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"stochas_week_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"stochas_week_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"stochas_week_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_WEEKLY ]).settingValue,
//                                          @"stochas_month_1" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_PERIOD and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"stochas_month_2" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_D_TERM and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"stochas_month_3" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERSOLD and:BAR_TYPE_MONTHLY ]).settingValue,
//                                          @"stochas_month_4" : ((ChartSettingModel *)[technicalSetting technicalSettingGetModel:SLOW_STCSTCS_OVERBOUGHT and:BAR_TYPE_MONTHLY ]).settingValue,
                                          };
        

//        if( [[NSUserDefaults standardUserDefaults] objectForKey:@"TechnicalIndicatorValue"] == nil ){
//            
//            [[NSUserDefaults standardUserDefaults] setObject:self.technicalDefaultValueDic forKey:@"TechnicalIndicatorValue"];
//            self.technicalValueDic = self.technicalDefaultValueDic;
//        }
//        else{
//            self.technicalValueDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"TechnicalIndicatorValue"];
//        }

        self.ymdMutableArray = [[NSMutableArray alloc]initWithCapacity:10];
        self.ohlcMutableArray = [[NSMutableArray alloc]initWithCapacity:CANDLESTICK_COUNT_ALL];

        

        NSDictionary *chartSettingDefaultDictionary = @{
                                          @"ashi" : @"4", //足種
                                          @"subchart" : @"1", //サブチャートを表示するか
                                          @"yaxis" : @"1", //Y軸固定するか 1 固定　０　可変
                                          @"show_movavg" : @"1", //移動平均表示
                                          @"show_bollinger" : @"0", //ボリンじゃ非表示
                                          @"show_ichimoku" : @"0", //一目均衡非表示
                                          @"show_rsi" : @"0", //RSI表示
                                          @"show_macd" : @"0", //MACD非表示
                                          @"show_stochas" : @"0", //Sストキャスを表示しない
                                          @"show_volume" : @"1", //出来高を表示しない
                                          @"show_fourprices" : @"0", //4本値を表示しない
                                          };
        

        if( [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CHART_SETTING] == nil ){
            [[NSUserDefaults standardUserDefaults] setObject:chartSettingDefaultDictionary forKey:KEY_CHART_SETTING];
            chartSettingMutableDictionary = [chartSettingDefaultDictionary mutableCopy];
        }
        else{
            chartSettingMutableDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey: KEY_CHART_SETTING] mutableCopy];
        }
        
//        if([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_MINUTES1] ){
//            self.ashiTypeSelected = BAR_TYPE_MINUTES1;
//        }
//        else if ([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_MINUTES10] ){
//            self.ashiTypeSelected = BAR_TYPE_MINUTES10;
//        }
//        else if ([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_TIME] ){
//            self.ashiTypeSelected = BAR_TYPE_TIME;
//        }
//        else if ([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_DAY] ){
//            self.ashiTypeSelected = BAR_TYPE_DAY;
//        }
//        else if ([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_WEEK] ){
//            self.ashiTypeSelected = BAR_TYPE_WEEK;
//        }
//        else if ([chartSettingMutableDictionary[@"ashi"] isEqualToString:BAR_TYPE_MONTH] ){
//            self.ashiTypeSelected = BAR_TYPE_MONTH;
//        }
        self.needShowSubChart = [chartSettingMutableDictionary[@"subchart"] isEqualToString:@"1"] ? YES : NO; //サブチャート
        self.yAxisFixed = [chartSettingMutableDictionary[@"yaxis"] isEqualToString:@"1"] ? YES : NO;  //Y軸固定するか
        self.needShowMovAvg = [chartSettingMutableDictionary[@"show_movavg"] isEqualToString:@"1"] ? YES : NO;    //移動平均を表示するか
        self.needShowBollinger = [chartSettingMutableDictionary[@"show_bollinger"] isEqualToString:@"1"] ? YES : NO;   //ボリンジャーを表示するか
        self.needShowIchimoku = [chartSettingMutableDictionary[@"show_ichimoku"] isEqualToString:@"1"] ? YES : NO;   //一目均衡表を表示するか
        self.needShowSub_rsi = [chartSettingMutableDictionary[@"show_rsi"] isEqualToString:@"1"] ? YES : NO;  //RSIを表示するか
        self.needShowSub_macd = [chartSettingMutableDictionary[@"show_macd"] isEqualToString:@"1"] ? YES : NO; //MACDを表示するか
        self.needShowSub_stochas = [chartSettingMutableDictionary[@"show_stochas"] isEqualToString:@"1"] ? YES : NO; //Sストキャスを表示するか
        self.needShowSub_volume = [chartSettingMutableDictionary[@"show_volume"] isEqualToString:@"1"] ? YES : NO; //出来高を表示するか
        self.needShowFourPrices = [chartSettingMutableDictionary[@"show_fourprices"] isEqualToString:@"1"] ? YES : NO; //4本値表示するか
        
        
        

    }
    
    return self;
}

//+(NSDate*)dateFromString:(NSString*)str{
//    
//    NSDateFormatter *datef = [[NSDateFormatter alloc] init];
//    
//    [datef setDateFormat:@"yyyy-MM-dd"];
//    
//    NSDate *tempDate = [datef dateFromString:str];
//    return tempDate;
//}

//+(NSDateComponents*)dateComponentsWithDate:(NSDate*)date{
//    if (date==nil) {
//        date = [NSDate date];
//    }
//    
//    NSCalendar *calenar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
//    
//    NSDateComponents *dateComp = [calenar components:unitFlags fromDate:date];
//    return dateComp;
//}

//+(bool)isEqualWithFloat:(float)f1 float2:(float)f2 absDelta:(int)absDelta
//{
//    int i1, i2;
//    i1 = (f1>0) ? ((int)f1) : ((int)f1 - 0x80000000);
//    i2 = (f2>0) ? ((int)f2)  : ((int)f2 - 0x80000000);
//    return ((abs(i1-i2))<absDelta) ? true : false;
//}

+(NSObject *) getUserDefaults:(NSString *) name{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:name];
}

+(void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaults forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)md5HexDigest:(NSString*)password
{
    const char *original_str = [password UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *mdfiveString = [hash lowercaseString];

    return mdfiveString;
}

//+ (NSString *)addUnitToPrice:(CGFloat)price{
//    CGFloat newPrice = 0;
//    
//    //393389184
//    NSString *danwei;// = @"万";
//    if ((int)price > 100000000) {
//        //        newPrice = price / 100000000 ;
//        return [[NSString alloc]initWithFormat: @"%.0f億", price / 100000000];
//    }
//    else if ((int)price > 10000000) {
//        newPrice = price / 10000000 ;
//        danwei = @"千万";
//    }
//    else if ((int)price > 10000) {
//        newPrice = price / 10000 ;
//    }
//    
//    // NSString *newstr = [[NSString alloc] initWithFormat:@"%.0f%@", newPrice, danwei];
//    return danwei;
//}

+ (CGFloat) getTheClosestVolume:(CGFloat)vol{
    
    CGFloat newVol = 0.0f;
//    NSLog(@"最大出来高： %.0f", vol );
    
    CGFloat thousand =         1000.f;
    CGFloat tenThousand =      10000.f;
    CGFloat hundredThousand =  100000.f;
    CGFloat million =          1000000.f;
    CGFloat tenMillion =       10000000.f;
    CGFloat hundredMillion =   100000000.f;
    CGFloat billion =          1000000000.f;
    
    if(vol <= tenThousand ){
        newVol = floorf(vol / thousand) * thousand;
    }
    else if(vol <= hundredThousand ){
        newVol = floorf(vol / tenThousand) * tenThousand;
    }
    else if(vol <= million ){
        newVol = floorf(vol / hundredThousand) * hundredThousand;
    }
    else if(vol <= tenMillion ){
        //3409000
        newVol = floorf(vol / million) * million;
    }
    else if(vol <= hundredMillion ){
        //28210200
        newVol = floorf(vol / tenMillion) * tenMillion;
    }
    else if(vol <= billion ){
        newVol = floorf(vol / hundredMillion) * hundredMillion;
    }

//    else if( vol > 100000000.f ){
//        CGFloat f1 = vol / 100000000;
//        newVol = roundf(f1) * 100000000 ;
//    }
    
    
    
    return newVol;
}

//+ (NSArray *)getPricesArrayH: (CGFloat)highPrice L: (CGFloat)lowPrice{
//    NSMutableArray *priceMutableArray = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%.2f", roundf(lowPrice)],[NSString stringWithFormat:@"%.2f", roundf(highPrice) ], nil];
//
//}


//間隔線のリスト
+ (NSArray *)getPricesByHighPrice: (CGFloat)highPrice lowPrice: (CGFloat)lowPrice{
    NSInteger low = [NSString stringWithFormat:@"%.2f",  roundf(lowPrice)].integerValue;
    NSInteger high = [NSString stringWithFormat:@"%.2f", roundf(highPrice)].integerValue;
    
//    NSMutableArray *priceMutableArray = [[NSMutableArray alloc]initWithObjects:
//                                         [NSString stringWithFormat:@"%.2f", roundf(lowPrice)],
//                                         [NSString stringWithFormat:@"%.2f", roundf(highPrice)], nil];
    NSMutableArray *priceMutableArray = [[NSMutableArray alloc]initWithObjects:
                                         [NSNumber numberWithFloat: roundf(lowPrice)],
                                         [NSNumber numberWithFloat: roundf(highPrice)], nil];
    
    for(NSInteger i = low + 1; i < high; i++){
        [priceMutableArray addObject: [NSNumber numberWithInteger: i] ];
    }
    
    
    NSInteger cnt = priceMutableArray.count;
    
    
    if(cnt == 2){
        [priceMutableArray addObject: [NSNumber numberWithFloat: ((CGFloat)low+(CGFloat)high)/2]];
    }
    else if(cnt > 2 && cnt < 10){
        
    }
    else{
        //cnt >= 10
        
        NSInteger span;
        NSInteger priceBegin = 0;
        if(cnt >= 10 && cnt <= 20){
            span = 2;
            //            priceBegin = low;
            priceBegin = [ChartBox getClosestEvenNumber:low];
        }
        //        else if(cnt > 20 && cnt <= 40){
        //            span = 4;
        //            priceBegin = [Util getClosestEvenNumber:low];
        //        }
        else if(cnt > 20 && cnt <= 70){
            span = 5;
            priceBegin = [ChartBox getClosetHalfNumber: low];
        }
        else if(cnt > 70 && cnt <= 100){
            span = 10;
        }
        else if(cnt > 100 && cnt <= 200)
            span = 20;
        //        else if(cnt > 200 && cnt <= 400)
        //            span = 40;
        else if(cnt > 200 && cnt <= 700)
            span = 50;
        
        else if(cnt > 700 && cnt <= 1000)
            span = 100;
        
        else if(cnt > 1000 && cnt <= 3000)
            span = 500;
        
        else if(cnt > 3000 && cnt <= 5000)
            span = 1000;
        
        else if(cnt > 5000 && cnt <= 10000)
            span = 2000;
        else
            span = 2500;
        
        if(priceBegin == 0){
            if(low < 100){
                priceBegin = (NSInteger)roundf( low/10 ) * 10 ;
            }
            else if(low < 1000){
                priceBegin = (NSInteger)roundf( low/100 ) * 100 ;
            }
            else if(low < 10000){
                priceBegin = (NSInteger)roundf( low/1000 ) * 1000 ;
            }
            else if(low < 100000){
                priceBegin = (NSInteger)roundf( low/10000 ) * 10000 ;
            }
            else{
                
            }
        }
        
        
        
        
        [priceMutableArray removeAllObjects];
        for(NSInteger i = priceBegin; i < high; i+=span){
            [priceMutableArray addObject: [NSNumber numberWithInteger: i]];
        }
        
    }
    
    return [NSArray arrayWithArray: priceMutableArray];
}

//偶数を返す
+ (CGFloat)getClosestEvenNumber: (CGFloat)f{
    CGFloat f1 = roundf(f);
    
    if( (NSInteger)f1 % 2 == 0 )//偶数
        return f1;
    else{ //奇数
        if(f1 == f)
            return f1-1;
        else if(f1 > f)
            return floorf(f);
        else
            return ceilf(f);
    }
    
}


+ (CGFloat)getTheClosestNumber: (CGFloat)f{
    
    //6.18 -> 6.20
    CGFloat f1 = 0.0f;
    //    if(f < 10.0){
    //        f1 = roundf( f * 10 ) / 10;
    //    }
    f1 = roundf( f/10 ) * 10;
    return f1;
}



+ (CGFloat)getBottomBoundValue:(CGFloat)valPrice{
    if(valPrice >= 10.0f){
        return floorf( valPrice );
    }
    
    float nValPrice = floorf( valPrice );
    NSString *strPrice = [NSString stringWithFormat:@"%.2f", valPrice];
    strPrice = [NSString stringWithFormat:@"0.%@", [strPrice substringWithRange:NSMakeRange(strPrice.length-2, 2)]];
    
    if( strPrice.floatValue >= 0 && strPrice.floatValue <= 0.33 ){
        return nValPrice;
    }
    else if(strPrice.floatValue > 0.33 && strPrice.floatValue < 0.8){
        return nValPrice+0.5;
    }
    else{
        return ceilf(valPrice);
    }
    
}

+ (CGFloat)getClosetHalfNumber: (CGFloat)f{
    NSString *result;
    
    //    CGFloat f1 = roundf(f);
    //    CGFloat fraction = modff(f1/10, &f2);
    
    NSString *str = [NSString stringWithFormat:@"%.2f", f/10];
    
    
    float fraction = [[str componentsSeparatedByString:@"."][1] floatValue];
    
    if(fraction >= 0.f && fraction <= 25) {
        result = [NSString stringWithFormat:@"%@.0", [str componentsSeparatedByString:@"."][0]];
    }
    else if(fraction > 25 && fraction <= 75) {
        result = [NSString stringWithFormat:@"%@.5", [str componentsSeparatedByString:@"."][0]];
    }
    else{
        result = [NSString stringWithFormat:@"%.0f", [[str componentsSeparatedByString:@"."][0] floatValue] + 1 ];
    }
    
    
    return result.floatValue * 10;
}


+ (CGFloat)getUpperBoundValue:(CGFloat)valPrice{
    if(valPrice >= 10.0f){
        return ceilf(valPrice);
    }
    
    float nValPrice = floorf( valPrice );
    NSString *strPrice = [NSString stringWithFormat:@"%.2f", valPrice];
    strPrice = [NSString stringWithFormat:@"0.%@", [strPrice substringWithRange:NSMakeRange(strPrice.length-2, 2)]];
    
    if( strPrice.floatValue >= 0 && strPrice.floatValue <= 0.2 ){
        return nValPrice;
    }
    else if(strPrice.floatValue > 0.2 && strPrice.floatValue < 0.77){
        return nValPrice+0.5;
    }
    else{
        return ceilf(valPrice);
    }
    
}

+(void)DrawLine:(CGRect)frame addView:(UIView *)view{
    UIView *lineViewRight = [[UIView alloc] initWithFrame:frame];
    lineViewRight.backgroundColor = [UIColor colorWithHexString:@"A7A7A7"];
    [view addSubview:lineViewRight];
    [view bringSubviewToFront:lineViewRight];
}



#pragma mark - チャート描画データの取得

//描画用データを取得 移動平均
- (void)getDrawData_movingAverage{
    //短期
    int maShortPeriod;
    //中期
    int maMediumPeriod;
    //長期
    int maLongPeriod;
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        maShortPeriod = [self.technicalValueDic[@"ma_1min_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_1min_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_1min_l"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        maShortPeriod = [self.technicalValueDic[@"ma_10min_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_10min_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_10min_l"] intValue];
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        maShortPeriod = [self.technicalValueDic[@"ma_hour_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_hour_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_hour_l"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        maShortPeriod = [self.technicalValueDic[@"ma_day_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_day_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_day_l"] intValue];
//
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        maShortPeriod = [self.technicalValueDic[@"ma_week_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_week_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_week_l"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        maShortPeriod = [self.technicalValueDic[@"ma_month_s"] intValue];
//        maMediumPeriod = [self.technicalValueDic[@"ma_month_m"] intValue];
//        maLongPeriod = [self.technicalValueDic[@"ma_month_l"] intValue];
//        
//    }
    
    
    self.maShortArray = [ChartBox calculateMoveAvg: maShortPeriod beanArray:self.ohlcMutableArray.copy];
    self.maMediumArray = [ChartBox calculateMoveAvg: maMediumPeriod beanArray:self.ohlcMutableArray.copy];
    self.maLongArray = [ChartBox calculateMoveAvg: maLongPeriod beanArray: self.ohlcMutableArray.copy];

}

//描画用データを取得 ボリンジャー
- (void)getDrawData_bollinger{
    int bollingerMa;
    int bollinger1;
    int bollinger2;
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        bollingerMa = [self.technicalValueDic[@"bollinger_1min_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_1min_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_1min_2"] intValue];
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        bollingerMa = [self.technicalValueDic[@"bollinger_10min_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_10min_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_10min_2"] intValue];
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        bollingerMa = [self.technicalValueDic[@"bollinger_hour_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_hour_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_hour_2"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        bollingerMa = [self.technicalValueDic[@"bollinger_day_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_day_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_day_2"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        bollingerMa = [self.technicalValueDic[@"bollinger_week_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_week_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_week_2"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        bollingerMa = [self.technicalValueDic[@"bollinger_month_ma"] intValue];
//        bollinger1 = [self.technicalValueDic[@"bollinger_month_1"] intValue];
//        bollinger2 = [self.technicalValueDic[@"bollinger_month_2"] intValue];
//        
//    }
    
    
    
    self.bollingerInfoArray = [ChartBox caluculateBollingerBandsTerm: bollingerMa
                                                                                  standardDeviationMR: bollinger1  standardDeviation2MR: bollinger2 beanArray: self.ohlcMutableArray.copy];

}

//描画用データを取得 一目均衡表
- (void)getDrawData_ichimoku{
    int itimoku_shortTerm;
    int itimoku_mediumTerm;
    int itimoku_longTerm;
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_1min_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_1min_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_1min_span"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_10min_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_10min_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_10min_span"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_hour_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_hour_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_hour_span"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_day_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_day_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_day_span"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_week_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_week_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_week_span"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        itimoku_shortTerm = [self.technicalValueDic[@"itimoku_month_convert"] intValue];
//        itimoku_mediumTerm = [self.technicalValueDic[@"itimoku_month_base"] intValue];
//        itimoku_longTerm = [self.technicalValueDic[@"itimoku_month_span"] intValue];
//        
//    }

    
    self.ichimokuInfoArray = [ChartBox calculateIchimokuShortTerm: itimoku_shortTerm MiddleTerm:itimoku_mediumTerm LongTerm:itimoku_longTerm beanArray: self.ohlcMutableArray.copy];

}

//描画用データを取得 RSI
- (void)getDrawData_rsi{
    int term;
//    int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_2"] intValue];
//    int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_3"] intValue];
    
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_1min_1"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_10min_1"] intValue];
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_hour_1"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_day_1"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_week_1"] intValue];
//
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        term = [[ChartBox sharedInstance].technicalValueDic[@"rsi_month_1"] intValue];
//
//    }

    
    
    [ChartBox sharedInstance].rsiInfoArray = [ChartBox caluculateRSI:term beanArray: self.ohlcMutableArray.copy];

}

//描画用データを取得 MACD
- (void)getDrawData_macd{
    // 短期EMA
    int shortEMA;
    // 長期EMA
    int longEMA;
    // 底値ライン
    int signal;
    
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_1min_3"] intValue];
//
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_10min_3"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_hour_3"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_day_3"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_week_3"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        shortEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_1"] intValue];
//        longEMA = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_2"] intValue];
//        signal = [[ChartBox sharedInstance].technicalValueDic[@"macd_month_3"] intValue];
//
//    }

    
    [ChartBox sharedInstance].macdInfoArray = [ChartBox caluculateMACDshortEMA:shortEMA longEMA:longEMA signal:signal beanArray:[ChartBox sharedInstance].ohlcMutableArray.copy];

}

//描画用データを取得 Sストキャス
- (void)getDrawData_stochas{
    // 高安周期
    int highLowCircle;
    // d期間
    int dTerm;
    
//    if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES1]) {//1分足
//        
//        highLowCircle = [self.technicalValueDic[@"stochas_1min_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_1min_2"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MINUTES10] ) {//10分足
//        highLowCircle = [self.technicalValueDic[@"stochas_10min_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_10min_2"] intValue];
//        
//    }
//    else if( [[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_TIME]) {//60分足
//        highLowCircle = [self.technicalValueDic[@"stochas_hour_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_hour_2"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_DAY]){//日足
//        highLowCircle = [self.technicalValueDic[@"stochas_day_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_day_2"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_WEEK]){//週足
//        highLowCircle = [self.technicalValueDic[@"stochas_week_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_week_2"] intValue];
//        
//    }
//    else if([[ChartBox sharedInstance].ashiTypeSelected isEqualToString:BAR_TYPE_MONTH]){//月足
//        highLowCircle = [self.technicalValueDic[@"stochas_month_1"] intValue];
//        dTerm = [self.technicalValueDic[@"stochas_month_2"] intValue];
//        
//    }

    // 底値ライン
    //    int overSellLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_3"] intValue];
    //    int overBuyLine = [[ChartBox sharedInstance].technicalValueDic[@"stochas_day_4"] intValue];
    self.stochasInfoArray = [ChartBox calculateSlowStcstcsJudgeTerm:highLowCircle avgTerm:dTerm beanArray:self.ohlcMutableArray.copy];

}


//チャートの描画データを取得
- (void)getDrawChartData{
    
    [self getDrawData_movingAverage];

    [self getDrawData_bollinger];
    
    [self getDrawData_ichimoku];
    
    [self getDrawData_rsi];
    
    [self getDrawData_macd];
    
    [self getDrawData_stochas];
    
}

//最高値・最安値・最大出来高を取得
- (void)getLimitValues_in_chart{
    NSRange range = NSMakeRange(self.ohlcMutableArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT);
    
    if(self.ohlcMutableArray.count <= CANDLE_STICK_COUNT){
        self.ohlcArray_in_chart = self.ohlcMutableArray.copy;
    }
    else{
        self.ohlcArray_in_chart = [self.ohlcMutableArray subarrayWithRange:range];
    }
    
    //移動平均・短期
    if(self.maShortArray.count <= CANDLE_STICK_COUNT){
        self.movAvgShortArray_in_chart = self.maShortArray;
    }
    else{
        self.movAvgShortArray_in_chart = [self.maShortArray subarrayWithRange:NSMakeRange(self.maShortArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }
    
    //移動平均・中期
    if(self.maMediumArray.count <= CANDLE_STICK_COUNT){
        self.movAvgMediumArray_in_chart = self.maMediumArray;
    }
    else{
        self.movAvgMediumArray_in_chart = [self.maMediumArray subarrayWithRange:NSMakeRange(self.maMediumArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
        
    }
    
    //移動平均・長期
    if([ChartBox sharedInstance].maLongArray.count <= CANDLE_STICK_COUNT){
        self.movAvgLongArray_in_chart = [ChartBox sharedInstance].maLongArray;
    }
    else{
        self.movAvgLongArray_in_chart = [[ChartBox sharedInstance].maLongArray subarrayWithRange:NSMakeRange(self.maLongArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }
    
    //ボリンジャー
    if([ChartBox sharedInstance].bollingerInfoArray.count <= CANDLE_STICK_COUNT){
        self.bollingerInfoArray_in_chart = [ChartBox sharedInstance].bollingerInfoArray;
    }
    else{
        self.bollingerInfoArray_in_chart = [[ChartBox sharedInstance].bollingerInfoArray subarrayWithRange:NSMakeRange([ChartBox sharedInstance].bollingerInfoArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }
    //    NSLog(@"Bollinger array count is : All[%ld] trim[%ld]", self.bollingerInfoArray.count, bollingerArray.count );
    
    
    //一目均衡表
//    if([ChartBox sharedInstance].ichimokuInfoArray.count - LEADING_SPAN_TERM <= CANDLE_STICK_COUNT){
//        self.itikomokuInfoArray_in_chart = [ChartBox sharedInstance].ichimokuInfoArray;
//    }
//    else{
//        self.itikomokuInfoArray_in_chart = [[ChartBox sharedInstance].ichimokuInfoArray subarrayWithRange:NSMakeRange([ChartBox sharedInstance].ichimokuInfoArray.count - CANDLE_STICK_COUNT - LEADING_SPAN_TERM, CANDLE_STICK_COUNT)];
//        
//    }
    if(self.ichimokuInfoArray.count <= CANDLE_STICK_COUNT){
        self.itikomokuInfoArray_in_chart = self.ichimokuInfoArray;
    }
    else{
        self.itikomokuInfoArray_in_chart = [self.ichimokuInfoArray subarrayWithRange:NSMakeRange(self.ichimokuInfoArray.count - CANDLE_STICK_COUNT, CANDLE_STICK_COUNT)];
    }
    //NSLog(@"＞＞＞一目均衡表全部リスト件数：%ld　＞＞＞サブリスト件数：%ld ",[ChartBox sharedInstance].ichimokuInfoArray.count, self.itikomokuInfoArray_in_chart.count );
    
    
    OhlcBean *item0 = [self.ohlcArray_in_chart objectAtIndex: 0];
    self.maxPrice = item0.highPrice.floatValue;
    self.minPrice = item0.lowPrice.floatValue;
    self.maxVolume = item0.turnover;
    for(OhlcBean *item in self.ohlcArray_in_chart){
        if(item.highPrice.floatValue > self.maxPrice)
            self.maxPrice = item.highPrice.floatValue;
        if(item.lowPrice.floatValue < self.minPrice)
            self.minPrice = item.lowPrice.floatValue;
        if(item.turnover > self.maxVolume)
            self.maxVolume = item.turnover;
    }
    self.maxPriceDisp = self.maxPrice;
    self.minPriceDisp = self.minPrice;
    
    //高値・安値の位置
    for(OhlcBean *item in self.ohlcArray_in_chart){
        if( self.maxPrice == item.highPrice.floatValue)
            self.maxPriceIdx = [self.ohlcArray_in_chart indexOfObject:item];
        if( self.minPrice == item.lowPrice.floatValue )
            self.minPriceIdx = [self.ohlcArray_in_chart indexOfObject:item];
    }
    
    //移動平均
    if(self.needShowMovAvg){
        for(NSDecimalNumber *ma in self.movAvgShortArray_in_chart){
            if(ma != nil && ![ma isEqual:[NSNull null]] ){
                if(ma.floatValue > self.maxPrice)
                    self.maxPrice = ma.floatValue;
                if(ma.floatValue < self.minPrice)
                    self.minPrice = ma.floatValue;
                
            }
        }
        for(NSDecimalNumber *ma in self.movAvgMediumArray_in_chart){
            if(ma != nil && ![ma isEqual:[NSNull null]] ){
                if(ma.floatValue > self.maxPrice)
                    self.maxPrice = ma.floatValue;
                if(ma.floatValue < self.minPrice)
                    self.minPrice = ma.floatValue;
            }
        }
        for(NSDecimalNumber *ma in self.movAvgLongArray_in_chart){
            if(ma != nil && ![ma isEqual:[NSNull null]] ){
                if(ma.floatValue > self.maxPrice)
                    self.maxPrice = ma.floatValue;
                if(ma.floatValue < self.minPrice)
                    self.minPrice = ma.floatValue;
            }
        }
    }
    
    //ボリンジャー
    if( self.needShowBollinger ){
        for(NSMutableArray *mutableArray in self.bollingerInfoArray_in_chart){
            if(mutableArray == nil || mutableArray.count == 0){
            }
            else{
                CGFloat bollingerValue0 = [mutableArray[0] floatValue];
                CGFloat bollingerValue1 = [mutableArray[1] floatValue];
                CGFloat bollingerValue2 = [mutableArray[2] floatValue];
                CGFloat bollingerValue3 = [mutableArray[3] floatValue];
                CGFloat bollingerValue4 = [mutableArray[4] floatValue];
                
                if(bollingerValue0 > self.maxPrice)
                    self.maxPrice = bollingerValue0;
                if(bollingerValue1 > self.maxPrice)
                    self.maxPrice = bollingerValue1;
                if(bollingerValue2 > self.maxPrice)
                    self.maxPrice = bollingerValue2;
                if(bollingerValue3 > self.maxPrice)
                    self.maxPrice = bollingerValue3;
                if(bollingerValue4 > self.maxPrice)
                    self.maxPrice = bollingerValue4;
                if(bollingerValue0 < self.minPrice)
                    self.minPrice = bollingerValue0;
                if(bollingerValue1 < self.minPrice)
                    self.minPrice = bollingerValue1;
                if(bollingerValue2 < self.minPrice)
                    self.minPrice = bollingerValue2;
                if(bollingerValue3 < self.minPrice)
                    self.minPrice = bollingerValue3;
                if(bollingerValue4 < self.minPrice)
                    self.minPrice = bollingerValue4;
            }
        }
        
        
    }
    
    
    //一目均衡表
    if(self.needShowIchimoku){
        
        for(NSMutableArray *mutableArray in self.itikomokuInfoArray_in_chart){
            if(mutableArray == nil || mutableArray.count == 0){
                
            }
            else{
                NSDecimalNumber *itimoku0 = mutableArray[0];
                if(itimoku0 == nil || [itimoku0 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku0.floatValue > self.maxPrice)
                        self.maxPrice = itimoku0.floatValue;
                    if(itimoku0.floatValue < self.minPrice)
                        self.minPrice = itimoku0.floatValue;
                }
                
                NSDecimalNumber *itimoku1 = mutableArray[1];
                if(itimoku1 == nil || [itimoku1 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku1.floatValue > self.maxPrice)
                        self.maxPrice = itimoku1.floatValue;
                    if(itimoku1.floatValue < self.minPrice)
                        self.minPrice = itimoku1.floatValue;
                }
                
                NSDecimalNumber *itimoku2 = mutableArray[2];
                if(itimoku2 == nil || [itimoku2 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku2.floatValue > self.maxPrice)
                        self.maxPrice = itimoku2.floatValue;
                    if(itimoku2.floatValue < self.minPrice)
                        self.minPrice = itimoku2.floatValue;
                }
                
                NSDecimalNumber *itimoku3 = mutableArray[3];
                if(itimoku3 == nil || [itimoku3 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku3.floatValue > self.maxPrice)
                        self.maxPrice = itimoku3.floatValue;
                    if(itimoku3.floatValue < self.minPrice)
                        self.minPrice = itimoku3.floatValue;
                }
                
                NSDecimalNumber *itimoku4 = mutableArray[4];
                if(itimoku4 == nil || [itimoku4 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku4.floatValue > self.maxPrice)
                        self.maxPrice = itimoku4.floatValue;
                    if(itimoku4.floatValue < self.minPrice)
                        self.minPrice = itimoku4.floatValue;
                }
            }
        }
        
    }
    
    
}



//最高値・最安値取得
- (void)getLimitValueInAll{
    if([ChartBox sharedInstance].ohlcMutableArray.count == 0){
        return;
    }
    
    self.maxPriceInAll = ((OhlcBean *)self.ohlcMutableArray[0]).highPrice.floatValue;
    self.minPriceInAll = ((OhlcBean *)self.ohlcMutableArray[0]).lowPrice.floatValue;
    self.maxVolumeInAll = 0;
    
    for(OhlcBean *item in self.ohlcMutableArray){
        if(item.highPrice.floatValue > self.maxPriceInAll)
            self.maxPriceInAll = item.highPrice.floatValue;
        if(item.lowPrice.floatValue < self.minPriceInAll)
            self.minPriceInAll = item.lowPrice.floatValue;
        if(item.turnover > self.maxVolumeInAll)
            self.maxVolumeInAll = item.turnover;
    }
    self.maxPriceInAllDisp = self.maxPriceInAll;
    self.minPriceInAllDisp = self.minPriceInAll;
    
    //高値・安値の位置
    for(OhlcBean *item in self.ohlcMutableArray ){
        if( item.lowPrice.floatValue == self.minPriceInAll )
            self.minPriceIdxInAll = [self.ohlcMutableArray indexOfObject:item];
        if( item.highPrice.floatValue == self.maxPriceInAll)
            self.maxPriceIdxInAll = [self.ohlcMutableArray indexOfObject:item];
    }
    
    
    if(self.needShowMovAvg){
        for(NSDecimalNumber *ma in [ChartBox sharedInstance].maShortArray){
            if([ma isEqual:[NSNull null]])
                continue;
            
            if(ma.floatValue > self.maxPriceInAll)
                self.maxPriceInAll = ma.floatValue;
            if(ma.floatValue < self.minPriceInAll)
                self.minPriceInAll = ma.floatValue;
        }
        for(NSDecimalNumber *ma in [ChartBox sharedInstance].maMediumArray){
            if([ma isEqual:[NSNull null]])
                continue;
            
            if(ma.floatValue > self.maxPriceInAll)
                self.maxPriceInAll = ma.floatValue;
            if(ma.floatValue < self.minPriceInAll)
                self.minPriceInAll = ma.floatValue;
        }
        for(NSDecimalNumber *ma in [ChartBox sharedInstance].maLongArray){
            if([ma isEqual:[NSNull null]])
                continue;
            
            if(ma.floatValue > self.maxPriceInAll)
                self.maxPriceInAll = ma.floatValue;
            if(ma.floatValue < self.minPriceInAll)
                self.minPriceInAll = ma.floatValue;
        }
        
    }
    
    
    if(self.needShowBollinger){
        for(NSMutableArray *mutableArray in [ChartBox sharedInstance].bollingerInfoArray){
            if(mutableArray == nil || mutableArray.count == 0){
            }
            else{
                CGFloat bollingerValue0 = [mutableArray[0] floatValue];
                CGFloat bollingerValue1 = [mutableArray[1] floatValue];
                CGFloat bollingerValue2 = [mutableArray[2] floatValue];
                CGFloat bollingerValue3 = [mutableArray[3] floatValue];
                CGFloat bollingerValue4 = [mutableArray[4] floatValue];
                
                if(bollingerValue0 > self.maxPriceInAll)
                    self.maxPriceInAll = bollingerValue0;
                if(bollingerValue1 > self.maxPriceInAll)
                    self.maxPriceInAll = bollingerValue1;
                if(bollingerValue2 > self.maxPriceInAll)
                    self.maxPriceInAll = bollingerValue2;
                if(bollingerValue3 > self.maxPriceInAll)
                    self.maxPriceInAll = bollingerValue3;
                if(bollingerValue4 > self.maxPriceInAll)
                    self.maxPriceInAll = bollingerValue4;
                if(bollingerValue0 < self.minPriceInAll)
                    self.minPriceInAll = bollingerValue0;
                if(bollingerValue1 < self.minPriceInAll)
                    self.minPriceInAll = bollingerValue1;
                if(bollingerValue2 < self.minPriceInAll)
                    self.minPriceInAll = bollingerValue2;
                if(bollingerValue3 < self.minPriceInAll)
                    self.minPriceInAll = bollingerValue3;
                if(bollingerValue4 < self.minPriceInAll)
                    self.minPriceInAll = bollingerValue4;
            }
            
        }
        
    }
    
    if(self.needShowIchimoku){
        for(NSMutableArray *mutableArray in [ChartBox sharedInstance].ichimokuInfoArray){
            if(mutableArray == nil || mutableArray.count == 0){
                
            }
            else{
                NSDecimalNumber *itimoku0 = mutableArray[0];
                if(itimoku0 == nil || [itimoku0 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku0.floatValue > self.maxPriceInAll)
                        self.maxPriceInAll = itimoku0.floatValue;
                    if(itimoku0.floatValue < self.minPriceInAll)
                        self.minPriceInAll = itimoku0.floatValue;
                }
                
                NSDecimalNumber *itimoku1 = mutableArray[1];
                if(itimoku1 == nil || [itimoku1 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku1.floatValue > self.maxPriceInAll)
                        self.maxPriceInAll = itimoku1.floatValue;
                    if(itimoku1.floatValue < self.minPriceInAll)
                        self.minPriceInAll = itimoku1.floatValue;
                }
                
                NSDecimalNumber *itimoku2 = mutableArray[2];
                if(itimoku2 == nil || [itimoku2 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku2.floatValue > self.maxPriceInAll)
                        self.maxPriceInAll = itimoku2.floatValue;
                    if(itimoku2.floatValue < self.minPriceInAll)
                        self.minPriceInAll = itimoku2.floatValue;
                }
                
                NSDecimalNumber *itimoku3 = mutableArray[3];
                if(itimoku3 == nil || [itimoku3 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku3.floatValue > self.maxPriceInAll)
                        self.maxPriceInAll = itimoku3.floatValue;
                    if(itimoku3.floatValue < self.minPriceInAll)
                        self.minPriceInAll = itimoku3.floatValue;
                }
                
                NSDecimalNumber *itimoku4 = mutableArray[4];
                if(itimoku4 == nil || [itimoku4 isEqual: [NSNull null]] ){
                }
                else{
                    if(itimoku4.floatValue > self.maxPriceInAll)
                        self.maxPriceInAll = itimoku4.floatValue;
                    if(itimoku4.floatValue < self.minPriceInAll)
                        self.minPriceInAll = itimoku4.floatValue;
                }
                
                
            }
            
        }
        
    }
    
    
    // MACD 最大・最小
    for(NSMutableArray *resultDatas in [ChartBox sharedInstance].macdInfoArray){
        if(resultDatas == nil || [resultDatas isEqual:[NSNull null]] || resultDatas.count != 3){
            continue;
        }
        
        if( resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3 ){
        }
        
        CGFloat macd = [resultDatas[0] floatValue];
        CGFloat signal = [resultDatas[1] floatValue];
        CGFloat osci = [resultDatas[2] floatValue];
        
        if(macd > self.macdMaxInAll)
            self.macdMaxInAll = macd;
        if(signal > self.macdMaxInAll)
            self.macdMaxInAll = signal;
        if(osci > self.macdMaxInAll)
            self.macdMaxInAll = osci;
        
        if(macd < self.macdMinInAll)
            self.macdMinInAll = macd;
        if(signal < self.macdMinInAll)
            self.macdMinInAll = signal;
        if(osci < self.macdMinInAll)
            self.macdMinInAll = osci;
    }
    
    
    
}


//Scroll範囲内の最高値・最安値取得
- (void)getLimitValueInRange: (CGFloat)offsetX{
    if(self.ohlcMutableArray.count == 0)
        return;


    //範囲内開始と終了値を取得
    NSInteger startIdx = 0;
    NSInteger endIdx = 0;
    
    if(self.ohlcMutableArray.count == CANDLESTICK_COUNT_ALL){
        startIdx = offsetX / [self getStickUnitWidth];
        endIdx = startIdx + [self getStickCountInRange];
        
    }
    else{
        startIdx = offsetX / [self getStickUnitWidth] - (CANDLESTICK_COUNT_ALL - self.ohlcMutableArray.count);
        if(startIdx < 0){
            startIdx = 0;
        }

        endIdx = (offsetX + self.detailChartViewWidth) / [self getStickUnitWidth] - (CANDLESTICK_COUNT_ALL - self.ohlcMutableArray.count);
        if(endIdx < 0){
            endIdx = 0;
        }

    
    }
    
    
    
    //高値・安値
    OhlcBean *item0 = [self.ohlcMutableArray objectAtIndex: startIdx];
    self.maxPriceInRange = item0.highPrice.floatValue;
    self.minPriceInRange = item0.lowPrice.floatValue;
    self.maxVolumeInRange = item0.turnover;
    
    //    NSInteger lastNo = startIdx + countInRange > [ChartBox sharedInstance].ohlcMutableArray.count ?
    NSRange range = NSMakeRange(startIdx, endIdx - startIdx );
    NSArray *arr = [self.ohlcMutableArray subarrayWithRange: range];
    
    for(OhlcBean *item in arr){
        if(item.highPrice.floatValue > self.maxPriceInRange)
            self.maxPriceInRange = item.highPrice.floatValue;
        if(item.lowPrice.floatValue < self.minPriceInRange)
            self.minPriceInRange = item.lowPrice.floatValue;
        if(item.turnover > self.maxVolumeInRange)
            self.maxVolumeInRange = item.turnover;
    }
    
    
    //高値・安値の位置
    for(OhlcBean *item in arr){
        if( item.lowPrice.floatValue == self.minPriceInRange)
            self.minPriceIdxInRange = [arr indexOfObject:item];
        if( item.highPrice.floatValue == self.maxPriceInRange)
            self.maxPriceIdxInRange = [arr indexOfObject:item];
    }
    
    arr = [self.maShortArray subarrayWithRange:range];
    for(NSDecimalNumber *ma in arr){
        if([ma isEqual: [NSNull null]]){
            continue;
        }
        
        if(ma.floatValue > self.maxPriceInRange)
            self.maxPriceInRange = ma.floatValue;
        if(ma.floatValue < self.minPriceInRange)
            self.minPriceInRange = ma.floatValue;
    }
    
    arr = [self.maMediumArray subarrayWithRange:range];
    for(NSDecimalNumber *ma in arr){
        if([ma isEqual: [NSNull null]]){
            continue;
        }
        
        if(ma.floatValue > self.maxPriceInRange)
            self.maxPriceInRange = ma.floatValue;
        if(ma.floatValue < self.minPriceInRange)
            self.minPriceInRange = ma.floatValue;
    }
    
    arr = [self.maLongArray subarrayWithRange:range];
    for(NSDecimalNumber *ma in arr){
        if([ma isEqual: [NSNull null]]){
            continue;
        }
        
        if(ma.floatValue > self.maxPriceInRange)
            self.maxPriceInRange = ma.floatValue;
        if(ma.floatValue < self.minPriceInRange)
            self.minPriceInRange = ma.floatValue;
    }
    
    arr = [[ChartBox sharedInstance].bollingerInfoArray subarrayWithRange:range];
    for(NSMutableArray *mutableArray in arr){
        if(mutableArray == nil || mutableArray.count == 0){
        }
        else{
            CGFloat bollingerValue0 = [mutableArray[0] floatValue];
            CGFloat bollingerValue1 = [mutableArray[1] floatValue];
            CGFloat bollingerValue2 = [mutableArray[2] floatValue];
            CGFloat bollingerValue3 = [mutableArray[3] floatValue];
            CGFloat bollingerValue4 = [mutableArray[4] floatValue];
            
            if(bollingerValue0 > self.maxPriceInRange)
                self.maxPriceInRange = bollingerValue0;
            if(bollingerValue1 > self.maxPriceInRange)
                self.maxPriceInRange = bollingerValue1;
            if(bollingerValue2 > self.maxPriceInRange)
                self.maxPriceInRange = bollingerValue2;
            if(bollingerValue3 > self.maxPriceInRange)
                self.maxPriceInRange = bollingerValue3;
            if(bollingerValue4 > self.maxPriceInRange)
                self.maxPriceInRange = bollingerValue4;
            if(bollingerValue0 < self.minPriceInRange)
                self.minPriceInRange = bollingerValue0;
            if(bollingerValue1 < self.minPriceInRange)
                self.minPriceInRange = bollingerValue1;
            if(bollingerValue2 < self.minPriceInRange)
                self.minPriceInRange = bollingerValue2;
            if(bollingerValue3 < self.minPriceInRange)
                self.minPriceInRange = bollingerValue3;
            if(bollingerValue4 < self.minPriceInRange)
                self.minPriceInRange = bollingerValue4;
        }
        
    }
    
    arr = [self.ichimokuInfoArray subarrayWithRange:range];
    for(NSMutableArray *mutableArray in arr){
        if(mutableArray == nil || mutableArray.count == 0){
            
        }
        else{
            NSDecimalNumber *itimoku0 = mutableArray[0];
            if(itimoku0 == nil || [itimoku0 isEqual: [NSNull null]] ){
            }
            else{
                if(itimoku0.floatValue > self.maxPriceInRange)
                    self.maxPriceInRange = itimoku0.floatValue;
                if(itimoku0.floatValue < self.minPriceInRange)
                    self.minPriceInRange = itimoku0.floatValue;
            }
            
            NSDecimalNumber *itimoku1 = mutableArray[1];
            if(itimoku1 == nil || [itimoku1 isEqual: [NSNull null]] ){
            }
            else{
                if(itimoku1.floatValue > self.maxPriceInRange)
                    self.maxPriceInRange = itimoku1.floatValue;
                if(itimoku1.floatValue < self.minPriceInRange)
                    self.minPriceInRange = itimoku1.floatValue;
            }
            
            NSDecimalNumber *itimoku2 = mutableArray[2];
            if(itimoku2 == nil || [itimoku2 isEqual: [NSNull null]] ){
            }
            else{
                if(itimoku2.floatValue > self.maxPriceInRange)
                    self.maxPriceInRange = itimoku2.floatValue;
                if(itimoku2.floatValue < self.minPriceInRange)
                    self.minPriceInRange = itimoku2.floatValue;
            }
            
            NSDecimalNumber *itimoku3 = mutableArray[3];
            if(itimoku3 == nil || [itimoku3 isEqual: [NSNull null]] ){
            }
            else{
                if(itimoku3.floatValue > self.maxPriceInRange)
                    self.maxPriceInRange = itimoku3.floatValue;
                if(itimoku3.floatValue < self.minPriceInRange)
                    self.minPriceInRange = itimoku3.floatValue;
            }
            
            NSDecimalNumber *itimoku4 = mutableArray[4];
            if(itimoku4 == nil || [itimoku4 isEqual: [NSNull null]] ){
            }
            else{
                if(itimoku4.floatValue > self.maxPriceInRange)
                    self.maxPriceInRange = itimoku4.floatValue;
                if(itimoku4.floatValue < self.minPriceInRange)
                    self.minPriceInRange = itimoku4.floatValue;
            }
            
            
        }
        
    }
    
    
    
    // MACD 最大・最小
    
    NSArray *macdRangeArray = [self.macdInfoArray subarrayWithRange:NSMakeRange(startIdx, endIdx - startIdx)];
    for(NSMutableArray *resultDatas in macdRangeArray){
        if(resultDatas == nil || [resultDatas isEqual:[NSNull null]] || resultDatas.count != 3){
            continue;
        }
        
        
        if( resultDatas != nil && ![resultDatas isEqual:[NSNull null]] && resultDatas.count == 3 ){
        }
        
        CGFloat macd = [resultDatas[0] floatValue];
        CGFloat signal = [resultDatas[1] floatValue];
        CGFloat osci = [resultDatas[2] floatValue];
        
        if(macd > self.macdMaxInRange)
            self.macdMaxInRange = macd;
        if(signal > self.macdMaxInRange)
            self.macdMaxInRange = signal;
        if(osci > self.macdMaxInRange)
            self.macdMaxInRange = osci;
        
        if(macd < self.macdMinInRange)
            self.macdMinInRange = macd;
        if(signal < self.macdMinInRange)
            self.macdMinInRange = signal;
        if(osci < self.macdMinInRange)
            self.macdMinInRange = osci;
    }
    
}

//チャートの描画データをクリア
- (void)clearDrawChartData{
    [self.ohlcMutableArray removeAllObjects];
    self.ohlcArray_in_chart = nil;
    self.movAvgShortArray_in_chart = nil;
    self.movAvgMediumArray_in_chart = nil;
    self.movAvgLongArray_in_chart = nil;
    self.bollingerInfoArray_in_chart = nil;
    self.itikomokuInfoArray_in_chart = nil;
    
    self.maxPrice = 0.f;
    self.minPrice = 0.f;
    self.maxPriceDisp = 0.f;
    self.minPriceDisp = 0.f;
    self.maxPriceIdx = 0;
    self.minPriceIdx = 0;
    self.maxVolume = 0;
    
}

- (void)clearDetailChartData{
    [self.ohlcMutableArray removeAllObjects];
    self.maShortArray = nil;
    self.maMediumArray = nil;
    self.maLongArray = nil;
    self.bollingerInfoArray = nil;
    self.ichimokuInfoArray = nil;

    self.rsiInfoArray = nil;
    self.macdInfoArray = nil;
    self.stochasInfoArray = nil;
    
    self.maxPriceInAll = 0.f;
    self.minPriceInAll = 0.f;
    self.maxPriceInAllDisp = 0.f; //４本値の最大値
    self.minPriceInAllDisp = 0.f; //４本値の最小値
    self.maxVolumeInAll = 0;
    self.maxPriceIdxInAll = 0;
    self.minPriceIdxInAll = 0;
    self.macdMaxInAll = 0.f;
    self.macdMinInAll = 0.f;
    
    self.maxPriceInRange = 0.f;
    self.minPriceInRange = 0.f;
    self.maxVolumeInRange = 0;
    self.maxPriceIdxInRange = 0;
    self.minPriceIdxInRange = 0;
    self.macdMaxInRange = 0.f;
    self.macdMinInRange = 0.f;
}

#pragma mark - Some Methods


- (BOOL)isMonthHead :(NSString *)date{
    if(date.length == 8){
        date = [NSString stringWithFormat: @"%@-%@-%@", [date substringToIndex:4],[date substringWithRange:NSMakeRange(4, 2) ], [date substringFromIndex: 6]];
        
    }
    
    NSArray *array = [date componentsSeparatedByString:@"-"];
    NSString *ym = [NSString stringWithFormat:@"%@%@", array[0], array[1]];
    int d = [array[2] intValue];
    if(d == 1){
        [self.ymdMutableArray addObject:ym];
        return YES;
    }
    if(d == 2){
        if(![self.ymdMutableArray containsObject:ym]){
            [self.ymdMutableArray addObject:ym];
            return YES;
        }
    }
    if(d == 3){
        if(![self.ymdMutableArray containsObject:ym]){
            [self.ymdMutableArray addObject:ym];
            return YES;
        }
    }
    if(d == 4){
        if(![self.ymdMutableArray containsObject:ym]){
            [self.ymdMutableArray addObject:ym];
            return YES;
        }
    }
    
    
    return NO;
}

//X軸有効開始座標を取得
- (CGFloat)getValidLeftBorder: (NSInteger)startIdx{
    //詳細チャートのX軸開始座標
    CGFloat leftBorderPosition = (CANDLESTICK_COUNT_ALL - self.ohlcMutableArray.count) * [self getStickUnitWidth];
    return leftBorderPosition + startIdx * [self getStickUnitWidth] + self.candleStickBodyWidth / 2 ;
}

//詳細チャートのX軸開始座標
- (CGFloat)getStartPositionX{
    return (CANDLESTICK_COUNT_ALL - self.ohlcMutableArray.count) * [self getStickUnitWidth] + self.candleStickBodyWidth / 2;
}

//ローソクステックの幅を取得
- (CGFloat)getStickUnitWidth{
    
    return self.candleStickBodyWidth + self.candleStickInterval;
}

- (NSInteger)getStickCountInRange{
    NSInteger cnt = self.detailChartViewWidth / [self getStickUnitWidth]; //何本？114
    return cnt;
}

- (void)saveTechnicalSettingValues{
    
}

- (void)saveChartSettingOptions{
    
    chartSettingMutableDictionary[@"ashi"] = [ChartBox sharedInstance].ashiTypeSelected;
    //サブチャート
    chartSettingMutableDictionary[@"subchart"] = self.needShowSubChart ? @"1" : @"0";
    //Y軸固定するか
    chartSettingMutableDictionary[@"yaxis"] = self.yAxisFixed ? @"1" : @"0";
    //移動平均を表示するか
    chartSettingMutableDictionary[@"show_movavg"] = self.needShowMovAvg ? @"1" : @"0";
    //ボリンジャーを表示するか
    chartSettingMutableDictionary[@"show_bollinger"] = self.needShowBollinger ? @"1" : @"0";
    //一目均衡表を表示するか
    chartSettingMutableDictionary[@"show_ichimoku"] = self.needShowIchimoku ? @"1" : @"0";
    //RSIを表示するか
    chartSettingMutableDictionary[@"show_rsi"] = self.needShowSub_rsi ? @"1" : @"0";
    //MACDを表示するか
    chartSettingMutableDictionary[@"show_macd"] = self.needShowSub_macd ? @"1" : @"0";
    //Sストキャスを表示するか
    chartSettingMutableDictionary[@"show_stochas"] = self.needShowSub_stochas ? @"1" : @"0";
    //出来高を表示するか
    chartSettingMutableDictionary[@"show_volume"] = self.needShowSub_volume ? @"1" : @"0";
    //4本値表示するか
    chartSettingMutableDictionary[@"show_fourprices"] = self.needShowFourPrices ? @"1" : @"0";

    [[NSUserDefaults standardUserDefaults] setObject:[chartSettingMutableDictionary copy] forKey: KEY_CHART_SETTING];

}

#pragma mark - Technical Calculate

/**
 * 移動平均計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * param moveAvgTerm    移動平均化日数
 * param fourValuesList 四本値を格納したリスト。index0の日時(fourValuesDate)が最も古く、末尾のデータが最も新しい状態を想定している
 * return プロットする移動平均値を格納したリストを返却する
 */
+ (NSArray *)calculateMoveAvg :(int) moveAvgTerm beanArray:(NSArray *) fourValuesList {
    
    // 0除算回避のため移動平均化日数をチェック
    if (moveAvgTerm == 0) {
        return nil;
    }
    
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    // 終値を格納する配列
    NSDecimalNumber *closePriceArray[fourValuesList.count];
    
    // 移動平均期間の終値合計
    NSDecimalNumber *totalClosePrice = DECIMALNUMBER_INTNUM(0);
    
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:fourValuesList.count];
    
    // メイン処理
    for (int i = 0; i < fourValuesList.count; i++) {
        
        // 終値の退避
        closePriceArray[i] = ((OhlcBean *)fourValuesList[i]).closePrice;
        
        // 終値合計の計算
        totalClosePrice = [closePriceArray[i] decimalNumberByAdding: totalClosePrice];
        
        // 対象期間から外れた処理データを削除する
        if (i >= moveAvgTerm) {
            totalClosePrice = [totalClosePrice decimalNumberBySubtracting: closePriceArray[i - moveAvgTerm] ];
        }
        
        // 処理データ数が移動平均化日数を満たす場合、返却リストに値をセットする
        if (i >= moveAvgTerm - 1) {
            // 移動平均計算
            NSDecimalNumber *moveAvgData = [totalClosePrice decimalNumberByDividingBy: DECIMALNUMBER_INTNUM(moveAvgTerm) withBehavior:ROUNDING_BEHAVIOR_5];
            [returnList addObject: moveAvgData];
        }
        else{
            [returnList addObject:[NSNull null]];
        }
    }
    
    return [returnList copy];
}


/**
 * ボリンジャーバンド計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * bollingerBandsTerm   移動平均化日数
 * standardDeviationMR  標準偏差倍率
 * standardDeviation2MR 標準偏差倍率2
 * fourValuesList       四本値を格納したリスト
 * プロットデータを格納したリストを返却する
 * [0]移動平均 [1]トップ1 [2]ロウ1 [3]トップ2 [4]ロウ2
 */
+ (NSArray *)caluculateBollingerBandsTerm: (int) bollingerBandsTerm  standardDeviationMR: (int) standardDeviationMR  standardDeviation2MR: (int) standardDeviation2MR beanArray: (NSArray *) fourValuesList{
    
    
    // 0での除算回避のため移動平均化日数のチェック
    if (bollingerBandsTerm == 0) {
        return nil;
    }
    
    // ４本値データの存在チェック
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    // 終値の退避領域作成
    NSDecimalNumber *closePrice[fourValuesList.count];
    
    // 終値の合計を格納する変数
    NSDecimalNumber *closePriceSum = DECIMALNUMBER_INTNUM(0);
    
    // 「終値の合計」の２乗を格納する変数
    NSDecimalNumber *closePriceSum_Square;
    
    // 「終値の２乗」退避領域作成
    NSDecimalNumber *closePrice_Square[fourValuesList.count];
    
    // 「終値の２乗」の合計を格納する変数
    NSDecimalNumber *closePrice_SquareSum = DECIMALNUMBER_INTNUM(0);
    
    // 期間計算用work
    NSDecimalNumber *workDivision1 = DECIMALNUMBER_INTNUM( bollingerBandsTerm );
    NSDecimalNumber *workDivision2 = DECIMALNUMBER_INTNUM( bollingerBandsTerm - 1);
    
    // 除算用 BigDecimal 変数(標準偏差用)
    NSDecimalNumber *standardDeviationDivision = [workDivision1 decimalNumberByMultiplyingBy:workDivision2];
    
    // 計算した移動平均を格納する変数
    NSDecimalNumber *moveAvg;
    
    // 標準偏差計算用 work 変数
    NSDecimalNumber *caluculateWork1;
    NSDecimalNumber *caluculateWork2;
    NSDecimalNumber *caluculateWork3;
    
    double standard_devitation;
    double BollingerTOP1;
    double BollingerTOP2;
    double BollingerLOW1;
    double BollingerLOW2;
    
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:fourValuesList.count];
    
    for (int i = 0; i < fourValuesList.count; i++) {
        
        // 取得した終値を退避、終値の合計を計算する
        closePrice[i] = ((OhlcBean *)fourValuesList[i]).closePrice;
        closePriceSum = [closePrice[i] decimalNumberByAdding:closePriceSum];
        
        // 取得した終値の２乗を退避、「終値の２乗」の合計を計算する
        closePrice_Square[i] = [closePrice[i] decimalNumberByMultiplyingBy:closePrice[i]];
        closePrice_SquareSum = [closePrice_Square[i] decimalNumberByAdding:closePrice_SquareSum];
        
        // 対象期間から外れた処理データを削除する
        if (bollingerBandsTerm <= i) {
            closePriceSum = [closePriceSum decimalNumberBySubtracting:closePrice[i-bollingerBandsTerm]];
            closePrice_SquareSum = [closePrice_SquareSum decimalNumberBySubtracting:closePrice_Square[i - bollingerBandsTerm] ];
        }
        
        // 移動平均
        moveAvg = [closePriceSum decimalNumberByDividingBy:workDivision1 withBehavior:ROUNDING_BEHAVIOR_5];
        
        // 終値合計の２乗
        closePriceSum_Square = [closePriceSum decimalNumberByMultiplyingBy:closePriceSum];
        
        // 標準偏差計算その１
        // 期間×(終値の２乗の合計)
        caluculateWork1 = [workDivision1 decimalNumberByMultiplyingBy:closePrice_SquareSum];
        
        //標準偏差計算その２
        // (期間×(終値の２乗の合計)) - 終値の合計の２乗
        caluculateWork2 = [caluculateWork1 decimalNumberBySubtracting:closePriceSum_Square];
        
        //標準偏差計算その３
        // (期間×(終値の２乗の合計)) - 終値の合計の２乗 ÷ (期間×(期間－１))
        caluculateWork3 = [caluculateWork2 decimalNumberByDividingBy:standardDeviationDivision withBehavior:ROUNDING_BEHAVIOR_5];
        
        // √を計算
        standard_devitation = sqrt([caluculateWork3 doubleValue]);
        
        // ボリンジャーTOPの計算
        BollingerTOP1 = [moveAvg doubleValue] + (standard_devitation * standardDeviationMR);
        BollingerTOP2 = [moveAvg doubleValue] + (standard_devitation * standardDeviation2MR);
        
        
        // ボリンジャーTOPの計算
        BollingerLOW1 = [moveAvg doubleValue] - (standard_devitation * standardDeviationMR);
        BollingerLOW2 = [moveAvg doubleValue] - (standard_devitation * standardDeviation2MR);
        
        // 返却データの整形
        NSMutableArray *returnDatas = [[NSMutableArray alloc]initWithCapacity:5];
        
        if (i >= bollingerBandsTerm - 1) {
            returnDatas[0] = [moveAvg decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2];
            returnDatas[1] = [[[NSDecimalNumber alloc] initWithDouble: BollingerTOP1 ] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2];
            returnDatas[2] = [[[NSDecimalNumber alloc] initWithDouble: BollingerLOW1 ] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2];
            returnDatas[3] = [[[NSDecimalNumber alloc] initWithDouble: BollingerTOP2 ] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2];
            returnDatas[4] = [[[NSDecimalNumber alloc] initWithDouble: BollingerLOW2 ] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2];
            
        }
        [returnList addObject:returnDatas];
        
    }
    
    return [returnList copy];
    
}

/**
 * 一目均衡表計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * shortTerm      短期移動平均化日数
 * middleTerm     中期移動平均化日数
 * longTerm       長期移動平均化日数
 * fourValuesList 四本値を格納したリスト
 * プロットデータを格納したリストを返却する。
 * [0]転換線 [1]基準線 [2]遅行線 [3]先行スパン1 [4]先行スパン2
 */
+ (NSArray *)calculateIchimokuShortTerm: (int)shortTerm MiddleTerm: (int)middleTerm LongTerm: (int)longTerm beanArray: (NSArray *) fourValuesList {
    
    // 0除算回避のため短期・中期・長期の日数チェック
    if (shortTerm == 0 || middleTerm == 0 || longTerm == 0) {
        return nil;
    }
    
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    NSInteger cnt = fourValuesList.count + LEADING_SPAN_TERM;
    
    // 転換線
    NSDecimalNumber *conversionLine[cnt];
    // 基準線
    NSDecimalNumber *baseLine[cnt];
    // 遅行線
    NSDecimalNumber *laggingLine[cnt];
    // 先行スパン１
    NSDecimalNumber *leadingSpan1[cnt];
    // 先行スパン２
    NSDecimalNumber *leadingSpan2[cnt];
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:cnt];
    
    // メイン処理
    for(int i = 0; i < fourValuesList.count; i++){
        // 転換線の計算
        if(i >= shortTerm - 1){
            // 処理データ数が期間(短期)を満たす場合
            
            NSDecimalNumber* maxPrice = ((OhlcBean *)fourValuesList[i]).highPrice;
            NSDecimalNumber* minPrice = ((OhlcBean *)fourValuesList[i]).lowPrice;
            
            // 期間内(短期)の最高・最安を取得
            for (int j = 0; j < shortTerm; j++) {
                NSDecimalNumber* highPrice = ((OhlcBean *)fourValuesList[i - j]).highPrice;
                NSDecimalNumber* lowPrice = ((OhlcBean *)fourValuesList[i - j]).lowPrice;
                
                //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
                if([maxPrice compare:highPrice] == NSOrderedAscending){
                    maxPrice = highPrice;
                }
                if([minPrice compare:lowPrice] == NSOrderedDescending){
                    minPrice = lowPrice;
                }
                
            }
            
            conversionLine[i] = [[maxPrice decimalNumberByAdding:minPrice] decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(2) withBehavior:ROUNDING_BEHAVIOR_5];
        }
        
        // 基準線の計算
        if (i >= middleTerm - 1) {
            // 処理データ数が期間(中期)を満たす場合
            
            NSDecimalNumber* maxPrice = ((OhlcBean *)fourValuesList[i]).highPrice;
            NSDecimalNumber* minPrice = ((OhlcBean *)fourValuesList[i]).lowPrice;
            
            // 期間内(中期)の最高・最安を取得
            for (int j = 0; j < middleTerm; j++) {
                NSDecimalNumber* highPrice = ((OhlcBean *)fourValuesList[i - j]).highPrice;
                NSDecimalNumber* lowPrice = ((OhlcBean *)fourValuesList[i - j]).lowPrice;
                
                if( [maxPrice compare:highPrice] == NSOrderedAscending){
                    maxPrice = highPrice;
                }
                if( [minPrice compare:lowPrice] == NSOrderedDescending){
                    minPrice = lowPrice;
                }
                
            }
            
            baseLine[i] = [[maxPrice decimalNumberByAdding:minPrice] decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(2) withBehavior:ROUNDING_BEHAVIOR_5];
        }
        
        // 先行スパン２の計算
        if (i >= longTerm - 1) {
            // 処理データ数が期間(長期)を満たす場合
            
            NSDecimalNumber* maxPrice = ((OhlcBean *)fourValuesList[i]).highPrice;
            NSDecimalNumber* minPrice = ((OhlcBean *)fourValuesList[i]).lowPrice;
            
            // 期間内(長期)の最高・最安を取得
            for (int j = 0; j < longTerm; j++) {
                
                NSDecimalNumber* highPrice = ((OhlcBean *)fourValuesList[i - j]).highPrice;
                NSDecimalNumber* lowPrice = ((OhlcBean *)fourValuesList[i - j]).lowPrice;
                
                if([maxPrice compare: highPrice] == NSOrderedAscending) {
                    maxPrice = highPrice;
                }
                if([minPrice compare:lowPrice] == NSOrderedDescending) {
                    minPrice = lowPrice;
                }
                
            }
            
            leadingSpan2[i + LEADING_SPAN_TERM - 1] = [[maxPrice decimalNumberByAdding:minPrice] decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(2)  withBehavior:ROUNDING_BEHAVIOR_5];
            
        }
        
        // 先行スパン１の計算
        if ( conversionLine[i] != nil && baseLine[i] != nil) {
            leadingSpan1[i + LEADING_SPAN_TERM - 1] = [[conversionLine[i] decimalNumberByAdding:baseLine[i]] decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(2) withBehavior:ROUNDING_BEHAVIOR_5];
            
        }
        
        // 遅行線の計算(26日前に終値設定)
        if (conversionLine[i] != nil && baseLine[i] != nil && longTerm <= i && LEADING_SPAN_TERM <= i) {
            laggingLine[i - LEADING_SPAN_TERM] = ((OhlcBean *)fourValuesList[i]).closePrice;
        }
        
        // 返却データの整形
        NSMutableArray *returnDatas = [[NSMutableArray alloc] initWithCapacity:5];
        
        
        // 転換線
        if (conversionLine[i] != nil && longTerm - 1 <= i) {
            [returnDatas addObject:[((NSDecimalNumber *)conversionLine[i]) decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2]];
            
        } else {
            [returnDatas addObject:[NSNull null]];
        }
        
        // 基準線
        if (baseLine[i] != nil && longTerm - 1 <= i) {
            [returnDatas addObject: [((NSDecimalNumber *)baseLine[i]) decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ]];
            
        } else {
            [returnDatas addObject:[NSNull null]];
            
        }
        
        // 遅行線を退避
        if (longTerm <= i + LEADING_SPAN_TERM && i + LEADING_SPAN_TERM <= fourValuesList.count ) {
            laggingLine[i] = ((OhlcBean *)fourValuesList[i + LEADING_SPAN_TERM - 1]).closePrice;
            [returnDatas addObject:[((NSDecimalNumber *)laggingLine[i]) decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ] ];
        } else {
            [returnDatas addObject:[NSNull null]];
            
        }
        
        // 先行スパン１・２
        if (leadingSpan1[i] != nil && leadingSpan2[i] != nil && longTerm - 1 <= i) {
            [returnDatas addObject:[((NSDecimalNumber *)leadingSpan1[i]) decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ] ];
            [returnDatas addObject:[((NSDecimalNumber *)leadingSpan2[i]) decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ] ];
        } else {
            [returnDatas addObject:[NSNull null]];
            [returnDatas addObject:[NSNull null]];
        }
        
        [returnList addObject:returnDatas];
        
    }
    
    // 先行スパンの格納
    for (NSInteger i = fourValuesList.count; i < fourValuesList.count - 1 + LEADING_SPAN_TERM; i++) {
        
        NSMutableArray *returnDatas = [[NSMutableArray alloc]initWithCapacity:5];
        
        // 転換線
        [returnDatas addObject:[NSNull null]];
        // 基準線
        [returnDatas addObject:[NSNull null]];
        // 遅行線
        [returnDatas addObject:[NSNull null]];
        
        // 先行スパン１
        if ( leadingSpan1[i] != nil) {
            [returnDatas addObject:[ leadingSpan1[i] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ]];
        } else {
            [returnDatas addObject:[NSNull null]];
        }
        
        // 先行スパン２
        if ( leadingSpan2[i] != nil) {
            [returnDatas addObject:[ leadingSpan2[i] decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2 ]];
            
        } else {
            [returnDatas addObject:[NSNull null]];
        }
        [returnList addObject:returnDatas];
    }
    
    return [returnList copy];
}

/**
 * RSI計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * moveAvgTerm    移動平均化日数
 * fourValuesList 四本値を格納したリスト
 * プロットデータを格納したリストを返却する
 */
+ (NSArray *)caluculateRSI: (int) moveAvgTerm beanArray: (NSArray *) fourValuesList{
    // 0での除算回避のため日数・指定された売買％の日数チェック
    if (moveAvgTerm == 0) {
        return nil;
    }
    
    // ４本値データの存在チェック
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    // 終値の退避領域作成
    NSDecimalNumber *closePrice[fourValuesList.count];
    
    // 終値の上がり幅退避領域作成
    NSDecimalNumber *risePriceWidth[fourValuesList.count];
    
    // 終値の下がり幅退避領域作成
    NSDecimalNumber *fallPriceWidth[fourValuesList.count];
    
    // 終値の上がり幅「平均」退避領域作成
    NSDecimalNumber *risePriceWidthAverage[fourValuesList.count];
    
    // 終値の下がり幅「平均」退避領域作成
    NSDecimalNumber *fallPriceWidthAverage[fourValuesList.count];
    
    // 期間内 終値 上がり幅の合計 変数
    NSDecimalNumber *risePriceSum = [NSDecimalNumber zero];
    
    // 期間内 終値 下がり幅の合計 変数
    NSDecimalNumber *fallPriceSum = [NSDecimalNumber zero];
    
    // 移動平均化日数より計算用の変数設定（移動平均化日数は当日を含めた日数）
    // 過去期間
    NSDecimalNumber *pastTerm = DECIMALNUMBER_INTNUM(moveAvgTerm - 1);
    
    // 平均化する期間
    NSDecimalNumber *averageTerm = DECIMALNUMBER_INTNUM(moveAvgTerm);
    
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:fourValuesList.count];
    
    
    for (int i = 0; i < fourValuesList.count; i++) {
        
        // 取得した終値の退避
        closePrice[i] = ((OhlcBean *)fourValuesList[i]).closePrice;
        
        // 終値の前日比を求めるため１件目は比較対象がないためスキップ
        if (i == 0) {
            [returnList addObject:[NSNull null]];
            continue;
        }
        
        // 前日比の計算、前日終値と比較し上がり幅・下がり幅とその合計を退避する
        if ([closePrice[i] compare: closePrice[i - 1]] == NSOrderedSame || [closePrice[i] compare: closePrice[i - 1]] == NSOrderedDescending ) {
            risePriceWidth[i] = [closePrice[i] decimalNumberBySubtracting: closePrice[i - 1]];
            fallPriceWidth[i] = [NSDecimalNumber zero];
            risePriceSum = [risePriceSum decimalNumberByAdding:risePriceWidth[i]];
            
        } else {
            risePriceWidth[i] = [NSDecimalNumber zero];
            fallPriceWidth[i] = [closePrice[i-1] decimalNumberBySubtracting:closePrice[i]];
            fallPriceSum = [fallPriceSum decimalNumberByAdding:fallPriceWidth[i]];
        }
        
        // 上がり幅・下がり幅の平均計算
        // ※初回は「前回の平均」がないため、期間内の上がり幅の合計を移動化平均日数で割ることで計算する
        if (i == moveAvgTerm) {
            // 平均化計算（期間内の上がりor下がり幅合計）÷期間
            risePriceWidthAverage[i] = [risePriceSum decimalNumberByDividingBy:averageTerm withBehavior:ROUNDING_BEHAVIOR_5];
            fallPriceWidthAverage[i] = [fallPriceSum decimalNumberByDividingBy:averageTerm withBehavior:ROUNDING_BEHAVIOR_5];
        }
        
        // ２回目以降は前回計算された終値上がり幅・下がり幅の平均を使用して計算を行う
        if (i > moveAvgTerm) {
            // 平均化計算（過去の平均×過去期間＋当日上がりor下がり幅）÷（移動化日数）
            // 上がり幅
            NSDecimalNumber *caluculateWork1 = [[risePriceWidthAverage[i-1] decimalNumberByMultiplyingBy:pastTerm] decimalNumberByAdding:risePriceWidth[i]];
            risePriceWidthAverage[i] = [caluculateWork1 decimalNumberByDividingBy:averageTerm withBehavior:ROUNDING_BEHAVIOR_5];
            
            // 下がり幅
            NSDecimalNumber *caluculateWork2 = [[fallPriceWidthAverage[i-1] decimalNumberByMultiplyingBy:pastTerm] decimalNumberByAdding:fallPriceWidth[i]];
            fallPriceWidthAverage[i] = [caluculateWork2 decimalNumberByDividingBy:averageTerm withBehavior:ROUNDING_BEHAVIOR_5];
        }
        
        // 返却データの整形
        if (i >= moveAvgTerm) {
            // 上がり幅・下がり幅からRSI値の計算
            NSDecimalNumber *caluculateWork3 = [risePriceWidthAverage[i] decimalNumberByAdding:fallPriceWidthAverage[i]];
            NSDecimalNumber *caluculateWork4 = [risePriceWidthAverage[i] decimalNumberByDividingBy:caluculateWork3 withBehavior: ROUNDING_BEHAVIOR_5];
            NSDecimalNumber *rsiValue = [caluculateWork4 decimalNumberByMultiplyingBy: DECIMALNUMBER_INTNUM( 100 )];
            [returnList addObject:[rsiValue decimalNumberByRoundingAccordingToBehavior:ROUNDING_BEHAVIOR_2]];
        }
        else{
            [returnList addObject:[NSNull null]];
        }
    }
    
    
    return [returnList copy];
    
}

/**
 * MACD計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * shortEMA       短期EMA
 * longEMA        長期EMA
 * signal         シグナル
 * fourValuesList 四本値を格納したリスト
 * プロットデータを格納したリストを返却する
 * [0]MACD [1]シグナル [2]OSCI
 */
+ (NSArray *)caluculateMACDshortEMA: (int) shortEMA longEMA:(int) longEMA signal: (int) signal beanArray: (NSArray *) fourValuesList{
    
    // 0除算回避の引数チェック
    if (shortEMA == 0) {
        return nil;
    }
    
    if (longEMA == 0) {
        return nil;
    }
    
    if (signal == 0) {
        return nil;
    }
    
    // ４本値データの存在チェック
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    // 短期EMA・長期EMAの退避領域作成
    NSDecimalNumber *shortEma[fourValuesList.count];
    NSDecimalNumber *longEma[fourValuesList.count];
    
    // MACDの退避領域作成
    NSDecimalNumber *macd[fourValuesList.count];
    
    // MACDシグナルの退避領域作成
    NSDecimalNumber *macdSignal[fourValuesList.count];
    
    // OSCIの退避領域作成
    NSDecimalNumber *osci[fourValuesList.count];
    
    // 短期・長期EMA計算用 work 変数
    
    // 終値退避領域
    NSDecimalNumber *closePriceWork;
    
    // 短期EMA計算で使用する除算値退避領域
    NSDecimalNumber * shortEmaDivide;
    
    // 長期EMA計算で使用する除算値退避領域
    NSDecimalNumber * longEmaDivide;
    
    // MACDシグナル計算で使用する除算値退避領域
    NSDecimalNumber * moveAvgDivide;
    
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:fourValuesList.count];
    
    
    // メイン処理
    for (int i = 0; i < fourValuesList.count; i++) {
        
        // 当日終値を退避
        closePriceWork = ((OhlcBean *)fourValuesList[i]).closePrice;
        
        // データ初日分は演算でなく初期値設定
        if (i == 0) {
            shortEma[i] = closePriceWork;
            longEma[i] = closePriceWork;
            macd[i] = [NSDecimalNumber zero];
            macdSignal[i] = [NSDecimalNumber zero];
            osci[i] = [NSDecimalNumber zero];
            
            NSMutableArray *returnDatas = [[NSMutableArray alloc] initWithCapacity: 3];
            returnDatas[0] = [macd[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            returnDatas[1] = [macdSignal[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            returnDatas[2] = [osci[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            
            [returnList addObject: returnDatas ];
            
        } else {
            // ２日目以降は演算により値設定
            // 短期EMA用除算変数設定
            // index i を除算する変数に流用しているため＋２しないと除算の値とならない
            // ※ｎ＋１を表現するため i +1 +1 で記述する
            if (i < shortEMA) {
                shortEmaDivide = DECIMALNUMBER_INTNUM(i + 1 + 1);
            } else {
                shortEmaDivide = DECIMALNUMBER_INTNUM(shortEMA +1);
            }
            
            // 長期EMA用除算変数設定
            if (i < longEMA) {
                longEmaDivide = DECIMALNUMBER_INTNUM(i + 1 + 1);
            } else {
                longEmaDivide = DECIMALNUMBER_INTNUM(longEMA + 1);
            }
            
            // 移動平均用除算変数設定
            if (i < signal) {
                moveAvgDivide = DECIMALNUMBER_INTNUM(i + 1 + 1);
            } else {
                moveAvgDivide = DECIMALNUMBER_INTNUM(signal + 1);
            }
            
            // 短期EMA計算その１
            // （当日終値 － 前日の指数平滑移動平均）×２
            NSDecimalNumber *caluculateWork1 = [[closePriceWork decimalNumberBySubtracting:shortEma[i - 1]] decimalNumberByMultiplyingBy:DECIMALNUMBER_INTNUM(2)];
            
            // 短期EMA計算その２
            // （当日終値 － 前日の指数平滑移動平均）×２÷（ｎ＋１）
            NSDecimalNumber *caluculateWork2 = [caluculateWork1 decimalNumberByDividingBy:shortEmaDivide withBehavior:ROUNDING_BEHAVIOR_5];
            
            // 短期EMA計算その３
            // 前日の指数平滑移動平均 ＋（当日終値 － 前日の指数平滑移動平均）×２÷（ｎ＋１）
            shortEma[i] = [shortEma[i - 1] decimalNumberByAdding: caluculateWork2];
            
            // 長期EMA計算その１
            // （当日終値 － 前日の指数平滑移動平均）×２
            NSDecimalNumber *caluculateWork3 = [[closePriceWork decimalNumberBySubtracting:longEma[i - 1]] decimalNumberByMultiplyingBy:DECIMALNUMBER_INTNUM(2)];
            
            // 長期EMA計算その２
            // （当日終値 － 前日の指数平滑移動平均）×２÷（ｎ＋１）
            NSDecimalNumber *caluculateWork4 = [caluculateWork3 decimalNumberByDividingBy:longEmaDivide withBehavior:ROUNDING_BEHAVIOR_5];
            
            // 長期EMA計算その３
            // 前日の指数平滑移動平均 ＋（当日終値 － 前日の指数平滑移動平均）×２÷（ｎ＋１）
            longEma[i] = [longEma[i - 1] decimalNumberByAdding: caluculateWork4 ];
            
            // MACDを短期・長期から計算
            macd[i] = [shortEma[i] decimalNumberBySubtracting: longEma[i] ];
            
            // MACDシングル計算その１
            // （当日MACD － 前日のMACDシグナル）×２
            NSDecimalNumber *caluculateWork5 = [[macd[i] decimalNumberBySubtracting:macdSignal[i - 1]] decimalNumberByMultiplyingBy:DECIMALNUMBER_INTNUM(2)];
            
            // MACDシングル計算その２
            // （当日MACD － 前日のMACDシグナル）×２÷（ｎ＋１）
            NSDecimalNumber *caluculateWork6 = [caluculateWork5 decimalNumberByDividingBy:moveAvgDivide withBehavior:ROUNDING_BEHAVIOR_5];
            
            // MACDシングル計算その３
            // 前日のMACDシグナル ＋（当日MACD － 前日のMACDシグナル）×２÷（ｎ＋１）
            macdSignal[i] = [macdSignal[i - 1] decimalNumberByAdding: caluculateWork6];
            
            // OSCIをMACD・MACDシングルから計算
            osci[i] = [macd[i] decimalNumberBySubtracting: macdSignal[i]];
            
            // 返却データの整形
            NSMutableArray *returnDatas = [[NSMutableArray alloc] initWithCapacity: 3];
            returnDatas[0] = [macd[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            returnDatas[1] = [macdSignal[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            returnDatas[2] = [osci[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            
            [returnList addObject:returnDatas];
        }
    }
    
    
    return [returnList copy];
}

/**
 * スローストキャス計算処理
 * <p>
 * 計算が成立しない場合(パラメータ不正)は<NULL>を返却する
 *
 * highLowJudgeTerm 高安周期
 * moveAvgTerm      移動平均化日数
 * fourValuesList   四本値を格納したリスト
 * プロットデータを格納したリストを返却する
 * [0]Slow %D [1]Slow %K
 */
+ (NSArray *)calculateSlowStcstcsJudgeTerm:(int) highLowJudgeTerm avgTerm:(int) moveAvgTerm beanArray: (NSArray *)fourValuesList{
    // 0での除算回避のため最高値・最安値判定期間チェック
    if (highLowJudgeTerm == 0) {
        return nil;
    }
    
    // 0での除算回避のため移動平均化日数チェック
    if (moveAvgTerm == 0) {
        return nil;
    }
    
    // ４本値データの存在チェック
    if (fourValuesList == nil || fourValuesList.count == 0) {
        return nil;
    }
    
    // ４本値終値退避領域作成
    NSDecimalNumber *closePrice[fourValuesList.count];
    
    // 計算：終値－最安値 退避領域作成
    NSDecimalNumber *closeMinDiff[fourValuesList.count];
    
    // 計算：最高値－最安値 退避領域作成
    NSDecimalNumber *maxMinDiff[fourValuesList.count];
    
    // %K 退避領域作成
    NSDecimalNumber *percentK[fourValuesList.count];
    
    // Slow%K 退避領域作成
    NSDecimalNumber *slowPercentK[fourValuesList.count];
    
    // Slow%D 退避領域作成
    NSDecimalNumber *slowPercentD[fourValuesList.count];
    
    // %K 合算値 退避領域作成
    NSDecimalNumber * percentKsum;
    
    // Slow%K 合算値 退避領域作成
    NSDecimalNumber * slowPercentKsum = [NSDecimalNumber zero];
    
    // 高値・安値を検索するための遡り日数を退避する work 変数
    int goBackCount;
    
    // Slow%K 計算開始 を表す work 変数
    // ※ List読み込み時のindex開始(i=0)を考慮して -2 する
    int slowPercentKstart = highLowJudgeTerm + moveAvgTerm - 2;
    
    // Slow%D 計算開始 を表す work 変数
    // ※ List読み込み時のindex開始(i=0)を考慮して -3 する
    int slowPercentDstart = highLowJudgeTerm + moveAvgTerm + moveAvgTerm - 3;
    
    // 返却用リスト
    NSMutableArray *returnList = [[NSMutableArray alloc]initWithCapacity:fourValuesList.count];
    
    
    // メイン処理
    for (int i = 0; i < fourValuesList.count; i++) {
        
        // 取得した終値の退避
        closePrice[i] = ((OhlcBean *)fourValuesList[i]).closePrice;
        
        // 高値・安値を検索するための遡り日数を設定
        if (i < highLowJudgeTerm) {
            goBackCount = i + 1;
        } else {
            goBackCount = highLowJudgeTerm;
        }
        
        // 高値・安値の取得
        NSDecimalNumber *priceMax = ((OhlcBean *)fourValuesList[i]).highPrice;
        NSDecimalNumber *priceMin = ((OhlcBean *)fourValuesList[i]).lowPrice;
        NSDecimalNumber *priceMaxBefore;
        NSDecimalNumber *priceMinBefore;
        
        // パラメータの「判定期間」分だけ高値・安値を繰り返し取得、最高値・最安値を判定する
        // ※初期 = 1 スタート
        for (int j = 1; j < goBackCount; j++) {
            priceMaxBefore = ((OhlcBean *)fourValuesList[i - j]).highPrice;
            priceMinBefore = ((OhlcBean *)fourValuesList[i - j]).lowPrice;
            
            if ([priceMax compare: priceMaxBefore] == NSOrderedAscending) {
                priceMax = priceMaxBefore;
            }
            if ([priceMin compare: priceMinBefore] == NSOrderedDescending) {
                priceMin = priceMinBefore;
            }
            
        }
        
        // 確定した最高値・最安値から以下の２点を計算し退避する
        // （当日終値 － 過去ｎ日間の最安値）
        // （過去ｎ日間の最高値 － 過去ｎ日間の最安値）
        closeMinDiff[i] = [closePrice[i] decimalNumberBySubtracting:priceMin];
        maxMinDiff[i] = [priceMax decimalNumberBySubtracting:priceMin];
        
        // %K の計算と格納
        if ( [[NSDecimalNumber zero] compare: maxMinDiff[i]] != NSOrderedSame) {
            NSDecimalNumber *caluculateWork1 = [closeMinDiff[i] decimalNumberByDividingBy:maxMinDiff[i] withBehavior:ROUNDING_BEHAVIOR_5];
            percentK[i] = [caluculateWork1 decimalNumberByMultiplyingBy: DECIMALNUMBER_INTNUM( 100 ) ];
        } else {
            percentK[i] = [NSDecimalNumber zero];
        }
        
        // Slow%K の計算
        // Slow%K は 移動平均化するため「判定期間」で正しく計算されたデータが「移動平均化日数」分必要となる
        // よって「判定期間」＋「移動平均化日数」分読み込みされた時点で Slow%K が計算される
        if (i == slowPercentKstart) {
            slowPercentK[i] = [percentK[i] decimalNumberByAdding: slowPercentK[i - 1] ];
            slowPercentKsum = [[slowPercentKsum decimalNumberByAdding: slowPercentK[i] ] decimalNumberBySubtracting: slowPercentK[i - moveAvgTerm] ];
        } else if (i > slowPercentKstart) {
            NSDecimalNumber *caluculateWork2 = [percentK[i] decimalNumberByAdding: slowPercentK[i - 1] ];
            slowPercentK[i] = [caluculateWork2 decimalNumberByDividingBy: DECIMALNUMBER_INTNUM(2) withBehavior:ROUNDING_BEHAVIOR_5 ];
            slowPercentKsum = [[slowPercentKsum decimalNumberByAdding: slowPercentK[i] ] decimalNumberBySubtracting: slowPercentK[i - moveAvgTerm] ];
        } else {
            slowPercentK[i] = [NSDecimalNumber zero ];
            if (i < highLowJudgeTerm - 1) {
                percentK[i] = [NSDecimalNumber zero ];
            }
        }
        
        // Slow%D の計算
        // Slow%D は Slow%K を移動平均化するため、Slow%K が正しく計算されたデータが「移動平均化日数」分必要となる
        // Slow%K の計算が開始され、なおかつ Slow%Kが「移動平均化日数」分計算された時点で Slow%D が計算される
        // Slow%Kと同期をとり結果出力する必要があり、移動平均化する際に足りない情報は %K を代用して計算する
        if (i >= slowPercentKstart) {
            
            // Slow%K が正常に計算されている場合（「判定期間」＋「移動平均化日数」＋「移動平均化日数」）
            if (i >= slowPercentDstart) {
                slowPercentD[i] = [slowPercentKsum decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(moveAvgTerm) withBehavior:ROUNDING_BEHAVIOR_5];
                
                // Slow%K が移動平均化日数に足りない場合
            } else {
                // 当日計算された Slow%K + 代用 %K の合算を行う
                // ※初期 = 1 スタート
                percentKsum = [NSDecimalNumber zero];
                for (int j = 1; j < moveAvgTerm; j++) {
                    percentKsum = [percentKsum decimalNumberByAdding: percentK[i - j]];
                }
                percentKsum = [percentKsum decimalNumberByAdding: slowPercentK[i]] ;
                slowPercentD[i] = [percentKsum decimalNumberByDividingBy:DECIMALNUMBER_INTNUM(moveAvgTerm) withBehavior:ROUNDING_BEHAVIOR_5 ];
            }
        } else {
            slowPercentD[i] = [NSDecimalNumber zero];
        }
        // 返却データの整形
        NSMutableArray *returnDatas = [[NSMutableArray alloc]initWithCapacity:2];
        
        if (i >= slowPercentKstart) {
            // slow %D
            returnDatas[0] = [slowPercentD[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2 ];
            // slow %K
            returnDatas[1] = [slowPercentK[i] decimalNumberByRoundingAccordingToBehavior: ROUNDING_BEHAVIOR_2] ;
            
        }
        
        [returnList addObject:returnDatas];
    }
    
    return [returnList copy];
    
}

@end
