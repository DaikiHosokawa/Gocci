//
//  TestTaskScheduler.swift
//  Gocci
//
//  Created by Ma Wa on 25.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import XCTest


class TestTaskScheduler: XCTestCase {
    
    // only once before testing (class function)
    override class func setUp() {
        // only starts the scheduler if it not already runnig
        TaskScheduler.startScheduler()
        
        super.setUp()
    }
    
    // after every test
    override func tearDown() {
        TaskScheduler.hardResetNeverUseThisOnlyForDebugging()
        TaskScheduler.slots = 1
        super.tearDown()
    }
    
    
    class CustonDummyPlugTask: DummyPlugTask {
        
        var expectation: XCTestExpectation?
        var stati: [PersistentBaseTask.State]
        
        init(msg: String? , sleep: Double, stati:[PersistentBaseTask.State], _ expectation: XCTestExpectation?) {
            self.expectation = expectation
            self.stati = stati
            super.init(msg: msg ?? Util.randomKanjiStringWithLength(5), sleepSec: sleep, finalState: .DONE)
        }
        
        override func run(finished: State->()) {
            print("*** Running : \(String(self.dynamicType)) \(msg). Will sleepSec for: \(sleepSec)")
            Util.sleep(sleepSec)
            
            if stati.isEmpty {
                fatalError()
            }
            
            let r = stati.removeFirst()
            
            if stati.isEmpty {
                print("*** Finished: \(String(self.dynamicType)) \(msg). Slept for: \(sleepSec). now in '\(r)' mode")
                expectation?.fulfill()
                finished(r)
            }
            else {
                print("*** Failed: \(String(self.dynamicType)) \(msg). Slept for: \(sleepSec). now in '\(r)' mode")
                finished(r)
            }
        }
    }
    
    class DelayedCustonDummyPlugTask: CustonDummyPlugTask {

        var timings: [Int] = []
        
        override func run(finished: State->()) {
            timeNextTry = timings.removeFirst()
            super.run(finished)
        }
    }
    
    class CallbackCustonDummyPlugTask: CustonDummyPlugTask {
        
        var callback: (()->())? = nil
        
