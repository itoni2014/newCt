
#import <Foundation/Foundation.h>

#define DECIMALNUMBER_INTNUM(num) [[NSDecimalNumber alloc]initWithInt: num]
#define ROUNDING_BEHAVIOR_5 [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:5 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]
#define ROUNDING_BEHAVIOR_2 [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]


@interface TechnicalCalculating : NSObject

////移動平均計算
//+ (NSArray *)calculateMoveAvg :(int) moveAvgTerm beanArray:(NSArray *) fourValuesList;
//
////ボリンジャーバンド計算
//+ (NSArray *)caluculateBollingerBandsTerm: (int) bollingerBandsTerm  standardDeviationMR: (int) standardDeviationMR  standardDeviation2MR: (int) standardDeviation2MR beanArray: (NSArray *) fourValuesList;
//
////一目均衡表計算
//+ (NSArray *)calculateIchimokuShortTerm: (int)shortTerm MiddleTerm: (int)middleTerm LongTerm: (int)longTerm beanArray: (NSArray *) fourValuesList;
//
////RSI計算
//+ (NSArray *)caluculateRSI: (int) moveAvgTerm beanArray: (NSArray *) fourValuesList;
//
////MACD計算
//+ (NSArray *)caluculateMACDshortEMA: (int) shortEMA longEMA:(int) longEMA signal: (int) signal beanArray: (NSArray *) fourValuesList;
//
////スローストキャス計算
//+ (NSArray *)calculateSlowStcstcsJudgeTerm:(int) highLowJudgeTerm avgTerm:(int) moveAvgTerm beanArray: (NSArray *)fourValuesList;


@end
