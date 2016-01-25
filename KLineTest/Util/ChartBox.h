#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** 枠線の太さ */
#define LINEWIDTH_WAKU 1.0f
/** 株価表示線の幅 */
#define LINEWIDTH_DIVIDE 0.5f
/* 先行日数(先行スパン/一目均衡表) */
#define LEADING_SPAN_TERM 26

//#define PORTRAIT_CHART_WIDTH 270 // (5 + 1) * 45 = 270 62
//#define PORTRAIT_CHART_MAIN_HEIGHT 270
//#define PORTRAIT_CHART_SUB_HEIGHT 90
//#define PORTRAIT_CHART_MAIN_OFFSET 15
//#define PORTRAIT_CHART_SUB_OFFSET 12
//#define CHART_Y_OFFSET 70.0f
//#define PORTRAIT_CHART_MAIN_YPOSITION(maxPrice,minPrice,nowPrice) (1 - (nowPrice - floorf(minPrice) ) / ( ceilf( maxPrice) - floorf( minPrice) )) * (PORTRAIT_CHART_MAIN_HEIGHT - PORTRAIT_CHART_MAIN_OFFSET * 2) + PORTRAIT_CHART_MAIN_OFFSET
//#define PORTRAIT_CHART_MAIN_YPOSITION(maxPrice,minPrice,nowPrice) (1 - (nowPrice-minPrice) / (maxPrice-minPrice)) * (PORTRAIT_CHART_MAIN_HEIGHT - PORTRAIT_CHART_MAIN_OFFSET * 2) + PORTRAIT_CHART_MAIN_OFFSET
//#define CHART_MAIN_YPERCENT(nowPrice,minPrice,maxPrice) (1 - (nowPrice - minPrice) / (maxPrice - minPrice))


//#define PORTRAIT_CHART_SUB_YPOSITION(maxVol,nowVol) (1 - nowVol / maxVol ) * (PORTRAIT_CHART_SUB_HEIGHT - PORTRAIT_CHART_SUB_OFFSET * 2) + PORTRAIT_CHART_SUB_OFFSET

//#define CHART_SUB_YPOSITION(maxVol,nowVol) (1 - nowVol / maxVol )

/** ローソク足の表示本数 */
#define CANDLE_STICK_COUNT 63// 70//45


//詳細チャート
#define CANDLESTICK_COUNT_ALL 400
//#define LAND_CHART_WIDTH 504  // (5 + 1) * 84 = 504
//#define LAND_CHART_HEIGHT 260
//#define LAND_CHART_MAIN_HEIGHT 200
//#define LAND_CHART_MAIN_OFFSET 20
//#define LAND_CHART_DATESCALE_OFFSET 12
//#define LAND_CHART_MAIN_YPOSITION(maxPrice,minPrice,nowPrice,viewHeight) (1 - (nowPrice-minPrice) / (maxPrice-minPrice)) * (viewHeight - LAND_CHART_MAIN_OFFSET * 2) + LAND_CHART_MAIN_OFFSET

#define RATE_IN_RANGE(nowPrice,minPrice,maxPrice) (1 - (nowPrice - minPrice) / (maxPrice - minPrice))
#define RATE_WITH_NUMBER(nowVol,maxVol) (1 - nowVol / maxVol )
#define NOW_STOCK_VALUE(yPos,maxPrice,minPrice,viewHeight) (1 - (yPos-LAND_CHART_MAIN_OFFSET) / (viewHeight-LAND_CHART_MAIN_OFFSET * 2)) * (maxPrice - minPrice) + minPrice

//#define NOWVALUE_BY_YPOSITION(yPos,maxPrice,minPrice,viewHeight) (1 - yPos / viewHeight) * (maxPrice - minPrice) + minPrice
#define NOWVALUE_BY_YPOSITION1(yPos,maxPrice,minPrice,viewHeight) (1- (yPos - Y_BEGIN_POINT(viewHeight)) / VALID_HEIGHT_MAIN(viewHeight))  * (maxPrice - minPrice) + minPrice
//#define LAND_CHART_SUB_YPOSITION(maxVol,nowVol) (1 - nowVol / maxVol ) * (LAND_CHART_HEIGHT - LAND_CHART_MAIN_HEIGHT - LAND_CHART_DATESCALE_OFFSET * 2) + LAND_CHART_DATESCALE_OFFSET

#define VALID_HEIGHT_MAIN(height) (height - height*0.08*2)
#define Y_BEGIN_POINT(height) height*0.08


