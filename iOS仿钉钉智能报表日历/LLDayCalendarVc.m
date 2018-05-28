//
//  LLDayCalendarVc.m
//  iOS仿钉钉智能报表日历
//
//  Created by 周尊贤 on 2018/5/28.
//  Copyright © 2018年 周尊贤. All rights reserved.
//

#import "LLDayCalendarVc.h"
#import "ViewController.h"
#import "FSCalendar.h"
#import "LLDayRangeCell.h"
@interface LLDayCalendarVc ()<FSCalendarDataSource,FSCalendarDelegate>
@property (weak, nonatomic) FSCalendar *calendar;

@property (weak, nonatomic) UILabel *eventLabel;
@property (strong, nonatomic) NSCalendar *gregorian;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// The start date of the range
@property (strong, nonatomic) NSDate *date1;
// The end date of the range
@property (strong, nonatomic) NSDate *date2;
@end

@implementation LLDayCalendarVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCalendarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}


- (void)setupCalendarView
{
    self.gregorian = [NSCalendar currentCalendar];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.calendar.accessibilityIdentifier = @"calendar";
    
//    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    view.backgroundColor = [UIColor whiteColor];
//    self.view = view;
    
    //CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 450 : 300;
    CGFloat statusHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat pageTitleViewY = 0;
    if (statusHeight == 20.0) {
        pageTitleViewY = 64;
    } else {
        pageTitleViewY = 88;
    }
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.headerMinimumDissolvedAlpha = 0;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase;
    [calendar registerClass:[LLDayRangeCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:calendar];
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
    self.date1 = [calendar today];
    
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

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    LLDayRangeCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
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
    if ((self.date1 && self.date2 == nil)||[self.date1 compare:self.date2 ] == NSOrderedSame) {
        self.date2 = date;
    }else if (self.date1 && self.date2){
        self.date1 = date;
        self.date2 = nil;
    }
    //if (calendar.swipeToChooseGesture.state == UIGestureRecognizerStateChanged) {
    // If the selection is caused by swipe gestures
    //        if (!self.date1) {
    //            self.date1 = date;
    //        } else {
    //            if (self.date2) {
    //                [calendar deselectDate:self.date2];
    //            }
    //            self.date2 = date;
    //        }
    //    } else {
    //        if (self.date2) {
    //            [calendar deselectDate:self.date1];
    //            [calendar deselectDate:self.date2];
    //            self.date1 = date;
    //            self.date2 = nil;
    //        } else if (!self.date1) {
    //            self.date1 = date;
    //        } else {
    //            self.date2 = date;
    //        }
    //}
    
    [self configureVisibleCells];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    NSLog(@"did deselect date %@",[self.dateFormatter stringFromDate:date]);
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
    [self.calendar.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendar dateForCell:obj];
        FSCalendarMonthPosition position = [self.calendar monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(__kindof FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    LLDayRangeCell *rangeCell = cell;
    if (position == FSCalendarMonthPositionCurrent) {
        //        rangeCell.middleLayer.hidden = YES;
        //        rangeCell.selectionLayer.hidden = YES;
        //        rangeCell.markLable.hidden = true;
        rangeCell.titleLabel.textColor = [UIColor blackColor];
        
    }else {
        rangeCell.titleLabel.textColor = [UIColor lightGrayColor];
    }
    if ((self.date1 && self.date2 == nil) ||[self.date1 compare:self.date2] == NSOrderedSame) {
        if ([self.date1 compare:date] == NSOrderedSame) {
            rangeCell.markLable.text = @"开始";
            rangeCell.markLable.hidden = false;
        }
    }
    if (self.date1 && self.date2) {
        // The date is in the middle of the range
        BOOL isMiddle = [date compare:self.date1] != [date compare:self.date2];
        rangeCell.middleLayer.hidden = !isMiddle;
        rangeCell.markLable.hidden = true;
        if (isMiddle) {
            rangeCell.titleLabel.textColor = [UIColor whiteColor];
        }else {
            
        }
        if ([self.date1 compare:self.date2] == NSOrderedAscending) {
            if ([self.date1 compare:date] == NSOrderedSame) {
                rangeCell.markLable.text = @"开始";
                rangeCell.markLable.hidden = false;
            }
            if ([self.date2 compare:date] == NSOrderedSame) {
                rangeCell.markLable.text = @"结束";
                rangeCell.markLable.hidden = false;
            }
        }
        else if([self.date1 compare:self.date2] == NSOrderedDescending) {
            if ([self.date1 compare:date] == NSOrderedSame) {
                rangeCell.markLable.text = @"结束";
                rangeCell.markLable.hidden = false;
            }
            if ([self.date2 compare:date] == NSOrderedSame) {
                rangeCell.markLable.text = @"开始";
                rangeCell.markLable.hidden = false;
            }
        }
        
    } else {
        rangeCell.middleLayer.hidden = YES;
        // rangeCell.titleLabel.textColor = [UIColor blackColor];
    }
    BOOL isSelected = NO;
    isSelected |= self.date1 && [self.gregorian isDate:date inSameDayAsDate:self.date1];
    isSelected |= self.date2 && [self.gregorian isDate:date inSameDayAsDate:self.date2];
    rangeCell.selectionLayer.hidden = !isSelected;
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
