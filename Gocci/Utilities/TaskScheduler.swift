//
//  TaskScheduler.swift
//  Gocci
//
//  Created by Ma Wa on 25.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

let TaskScheduler = SingletonTaskScheduler()

// Swift does not support reflection yet. So we either have to hack with NSClassFromString() which does
// Sound a little it meh or we provide this automatic casting table...
class PersistentClassReflexion {
    class func createPersistentTaskFromString(className: String, data: NSDictionary) -> PersistentBaseTask? {
        switch(className) {
            case "DummyPlugTask":
                return DummyPlugTask(dict: data)
            case "TwitterVideoSharingTask":
                return TwitterVideoSharingTask(dict: data)
            default:
                return nil
        }
    }
}

// objective-c wrapper
@objc class TaskSchedulerWrapper: NSObject {
    class func nudge() {
        TaskScheduler.nudge()
    }
    
    class func start() {
        TaskScheduler.startScheduler()
    }
}

class SingletonTaskScheduler {
    
    //let internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    let saveFileName = Util.documentsDirectory() + "/" + "unfinishedTasks.plist"
    
    var schedulerThread: NSThread? = nil
    
    var slots = 1
    var slots_enabled = false
    
    private let eventSemaphore = dispatch_semaphore_create(0)
    var onceToken: dispatch_once_t = 0
    
    let schedulerQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    let subThreadQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    
    var tasks: [PersistentBaseTask] = []
    
    
    func sync(o: AnyObject, f: ()->() ) {
        objc_sync_enter(o)
        f()
        objc_sync_exit(o)
    }
    
    func loadTasksFromDisk() {
        if !tasks.isEmpty {
            print("=== WARNING: you are overwriting tasks... ")
        }
        
        var tmp: [PersistentBaseTask] = []
        
        if let inn = NSArray(contentsOfFile: saveFileName) {
            for dict in inn {
                if let dict = dict as? NSDictionary {
                    if let cn = dict["classname"] as? String {
                        if let t = PersistentClassReflexion.createPersistentTaskFromString(cn, data: dict) {
                            if t.state == .RUNNING {
                                t.state = .SUSPENDED
                            }
                            tmp.append(t)
                        }
                    }
                }
            }
            
            sync(tasks) {
                self.tasks = tmp
            }
            return
        }
    }
    
    private func safeTasksToDisk() {
        if tasks.isEmpty {
            let _ = try? NSFileManager.defaultManager().removeItemAtPath(saveFileName)
        }
        
        let out = NSMutableArray()
        for task in tasks {
            out.addObject(task.dictonaryRepresentation())
        }
        if !out.writeToFile(saveFileName, atomically: true) {
            print("=== ERROR cant write file to disk")
        }
        else {
            print("=== Saved: \(saveFileName)")
        }
    }
    
    func schedule(task: PersistentBaseTask) {

        sync(tasks) {
            self.tasks = self.tasks.filter{ !task.equals($0) }
            self.tasks.append(task) // last position has the highest priority. new task are be default expected to have the highest priority
            self.tasks = self.tasks.sort{ $0.timeNextTry > $1.timeNextTry } // well we sort it anyway for debuggin purposes
            self.safeTasksToDisk()
        }
        dispatch_semaphore_signal(eventSemaphore)
    }
    
    private func dequeueTask(task: PersistentBaseTask) {
        sync(tasks) {
            self.tasks = self.tasks.filter{ !task.equals($0) }
            self.safeTasksToDisk()
        }
    }
    
    private func punishTask(task: PersistentBaseTask) {
        sync(tasks) {
            self.tasks = self.tasks.filter{ !task.equals($0) }
            // punishment time
            let diff = min(60 * 30, max(1, task.timeNextTry - task.timeCreation)) // we try at least once per half an hour
            task.timeNextTry = Int(NSDate().timeIntervalSince1970) + (2 * diff) // <- exponential punishment. everytime twice as long as last time
            
            
            if task.timeNextTry < task.timeGiveUp {
                self.tasks.append(task)
                self.tasks = self.tasks.sort{ $0.timeNextTry > $1.timeNextTry }
            }
            self.safeTasksToDisk()
        }
        dispatch_semaphore_signal(eventSemaphore)
    }
    
    
    func nudge() {
        sync(tasks) {
            if !self.tasks.isEmpty {
                dispatch_semaphore_signal(self.eventSemaphore)
            }
        }
    }
    
    func hardResetNeverUseThisOnlyForDebugging() {
        sync(tasks) {
            self.tasks = []
            let _ = try? NSFileManager.defaultManager().removeItemAtPath(TaskScheduler.saveFileName)
        }
    }
    
