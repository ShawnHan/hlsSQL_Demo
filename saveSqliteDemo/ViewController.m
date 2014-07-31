//
//  ViewController.m
//  saveSqliteDemo
//
//  Created by Shawn on 14-7-31.
//  Copyright (c) 2014年 hanlong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *finishDate;
@property (strong, nonatomic) NSString *checkResult;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *testResultDB;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"testResult.sqlite"]];
    
    NSLog(@"path == %@",_databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:_databasePath] == NO) {
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open(dbpath, &_testResultDB) == SQLITE_OK) {
            
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, STARTTIME TEXT, FINISHTIME TEXT, RESULT TEXT)";
            if (sqlite3_exec(_testResultDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK ) {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_testResultDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
    
    int count;
    count = [self GetCount];
    NSLog(@"data base count %i",count);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startTime:(id)sender {
    _startDate = [NSDate date];
}
- (IBAction)goodTapped:(id)sender {
    _checkResult = @"good";
}
- (IBAction)badTapped:(id)sender {
    _checkResult = @"bad";
}
- (IBAction)finishTime:(id)sender {
    
    _finishDate = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *startStr = [formatter stringFromDate:_startDate];
    NSString *finishStr = [formatter stringFromDate:_finishDate];
    
    NSLog(@"Start time = %@, checkresult = %@, finish time = %@",startStr,_checkResult,finishStr);
   //**************************************
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_testResultDB) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO CONTACTS (starttime, finishtime, result) VALUES (\"%@\", \"%@\",\"%@\")",startStr, finishStr, _checkResult];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_testResultDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            
            NSLog(@"data add success!");
        }
        else
        {
            NSLog(@"failed to add data");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_testResultDB);
        
    }
}
- (IBAction)outputdata:(id)sender {
    [self dataOutPut];
}

-(void)dataOutPut
{
    NSLog(@"dataoutput");
    const char *dbpath = [_databasePath UTF8String];
    
    //SELECT ROW,FIELD_DATA FROM FIELDS ORDER BY ROW
    sqlite3_stmt *stmt;
    if (sqlite3_open(dbpath, &_testResultDB) == SQLITE_OK) {
        NSString *quary = @"SELECT * FROM CONTACTS";
        NSLog(@"data = %@",quary);
        const char *query_stmt = [quary UTF8String];
    if (sqlite3_prepare_v2(_testResultDB, query_stmt, -1, &stmt, NULL) == SQLITE_OK) {
        NSLog(@"sqlite ok");
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            char *name = (char *)sqlite3_column_text(stmt, 1);
            NSString *nameString = [[NSString alloc] initWithUTF8String:name];
            
            char *sex = (char *)sqlite3_column_text(stmt, 2);
            NSString *sexString = [[NSString alloc] initWithUTF8String:sex];
            
            char *address = (char *)sqlite3_column_text(stmt, 3);
            NSString *addressString = [[NSString alloc] initWithUTF8String:address];
            
            NSLog(@"starr: %@, finish: %@, result: %@",nameString,sexString,addressString);
        }  
        
        sqlite3_finalize(stmt);  
    }
         sqlite3_close(_testResultDB);
    }
    
}


-(int)GetCount
{
    int count = 0;
    
    if (sqlite3_open([self.databasePath UTF8String], &_testResultDB) == SQLITE_OK) {
        NSLog(@"count sqlite ok");
        //NSString *query = @"SELECT COUNT(*) FROM CONTACTS";
        const char* sqlStmt = "SELECT COUNT(*) FROM CONTACTS";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(_testResultDB, sqlStmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"sqlite prepare ok");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
                NSLog(@"count == %i",count);
                
            }
        }
        else
        {
            NSLog(@"Failed from sqlite3_prepare_v2. Error is: %s", sqlite3_errmsg(_testResultDB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(_testResultDB);
    }
    
    
    return count;
}
- (IBAction)countAction:(id)sender {
    int count;
    count = [self GetCount];
    NSLog(@"count == %i",count);
}




@end
