//
//  TechnicalCalculating.m
//  Prototype2
//
//  Created by ias_sec on 2015/11/06.
//  Copyright © 2015年 TnsStudio. All rights reserved.
//

#import "TechnicalCalculating.h"
#import "OhlcBean.h"
#import "ChartBox.h"

@implementation TechnicalCalculating


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