    func rescheduleNetworkTasks() {
        sync(tasks) {
            for task in self.tasks {
                if task.state == PersistentBaseTask.State.FAILED_NETWORK {
                    // TODO +5 sec network overload buffer. tests will fail
                    task.timeNextTry = Int(NSDate().timeIntervalSince1970)
                }
            }
            self.tasks = self.tasks.sort{ $0.timeNextTry > $1.timeNextTry }
        }
        dispatch_semaphore_signal(eventSemaphore)
    }
    
//    @objc func reachabilityChanged(note: NSNotification) {
//        if let reachabilty = note.object as? Reachability {
//            let status = reachabilty.currentReachabilityStatus()
//            
//            if status.rawValue != 0 { // == NetworkStatus.ReachableViaWiFi || status == NetworkStatus.ReachableViaWWAN {
//                self.rescheduleNetworkTasks()
//            }
//        }
//    }
    
    func startScheduler() {
        

        let getACopyOfTheThreadWithTheHigestDueThatIsNotRunning: ()->PersistentBaseTask? = {
            
            var task: PersistentBaseTask? = nil
            
            self.sync(self.tasks) {
                for candidate in self.tasks.reverse() {
                    if candidate.state != PersistentBaseTask.State.RUNNING {
                        task = candidate
                        break
                    }
                }
            }
            return task
        }
        
        let taskFrameForHandlingTaskStateResults: (PersistentBaseTask)->()->() = { task in
            
            return {
                task.run { result in
                    
                    print("=== Task finished with result: \(result)")
                
                    self.sync(task) {
                        task.state = result
                    }
                    
                    switch(task.state) {
                    case .FAILED_IRRECOVERABLE:  // nothing we can do here anymore
                        self.dequeueTask(task)
                    case .FAILED_RECOVERABLE:    // maybe next time we have more luck
                        self.punishTask(task)
                    case .FAILED_NETWORK:        // lets hope for the best
                        self.punishTask(task)
                    case .DONE:                  // awesome
                        self.dequeueTask(task)
                    case .SUSPENDED:             // this should never happen
                        self.dequeueTask(task)
                    case .RUNNING:               // this should only happen if a app level bg thread is suspended by iOS
                        self.punishTask(task)
                    }
                    
                    self.sync(self.slots) {
                        self.slots++
                    }
                    dispatch_semaphore_signal(self.eventSemaphore)
                }
            }
        }
        
        let schedulerLoop: ()->() = {
            
            while (true) {
                
                print("===============================================================================")
                print("\(self.tasks)")
                
                // actually this is threadsafe becasue removing tasks can only this task itself. so there is no
                // way that this jumps from true to false.
                if self.tasks.isEmpty {
                    print("=== No tasks... waiting...")
                    dispatch_semaphore_wait(self.eventSemaphore, DISPATCH_TIME_FOREVER)
                    continue
                }
                
                // this is on the other hand is not threadsafe. mainly used for debugging
                if self.slots_enabled && self.slots <= 0 {
                    print("=== No free SLOTS... waiting...")
                    dispatch_semaphore_wait(self.eventSemaphore, DISPATCH_TIME_FOREVER)
                    continue
                }
                
                // don't run running tasks again
                guard let task = getACopyOfTheThreadWithTheHigestDueThatIsNotRunning() else {
                    print("=== All tasks are running. Nothing to do. Waiting...")
                    dispatch_semaphore_wait(self.eventSemaphore, DISPATCH_TIME_FOREVER)
                    continue
                }
                
                // test if the task is on due
                if task.timeNextTry > Int(NSDate().timeIntervalSince1970) {
                    let diff = task.timeNextTry - Int(NSDate().timeIntervalSince1970)
                    print("=== Too early for '\(task)'. waiting \(diff) seconds. waiting...")
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(diff) * Int64(NSEC_PER_SEC))
                    dispatch_semaphore_wait(self.eventSemaphore, dispatchTime)
                    continue
                }
                
                print("=== TASK GETTO!!! (tasks not empty, I have free slots, there is a not running task)")
                
                self.sync(self.slots) {
                    self.slots--
                }
                self.sync(task) {
                    task.state = .RUNNING
                }
                
                let taskWrappedInResponseHandlerFrame = taskFrameForHandlingTaskStateResults(task)
                
                // make this a task that can even run in the background when the app is suspended
                let theRealDeal = Util.createTaskThatWillEvenRunIfTheAppIsPutInBackground(task.identifier,
                    queue: self.subThreadQueue,
                    task: taskWrappedInResponseHandlerFrame,
                    expirationHandler: taskWrappedInResponseHandlerFrame
                )
                
                // here we go. runs that stuff above in a seperate BG Thread
                theRealDeal()
            }
        }
        
