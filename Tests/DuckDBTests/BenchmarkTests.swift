//
//  DuckDB
//  https://github.com/duckdb/duckdb-swift
//
//  Copyright © 2018-2023 Stichting DuckDB Foundation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

import Foundation
import XCTest
import TabularData
@testable import DuckDB

var connection : Connection?

final class BenchmarkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        do {
            connection = try Database(store: .inMemory).connect()
            if let unwrapped_conn = connection {
                try unwrapped_conn.execute("""
                    create table t1 as select range as a, range::VARCHAR as b from range(10000);
                """)
            }
        } catch {
            // self.connection not initialized
        }
    }

    func test_bool_round_trip() throws {
        if let unwrapped_conn = connection {
            measure {
                do {
                    
                    let result = try unwrapped_conn.query("""
                        select * from t1;
                    """)
                    let int_column = result[0].cast(to: Int.self)
                    let varchar_column = result[1].cast(to: String.self)
                    let _ = DataFrame(columns: [
                        TabularData.Column(int_column)
                            .eraseToAnyColumn(),
                        TabularData.Column(varchar_column)
                            .eraseToAnyColumn(),
                    ])
                } catch {
                }
            }
        }
    }
}
