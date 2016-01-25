

#import <Foundation/Foundation.h>


@interface OhlcBean : NSObject
/** 四本値日付 */
@property(nonatomic, copy) NSString *fourValuesDate;
/** 四本値時刻 */
@property(nonatomic, copy) NSString *fourValuesTime;
/** 始値 */
@property(nonatomic, copy) NSDecimalNumber *openPrice;
/** 高値 */
@property(nonatomic, copy) NSDecimalNumber *highPrice;
/** 安値 */
@property(nonatomic, copy) NSDecimalNumber *lowPrice;
/** 終値 */
@property(nonatomic, copy) NSDecimalNumber *closePrice;
/** 出来高 */
@property(nonatomic, assign) NSInteger turnover;
/** 前日始値 */
@property(nonatomic, copy) NSDecimalNumber *previousOpenPrice;
/** 前日高値 */
@property(nonatomic, copy) NSDecimalNumber *previousHighPrice;
/** 前日安値 */
@property(nonatomic, copy) NSDecimalNumber *previousLowPrice;
/** 前日終値 */
@property(nonatomic, copy) NSDecimalNumber *previousClosePrice;
///** 最高 */
//@property(nonatomic, copy) NSDecimalNumber *maxPrice;
///** 最安 */
//@property(nonatomic, copy) NSDecimalNumber *minPrice;


@end