        override func run(finished: State -> ()) {
            if stati.count == 1 {
                print("calling callback before foshing task")
                callback?()
            }
            super.run(finished)
        }
    }

    
    
    
    func testIfOneTaskExecutes() {
        let expectation = expectationWithDescription("fin")
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectation).schedule()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testIfTwoTasksExecute() {
        let expectation1 = expectationWithDescription("first")
        CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.DONE], expectation1).schedule()
        
        let expectation2 = expectationWithDescription("second")
        CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.DONE], expectation2).schedule()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testIfTwoTasksExecuteWithTimeDiff() {
        let expectation1 = expectationWithDescription("first")
        CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.DONE], expectation1).schedule()
        Util.sleep(0.1)
        let expectation2 = expectationWithDescription("second")
        CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.DONE], expectation2).schedule()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testIfAFailedTaskGetsRescheduledAndFinishesGracefully() {
        let expectation1 = expectationWithDescription("first")
        CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], expectation1).schedule()
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    
    func testIfReschedulingWorksWithOneTaskWaiting() {
        let dummy = CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], nil)
        dummy.timeNextTry = dummy.timeNextTry + 10000
        dummy.schedule()
        
        let expectation1 = expectationWithDescription("first")
        CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], expectation1).schedule()
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testIfReschedulingWorksWithFourTaskWaiting() {
        
        for _ in 1...4 {
            let dummy = CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], nil)
            dummy.timeNextTry = dummy.timeNextTry + 10000
            dummy.schedule()
        }
        
        let expectation1 = expectationWithDescription("first")
        CustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], expectation1).schedule()
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testInstantRescheduleOnNetworkActivity() {
        let expectation1 = expectationWithDescription("first")
        
        let dummy = DelayedCustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_NETWORK, .DONE], expectation1)
        dummy.timings = [10000, 10000]
        dummy.schedule()
        
        Util.sleep(1.0)
        TaskScheduler.rescheduleNetworkTasks() // pretend network came back
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testSchdulerWith_2_Slots() {
        
        TaskScheduler.slots = 2
        
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectationWithDescription("first")).schedule()
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectationWithDescription("second")).schedule()
        
        waitForExpectationsWithTimeout(0.7, handler: nil)
    }
    
    func testSchdulerWith_3_Slots() {
        
        TaskScheduler.slots = 3
        
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectationWithDescription("first")).schedule()
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectationWithDescription("second")).schedule()
        CustonDummyPlugTask(msg: nil, sleep: 0.5, stati: [.DONE], expectationWithDescription("third")).schedule()
        
        waitForExpectationsWithTimeout(0.7, handler: nil)
    }
    
    func testSchdulerWith_8_ThreadsAnd_4_Slots() {
        
        TaskScheduler.slots = 4
        
        for i in 1...8 {
            CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.DONE], expectationWithDescription("t\(i)")).schedule()
        }
        
        waitForExpectationsWithTimeout(0.8, handler: nil)
    }
    
    func testReschedulingWith_3_ThreadsAnd_3_Slots() {
        
        TaskScheduler.slots = 3
        
        for i in 1...3 {
            // one thread will take 0.3 + 0.3 + 1.0 Punishment Time
            CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.FAILED_RECOVERABLE, .DONE], expectationWithDescription("t\(i)")).schedule()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testReschedulingWith_4_ThreadsAnd_2_Slots() {
        
        TaskScheduler.slots = 2
        
        for i in 1...4 {
            // one thread will take 0.3 + 0.3 + 1.0 Punishment Time
            CustonDummyPlugTask(msg: nil, sleep: 0.3, stati: [.FAILED_RECOVERABLE, .DONE], expectationWithDescription("t\(i)")).schedule()
        }
        
        waitForExpectationsWithTimeout(4.0, handler: nil)
    }

    func testLoadTaskFromDiskCapability() {
        let t = DummyPlugTask(msg: "simple", sleepSec: 0.5, finalState: .DONE)
        t.timeNextTry = t.timeNextTry + 2
        t.schedule()
        TaskScheduler.hardResetNeverUseThisOnlyForDebugging()
        XCTAssert(TaskScheduler.tasks.isEmpty)
        TaskScheduler.loadTasksFromDisk()
        XCTAssert(TaskScheduler.tasks.count == 1)
        TaskScheduler.nudge()
        Util.sleep(4)
        XCTAssert(TaskScheduler.tasks.isEmpty)

    }
    
    func testLoad_3_TasksFromDiskCapability() {
        for i in 1...3 {
            let t = DummyPlugTask(msg: "simple\(i)", sleepSec: 0.1, finalState: .DONE)
            t.timeNextTry = t.timeNextTry + 2
            t.schedule()
        }
        XCTAssert(TaskScheduler.tasks.count == 3)
        TaskScheduler.hardResetNeverUseThisOnlyForDebugging()
        XCTAssert(TaskScheduler.tasks.isEmpty)
        TaskScheduler.loadTasksFromDisk()
        XCTAssert(TaskScheduler.tasks.count == 3)
        TaskScheduler.nudge()
        Util.sleep(4)
        XCTAssert(TaskScheduler.tasks.isEmpty)
        
    }
    
    func testATaskWhichStartsAnotherTask_ChainTasking() {
        
        let levels = 5
        
        let exs = (1...levels).map{ i in self.expectationWithDescription("ex\(i)") }
            
        
        func f(i: Int) -> () -> () {
            if i == 0 { return {} }
            
            return {
                let d = CallbackCustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.DONE], exs[i-1])
                //let d = CallbackCustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.FAILED_RECOVERABLE, .DONE], exs[i-1])
                d.callback = f(i-1)
                d.schedule()
            }
        }
        
        let dummy = CallbackCustonDummyPlugTask(msg: nil, sleep: 0.2, stati: [.DONE], expectationWithDescription("top"))
        dummy.callback = f(levels)
            
        dummy.schedule()
        
        waitForExpectationsWithTimeout(4.0, handler: nil)
    }
}






