//#define CANDLESTICK_WIDTH 5     //ローソクの幅
//#define CANDLESTICK_INTERVAL 1  //ローソクの間隔

#define COLOR_CANDLESTICK_RISE 255/255.0f,0/255.0f,0/255.0f //陽線の色
#define COLOR_CANDLESTICK_FALL 0/255.0f,0/255.0f,255/255.0f //陰線の色
#define COLOR_DIVIDE_LINE 105/255.0f,105/255.0f,105/255.0f //間隔線
#define COLOR_MY_YELLOW 0/255.0f,255/255.0f,0/255.0f  //#00FF00
//#define COLOR_MOVING_AVERAGE_LINE_2_BLACKBACK 255/255.0f,255/255.0f,0/255.0f  //#FFFF00
//#define COLOR_MOVING_AVERAGE_LINE_2           255/255.0f,153/255.0f,0/255.0f  //#FFFF00 Orange

//#define COLOR_YAXIS_BLACKBACK 255/255.f, 255/255.f, 255/255.f //白
#define COLOR_YAXIS 0/255.f, 0/255.f, 0/255.f //黒
//#define BACKGROUND_COLOR_IN_USERDEFAULTS [[NSUserDefaults standardUserDefaults] integerForKey:@"Background_Color"]

//#define FONT_ATTRIBUTE_GREEN @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:10], NSForegroundColorAttributeName:[UIColor greenColor]}
//#define FONT_ATTRIBUTE_YELLOW @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:10], NSForegroundColorAttributeName:[UIColor yellowColor]}
//#define FONT_ATTRIBUTE_ORANGE @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:10], NSForegroundColorAttributeName:[UIColor orangeColor]}
//#define FONT_ATTRIBUTE_WHITE(fontsize) @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fontsize], NSForegroundColorAttributeName:[UIColor whiteColor]}
#define FONT_ATTRIBUTE_BLACK(fontsize) @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fontsize], NSForegroundColorAttributeName:[UIColor blackColor]}
//#define FONT_ATTRIBUTE(fontsize) BACKGROUND_COLOR_IN_USERDEFAULTS == 0 ? FONT_ATTRIBUTE_WHITE(fontsize) : FONT_ATTRIBUTE_BLACK(fontsize)

#define FONT_ATTRIBUTE(fontsize) FONT_ATTRIBUTE_BLACK(fontsize)

#define COLOR_WITH_RGB(r,g,b) r/255.0f,g/255.0f,b/255.0f
//#define FONT_WITH_ATTRIBUTE(fontsize,fontcolor) @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fontsize], NSForegroundColorAttributeName:fontcolor}

#define FONTATTRIBUTE_WITH_RGB_SIZE(r,g,b,fsize) @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fsize], NSForegroundColorAttributeName:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]}

#define DECIMALNUMBER_INTNUM(num) [[NSDecimalNumber alloc]initWithInt: num]
#define ROUNDING_BEHAVIOR_5 [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:5 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]
#define ROUNDING_BEHAVIOR_2 [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]


@interface ChartBox : NSObject