        // only one scheduler thread double protection.
        if self.schedulerThread != nil && self.schedulerThread!.executing {
            return
        }
        
        self.loadTasksFromDisk()
        
        
        // we only want one scheduler active. This thread should never disappear. We hope for the best. If it disappears ever
        // we have to find a way that this thread restarts. But for now it seems there is no problem.
        dispatch_once(&self.onceToken) {
            
            // the scheduler has its own threaad. (actually that schould have higher priority than everything else, but its not that important
            dispatch_async(self.schedulerQueue) {
                
                
                self.schedulerThread = NSThread.currentThread()
                
                Network.notifyMyForNetworkStatusChanges { state in
                    if state != .OFFLINE {
                        self.rescheduleNetworkTasks()
                    }
                }
                
//                self.internetReachability.startNotifier()
//                
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
                
                // scheduler GO!
                schedulerLoop()
            }
        }
        
    }

}


class PersistentBaseTask: CustomStringConvertible {
    
    
    enum State: String {
        case SUSPENDED
        case FAILED_IRRECOVERABLE
        case FAILED_RECOVERABLE
        case FAILED_NETWORK
        case DONE
        case RUNNING
    }
    
    let identifier: String
    
    var state: State = .SUSPENDED
    var retrys = 5
    
    var timeCreation = Int(NSDate().timeIntervalSince1970)
    var timeGiveUp = Int(NSDate().timeIntervalSince1970) + (60 * 60 * 24 * 7) // 7 days
    var timeNextTry = Int(NSDate().timeIntervalSince1970)
    
    
    init(identifier: String) {
        self.identifier = identifier + "-" + "RANDOMSTRING"
    }
    
    func schedule() {
        TaskScheduler.schedule(self)
    }
    
    func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["classname"] = String(self.dynamicType)
        dict["identifier"] = identifier
        dict["state"] = String(state)
        dict["retrys"] = retrys
        dict["timeCreation"] = timeCreation
        dict["timeGiveUp"] = timeGiveUp
        dict["timeNextTry"] = timeNextTry
        return dict
    }
    
    
    init?(dict: NSDictionary) {
        identifier = dict["identifier"] as? String ?? ""
        state = State(rawValue: dict["state"] as? String ?? "NEW") ?? .SUSPENDED
        retrys = dict["retrys"] as? Int ?? 0
        timeCreation = dict["timeCreation"] as? Int ?? 0
        timeGiveUp = dict["timeGiveUp"] as? Int ?? 0
        timeNextTry = dict["timeNextTry"] as? Int ?? 0
        
        if identifier == "" || timeCreation == 0 || timeGiveUp == 0 || timeNextTry == 0 {
            return nil
        }
    }
    
    func equals(task: PersistentBaseTask) -> Bool {
        return false
    }
    
    func run(finished: State->()) {
        // override
        fatalError()
    }
    
    var description: String {
        // override
        let left = timeNextTry - Int(NSDate().timeIntervalSince1970)
        return "\(String(self.dynamicType)) \(identifier). Due in '\(left)' seconds."
    }
    
}



class DummyPlugTask: PersistentBaseTask {
    let msg: String
    let sleepSec: Double
    let res: PersistentBaseTask.State
    
    init(msg: String, sleepSec: Double, finalState: PersistentBaseTask.State) {
        self.msg = msg
        self.sleepSec = sleepSec
        self.res = finalState
        super.init(identifier: String(self.dynamicType) + " " + msg)
    }
    
    override init?(dict: NSDictionary) {
        self.msg = dict["msg"] as? String ?? ""
        self.sleepSec = dict["sleepSec"] as? Double ?? -1.0
        self.res = PersistentBaseTask.State(rawValue: dict["res"] as? String ?? "DONE")!
        super.init(dict: dict)
        if msg == "" || sleepSec < 0 { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["msg"] = msg
        dict["sleepSec"] = sleepSec
        dict["res"] = res.rawValue
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? DummyPlugTask {
            return task.msg == msg && task.sleepSec == sleepSec
        }
        return false
    }
    
    override func run(finished: State->()) {
        print("*** Running : \(String(self.dynamicType)) \(msg). Will sleepSec for: \(sleepSec)")
        Util.sleep(sleepSec)
        print("*** Finished: \(String(self.dynamicType)) \(msg). Slept for: \(sleepSec). now in '\(res)' mode")
        finished(res)
    }
    
    override var description: String {
        return "Sleep: \(sleepSec)"
        //return super.description + " \(msg). Will Sleep for \(sleepSec)"
    }
    
}



























