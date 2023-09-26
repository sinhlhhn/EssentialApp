//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Sam on 26/09/2023.
//

import XCTest

extension XCTestCase {
    func assert(snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try! snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name: name, file: file)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL
                    .deletingLastPathComponent(),
                withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return snapshotData
    }
    
    private func makeSnapshotURL(name: String, file: StaticString) -> URL {
        return URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshot")
            .appending(path: "\(name).png")
    }
}
