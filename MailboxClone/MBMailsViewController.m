//
//  MBMailsViewController.m
//  RBTest1
//
//  Created by Vitaliy Berg on 4/21/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "MBMailsViewController.h"
#import "MBMailCell.h"
#import "MBMailBox.h"

@interface MBMailsViewController () <
    UITableViewDataSource,
    UITableViewDelegate,
    MBMailCellDelegate
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *mails;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MBMailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.opaque = YES;
    self.view.backgroundColor = MB_RGB(227, 227, 227);
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.frame = self.view.bounds;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 86;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.calendar = [NSCalendar currentCalendar];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSURL *dataURL = [[NSBundle mainBundle] URLForResource:@"emails.json" withExtension:@""];
    NSData *data = [NSData dataWithContentsOfURL:dataURL];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    self.mails = [[MBMail mailsWithAttributes:json] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    NSUInteger components = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [self.calendar components:components fromDate:date];
    NSDateComponents *currentDateComponents = [self.calendar components:components fromDate:currentDate];
    
    if (dateComponents.year == currentDateComponents.year) {
        if (dateComponents.month == currentDateComponents.month &&
            dateComponents.day == currentDateComponents.day)
        {
            self.dateFormatter.dateFormat = @"h:mm a";
        } else {
            self.dateFormatter.dateFormat = @"MMM d";
        }
    } else {
        self.dateFormatter.dateFormat = @"MMM d, yyyy";
    }
    
    return [self.dateFormatter stringFromDate:date];
}

#pragma mark - MBMailCellDelegate

- (void)mailCellDidSlideFromLeft:(MBMailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.mails removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)mailCellDidSlideFromRight:(MBMailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.mails removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MailCell";
    MBMailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[MBMailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.delegate = self;
    }
    
    MBMail *mail = self.mails[indexPath.row];
    cell.from = [mail.from nameString];
    cell.subject = mail.subject;
    cell.body = mail.body;
    cell.starred = mail.starred;
    cell.messages = mail.messages;
    cell.receivedAt = [self stringFromDate:mail.receivedAt];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end