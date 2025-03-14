//
//  ThreadingOperator.swift
//  Hitch
//
//  Created by Brandon Price on 2/19/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

infix operator ~>   // serial queue operator
/**
 Executes the lefthand closure on a background thread and,
 upon completion, the righthand closure on the main thread.
 Passes the background closure's output to the main closure.
 */
func ~> <R> (
    backgroundClosure:   @escaping () -> R,
    mainClosure:         @escaping (_ result: R) -> ())
{
    serial_queue.async {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: {
            mainClosure(result)
        })
    }
}
/** Serial dispatch queue used by the ~> operator. */
private let serial_queue = DispatchQueue(label: "serial-worker")

////////////////////////////////////////////////////////////////////////////////////////////////////
infix operator ≠>   // concurrent queue operator
/**
 Executes the lefthand closure on a background thread and,
 upon completion, the righthand closure on the main thread.
 Passes the background closure's output to the main closure.
 */
func ≠> <R> (
    backgroundClosure: @escaping () -> R,
    mainClosure:       @escaping (_ result: R) -> ())
{
    concurrent_queue.async {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: {
            mainClosure(result)
        })
    }
}

/** Concurrent dispatch queue used by the ≠> operator. */
private let concurrent_queue = DispatchQueue(label: "concurrent-worker", attributes: .concurrent)