/** 移動平均線・短期の描画色 */
extern float const MOVAVG_SHORT_COLOR[];
/** 移動平均線・中期の描画色 */
extern float const MOVAVG_MEDIUM_COLOR[];
/** 移動平均線・長期の描画色 */
extern float const MOVAVG_LONG_COLOR[];
/** ボリンジャー・移動平均の描画色 */
extern float const BOLLINGER_MOVE_AVG_COLOR[];
/** ボリンジャー・TOP1の描画色 */
extern float const BOLLINGER_TOP1_COLOR[];
/** ボリンジャー・LOW1の描画色 */
extern float const BOLLINGER_LOW1_COLOR[];
/** ボリンジャー・TOP2の描画色 */
extern float const BOLLINGER_TOP2_COLOR[];
/** ボリンジャー・LOW2の描画色 */
extern float const BOLLINGER_LOW2_COLOR[];
/** 一目均衡表・転換線の描画色 */
extern float const ITIMOKU_CONVERSION_COLOR[];
/** 一目均衡表・基準線の描画色 */
extern float const ITIMOKU_BASE_COLOR[];
/** 一目均衡表・遅行線の描画色 */
extern float const ITIMOKU_LAGGING_COLOR[];
/** 一目均衡表・先行スパン1の描画色 */
extern float const ITIMOKU_LEADING_SPAN1_COLOR[];
/** 一目均衡表・先行スパン2の描画色 */
extern float const ITIMOKU_LEADING_SPAN2_COLOR[];
/** 一目均衡表・雲上の描画色 */
extern float const ITIMOKU_CLOUD1_COLOR[];
/** 一目均衡表・雲下の描画色 */
extern float const ITIMOKU_CLOUD2_COLOR[];
/** RSIの描画色 */
extern float const RSI_COLOR[];
/** RSI基準線の描画色 */
extern float const RSI_BASE_COLOR[];
/** RSI買われすぎの描画色 */
extern float const RSI_OVER_BUY_COLOR[];
/** RSI売られすぎの描画色 */
extern float const RSI_OVER_SELL_COLOR[];
/** MACDの描画色 */
extern float const MACD_COLOR[];
/** MACD・シグナルの描画色 */
extern float const MACD_SIGNAL_COLOR[];
/** MACD・OSCI(明)の描画色 */
extern float const MACD_OSCI_LIGHT_COLOR[];
/** MACD・OSCI(暗)の描画色 */
extern float const MACD_OSCI_DARK_COLOR[];
/** Sストキャス・Slow%Dの描画色 */
extern float const STOCHAS_SLOW_PER_D_COLOR[];
/** Sストキャス・Slow%Kの描画色 */
extern float const STOCHAS_SLOW_PER_K_COLOR[];
/** Sストキャス・買われすぎの描画色 */
extern float const STOCHAS_OVER_BUY_COLOR[];
/** Sストキャス・売られすぎの描画色 */
extern float const STOCHAS_OVER_SELL_COLOR[];


+ (ChartBox *)sharedInstance;

//テクニカル指標の名称Array
@property (strong, nonatomic) NSArray *technicalNameArray;
//名称Array
@property (strong, nonatomic) NSArray *mainTechnicalNameArray;
//名称Array
@property (strong, nonatomic) NSArray *subTechnicalNameArray;
//名称Array
@property (strong, nonatomic) NSArray *subviewNameArray;
//名称Array
@property(nonatomic, strong) NSArray *indexNameArray;
//足種名称Array
@property (strong, nonatomic) NSArray *ashiNameArray;
//テクニカル指標の初期値
@property (strong, nonatomic) NSDictionary *technicalDefaultValueDic;
//テクニカル指標の設定値
@property (strong, nonatomic) NSDictionary *technicalValueDic;

@property(nonatomic, strong) NSArray *tsukiArray;


@property(nonatomic, copy) NSArray *ma_labelTextArray;
@property(nonatomic, copy) NSArray *bollinger_labelTextArray;
@property(nonatomic, copy) NSArray *itimoku_labelTextArray;
@property(nonatomic, copy) NSArray *rsi_labelTextArray;
@property(nonatomic, copy) NSArray *macd_labelTextArray;
@property(nonatomic, copy) NSArray *stochas_labelTextArray;

@property (strong, nonatomic) NSMutableArray *ymdMutableArray;

- (BOOL)isMonthHead :(NSString *)date;


