//
//  GCD.swift
//  GCDDemo-Swift
//
//  Created by Mr.LuDashi on 16/3/29.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import Foundation

/**
 获取当前线程
 
 - returns: NSThread
 */
func getCurrentThread() -> NSThread {
    let currentThread = NSThread.currentThread()
    return currentThread
}

/**
 当前线程休眠
 
 - parameter timer: 休眠时间/单位：s
 */
func currentThreadSleep(timer: NSTimeInterval) -> Void {
    NSThread.sleepForTimeInterval(timer)
}



/**
 获取主队列
 
 - returns: dispatch_queue_t
 */
func getMainQueue() -> dispatch_queue_t {
    return dispatch_get_main_queue();
}


/**
 获取全局队列, 并指定优先级
 
 - parameter priority: 优先级
 DISPATCH_QUEUE_PRIORITY_HIGH        高
 DISPATCH_QUEUE_PRIORITY_DEFAULT     默认
 DISPATCH_QUEUE_PRIORITY_LOW         低
 DISPATCH_QUEUE_PRIORITY_BACKGROUND  后台
 - returns: 全局队列
 */
func getGlobalQueue(priority: dispatch_queue_priority_t = DISPATCH_QUEUE_PRIORITY_DEFAULT) -> dispatch_queue_t {
    return dispatch_get_global_queue(priority, 0)
}



/**
 创建并行队列
 
 - parameter label: 并行队列的标记
 
 - returns: 并行队列
 */
func getConcurrentQueue(label: String) -> dispatch_queue_t {
    return dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT)
}


/**
 创建串行队列
 
 - parameter label: 串行队列的标签
 
 - returns: 串行队列
 */
func getSerialQueue(label: String) -> dispatch_queue_t {
    return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
}


/**
 使用dispatch_sync在当前线程中执行队列
 
 - parameter queue: 队列
 */
func performQueuesUseSynchronization(queue: dispatch_queue_t) -> Void {
    
    for i in 0..<3 {
        dispatch_sync(queue) {
            currentThreadSleep(1)
            print("当前执行线程：\(getCurrentThread())")
            print("执行\(i)")
        }
        print("\(i)执行完毕")
    }
    print("所有队列使用同步方式执行完毕")
}

/**
 使用dispatch_async在当前线程中执行队列
 
 - parameter queue: 队列
 */
func performQueuesUseAsynchronization(queue: dispatch_queue_t) -> Void {
    
    //一个串行队列，用于同步锁
    let lockQueue = getSerialQueue("lock")
    
    for i in 0..<3 {
        dispatch_async(queue) {
            currentThreadSleep(Double(arc4random()%3))
            let currentThread = getCurrentThread()
            
            dispatch_sync(lockQueue, {              //同步锁
                print("Sleep的线程\(currentThread)")
                print("当前输出内容的线程\(getCurrentThread())")
                print("执行\(i):\(queue)\n")
            })
        }
        
        print("\(i)添加完毕\n")
    }
    print("使用异步方式添加队列")
}


func deferPerform(time: Double) -> Void {
    
    //dispatch_time用于计算相对时间,当设备睡眠时，dispatch_time也就跟着睡眠了
    let delayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, getGlobalQueue()) { 
        print("dispatch_time: 延迟\(time)秒执行")
    }
    
    //dispatch_walltime用于计算绝对时间,而dispatch_walltime是根据wall clock，即使设备睡眠了，他也不会睡眠。
    let nowInterval = NSDate().timeIntervalSince1970
    var nowStruct = timespec(tv_sec: Int(nowInterval), tv_nsec: 0)
    let delayWalltime = dispatch_walltime(&nowStruct, Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(delayWalltime, getGlobalQueue()) {
        print("dispatch_walltime: 延迟\(time)秒执行")
    }

}
