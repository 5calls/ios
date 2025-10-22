// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class BaseOperation: Operation, @unchecked Sendable {
    var session: URLSession = .shared

    override init() {
        super.init()

        // ideally we could avoid the app code knowing about testing at all,
        // and that would be possible if we were only unit testing and can
        // inject a mock session into our operations, but for UI testing we
        // also want to mock data and you can't reach into the app module to
        // configure anything so we're stuck with configuring via
        // appEnvironment for loading test data which you have to handle in
        // your actual app module
        if isUITesting() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [ProtocolMock.self]
            session = URLSession(configuration: config)
        }
    }

    override var isAsynchronous: Bool {
        true
    }

    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isExecuting: Bool {
        _executing
    }

    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }

        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isFinished: Bool {
        _finished
    }

    func buildRequest(forURL url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(AnalyticsManager.shared.callerID, forHTTPHeaderField: "X-Caller-ID")
        return request
    }

    override func start() {
        _executing = true
        execute()
    }

    func execute() {
        fatalError("You must override this")
    }

    func finish() {
        _executing = false
        _finished = true
    }
}