//+(NSDate*)dateFromString:(NSString*)str;
//+(NSDateComponents*)dateComponentsWithDate:(NSDate*)date;
//+(bool)isEqualWithFloat:(float)f1 float2:(float)f2 absDelta:(int)absDelta;
+(NSObject *) getUserDefaults:(NSString *) name;
+(void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key;
+ (NSString *)md5HexDigest:(NSString*)password;

//+ (NSString*)addUnitToPrice:(CGFloat)price;

+ (NSArray *)getPricesByHighPrice : (CGFloat)high lowPrice: (CGFloat)low;

+ (CGFloat)getTheClosestNumber: (CGFloat)f;

+ (CGFloat)getTheClosestVolume:(CGFloat)vol;

+ (CGFloat)getClosetHalfNumber: (CGFloat)f;

+ (CGFloat)getBottomBoundValue:(CGFloat)valPrice;

+ (CGFloat)getUpperBoundValue:(CGFloat)valPrice;

+ (CGFloat)getClosestEvenNumber: (CGFloat)f;

+(void)DrawLine:(CGRect)frame addView:(UIView *)view;



#pragma mark - チャート描画用データ

@property (strong, nonatomic) NSMutableArray *ohlcMutableArray;

//移動平均
@property (strong, nonatomic) NSArray *maShortArray;
@property (strong, nonatomic) NSArray *maMediumArray;
@property (strong, nonatomic) NSArray *maLongArray;
//ボリンジャー
@property (strong, nonatomic) NSArray *bollingerInfoArray;
//一目均衡表
@property (strong, nonatomic) NSArray *ichimokuInfoArray;
//RSI
@property (strong, nonatomic) NSArray *rsiInfoArray;
//MACD
@property (strong, nonatomic) NSArray *macdInfoArray;
//Sストキャス
@property (strong, nonatomic) NSArray *stochasInfoArray;

/* ローソクステックの幅 */
@property CGFloat candleStickBodyWidth;
/* ローソクステックの間隔 */
@property CGFloat candleStickInterval;

/* 選択中の足種 */
@property (nonatomic, copy) NSString *ashiTypeSelected;



#pragma mark - CHART DATA

/* 描画用四本値データArray (63件) */
@property (strong, nonatomic) NSArray *ohlcArray_in_chart;
/* 描画用移動平均短期データArray (63件) */
@property (strong, nonatomic) NSArray *movAvgShortArray_in_chart;
/* 描画用移動平均中期データArray (63件) */
@property (strong, nonatomic) NSArray *movAvgMediumArray_in_chart;
/* 描画用移動平均長期データArray (63件) */
@property (strong, nonatomic) NSArray *movAvgLongArray_in_chart;
/* 描画用ボリンジャーデータArray (63件) */
@property (strong, nonatomic) NSArray *bollingerInfoArray_in_chart;
/* 描画用一目均衡表データArray (63件) */
@property (strong, nonatomic) NSArray *itikomokuInfoArray_in_chart;

@property CGFloat maxPrice;
@property CGFloat minPrice;
@property NSInteger maxPriceIdx;
@property NSInteger minPriceIdx;
@property NSInteger maxVolume;
@property CGFloat maxPriceDisp; //表示用
@property CGFloat minPriceDisp; //表示用

//チャートの描画データを取得
- (void)getDrawChartData;

//最高値・最安値・最大出来高を取得
- (void)getLimitValues_in_chart;
//チャートの描画データをクリア
- (void)clearDrawChartData;




#pragma mark - DETAIL CHART DATA

//サブチャートを表示するフラグ
@property BOOL needShowSubChart;
//Y軸固定・可変
@property BOOL yAxisFixed;
//移動平均線を表示するフラグ
@property BOOL needShowMovAvg;
//ボリンジャーを表示するフラグ
@property BOOL needShowBollinger;
//一目均衡表を表示するフラグ
@property BOOL needShowIchimoku;
//RSIを表示するフラグ
@property BOOL needShowSub_rsi;
//MACDを表示するフラグ
@property BOOL needShowSub_macd;
//Sストキャスを表示するフラグ
@property BOOL needShowSub_stochas;
//出来高を表示するフラグ
@property BOOL needShowSub_volume;
//四本値を表示するフラグ
@property BOOL needShowFourPrices;

//Y軸が固定する
@property CGFloat maxPriceInAll;
@property CGFloat minPriceInAll;
@property CGFloat maxPriceInAllDisp; //４本値の最大値
@property CGFloat minPriceInAllDisp; //４本値の最小値
@property NSInteger maxVolumeInAll;
@property NSInteger maxPriceIdxInAll;
@property NSInteger minPriceIdxInAll;
@property CGFloat macdMaxInAll;
@property CGFloat macdMinInAll;

- (void)getLimitValueInAll;
- (void)clearDetailChartData;



//Y軸が変化する
@property CGFloat detailChartViewWidth;

@property CGFloat maxPriceInRange;
@property CGFloat minPriceInRange;
@property NSInteger maxVolumeInRange;
@property NSInteger maxPriceIdxInRange;
@property NSInteger minPriceIdxInRange;
@property CGFloat macdMaxInRange;
@property CGFloat macdMinInRange;

- (void)getLimitValueInRange: (CGFloat)offsetX;



#pragma mark - CHART SHARED DATA

@property NSInteger xCursorBtnWidth;
@property NSInteger xCursorBtnHeight;

//ローソクステックの幅を取得
- (CGFloat)getStickUnitWidth;
//X軸有効開始座標を取得
- (CGFloat)getValidLeftBorder: (NSInteger)startIdx;

- (NSInteger)getStickCountInRange;

- (CGFloat)getStartPositionX;

- (void)saveTechnicalSettingValues;

- (void)saveChartSettingOptions;

@end
