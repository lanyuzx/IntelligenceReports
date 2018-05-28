//
//  LLWeekCalendarVc.m
//  iOS仿钉钉智能报表日历
//
//  Created by 周尊贤 on 2018/5/28.
//  Copyright © 2018年 周尊贤. All rights reserved.
//

#import "LLWeekCalendarVc.h"
#import "FSCalendar.h"
#import "LLWeekRangeCell.h"
@interface LLWeekCalendarVc ()<FSCalendarDataSource,FSCalendarDelegate>
@property (weak, nonatomic) FSCalendar *calendar;

@property (weak, nonatomic) UILabel *eventLabel;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

//用作选择周历
@property (nonatomic,strong) NSDate * selectedDate;

@property (nonatomic,strong) NSMutableArray <NSDate*> * seletedWeekDates;
@end

@implementation LLWeekCalendarVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.seletedWeekDates = [NSMutableArray array];
    [self setupCalendarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCalendarView
{
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    view.backgroundColor = [UIColor whiteColor];
//    self.view = view;
    
    CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 650 : 300;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.firstWeekday = 1;
    calendar.backgroundColor = [UIColor whiteColor];
    //    calendar.appearance.headerMinimumDissolvedAlpha = 0;
    //    calendar.placeholderType = FSCalendarPlaceholderTypeNone;
    //    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase;
    [calendar registerClass:[LLWeekRangeCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:calendar];
    // For UITest
    self.calendar.accessibilityIdentifier = @"calendar";
    self.calendar = calendar;
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(0, 0, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setImage:[UIImage imageNamed:@"icon_prev"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousButton];
    //self.previousButton = previousButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-95, 0, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setImage:[UIImage imageNamed:@"icon_next"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    
}



#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.dateFormatter dateFromString:@"2001-01-01"];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:10 toDate:[NSDate date] options:0];
}
//
//- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
//{
//    if ([self.gregorian isDateInToday:date]) {
//        return @"今";
//    }
//    return nil;
//}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    LLWeekRangeCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:(LLWeekRangeCell*)cell forDate:date atMonthPosition:monthPosition];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return true;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return true;
}


- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [self .seletedWeekDates removeAllObjects];
    self.selectedDate = date;
    [self configureVisibleCells];
}



- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

#pragma mark - Private methods

- (void)configureVisibleCells
{
    
    [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof LLWeekRangeCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendar dateForCell:obj];
        if ([self isSameWeekWithDate:date withWeakDay:self.selectedDate]) {
            NSLog(@"%@和选择日期为同一周%@\n",date,self.selectedDate);
            [self .seletedWeekDates addObject:date];
        }
        FSCalendarMonthPosition position = [self.calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position] ;
    }];
    
}

- (void)configureCell:(__kindof LLWeekRangeCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    
    LLWeekRangeCell *rangeCell = cell;
    rangeCell.middleLayer.hidden = true;
    rangeCell.selectionLayer.hidden = true;
    rangeCell.markLable.hidden = true;
    if (position == FSCalendarMonthPositionCurrent) {
        rangeCell.titleLabel.textColor = [UIColor blackColor];
    }else {
        rangeCell.titleLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (self.seletedWeekDates.count == 7) {
        NSArray<NSDate *>* compareDates = [self.seletedWeekDates sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        [self.seletedWeekDates enumerateObjectsUsingBlock:^(NSDate * _Nonnull dateObj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof LLWeekRangeCell * _Nonnull cellObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDate *date = [self.calendar dateForCell:cellObj];
                if ([dateObj compare:date] == NSOrderedSame ) {
                    cellObj.middleLayer.hidden = false;
                      cellObj.titleLabel.textColor = [UIColor whiteColor];
                }
              
                if ([compareDates.firstObject compare:date]==NSOrderedSame) {
                    cellObj.markLable.hidden = false;
                    cellObj.markLable.text = @"开始";
                }
                if ([compareDates.lastObject compare:date]==NSOrderedSame) {
                    cellObj.markLable.hidden = false;
                    cellObj.markLable.text = @"结束";
                }
            }];
        }];
    }
}

- (void)previousClicked:(id)sender
{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)nextClicked:(id)sender
{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (BOOL) isSameWeekWithDate:(NSDate *)beforeDate withWeakDay:(NSDate*)selectedDate {
    
    NSCalendar *calendar = self.gregorian;
    
    NSInteger nowInteger = [calendar component:NSCalendarUnitWeekOfYear fromDate:self.selectedDate];
    NSInteger nowWeekDay = [calendar component:NSCalendarUnitWeekday fromDate:self.selectedDate];
    
    //nowWeekDay =   nowWeekDay == 1 ? 7 : nowWeekDay - 1;
    
    NSInteger beforeInteger = -1;
    if (beforeDate) {
        beforeInteger = [calendar component:NSCalendarUnitWeekOfYear fromDate:beforeDate];
    }
    
    if (nowInteger == beforeInteger) {
        // 在一周
        return YES;
    } else if (nowInteger - beforeInteger == 1 && nowWeekDay == 1) {
        // 西方一周的第一天从周日开始，所以需要判断当前是否为一周的第一天，如果是，则为同周
        return YES;
    }
    
    return NO;
    
    
}



@end
