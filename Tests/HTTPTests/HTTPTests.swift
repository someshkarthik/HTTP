import XCTest
@testable import HTTP

struct User: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

final class HTTPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        HTTP.shared
            .dataRequestBuilder ({ (builder) in
                builder
                    .url("https://jsonplaceholder.typicode.com/todos/1")
                    .decode(to: User.self, completion: {
                        print("Decoded", $0.value)
                    })
                    .catch({
                        print($0.value)
                    })
                    .build()
            })
            .downloadRequestBuilder { (builder) in
                builder
                    .url("https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg")
                    .catch({
                        print($0.value.localizedDescription)
                    })
                    .progressHandler({
                        print($0.percentage, $0.formattedCompletedSize(in: .megaByte))
                    })
                    .fileDestination({ (url, response) -> (targetURL: URL, options: HTTPDownloadRequestBuilder.DestinationFileOptions) in
                        return (
                            URL(fileURLWithPath: "/Users/somesh-8758/Downloads/\(url.lastPathComponent)")
                            ,
                            [.removeDuplicate]
                        )
                    })
                    .completionHandler({
                        print($0.value.path)
                    })
                    .build()
        }
        sleep(100)
    }
    
    var request: HTTPRequest!
    func testDownloadRequest() {
        let semaphore = DispatchSemaphore(value: 0)
        request = HTTP.shared
            .downloadRequestBuilder()
            .url(URL(string: ""))
            .catch({
                self.request.resume()
                print($0.value.localizedDescription)
            })
            .progressHandler({
                print("Percentage: \($0.percentage)\t\t","Completed: \($0.formattedCompletedSize(in: .megaByte))MB  of  \($0.formattedTotalSize(in: .megaByte))MB")
            })
            .header(["Cookie" : "PHPSESSID=c9run956jg43imh8sva0it1bu3; kt_ips=205.185.125.216; kt_tcookie=1; kt_is_visited=1; bulFreq_jz13qrwb=1&2&3&4&5&6&7&8; bulExpir_jz13qrwb=1591107717300; bulLoad_jz13qrwb=9; _ga=GA1.2.1062644397.1591104919; _gid=GA1.2.1871591381.1591104919; kt_member=94804a54d6960d80f4b38ccf30ac524b; aawintermission=1; aawsmackeroo0=1"])
            .fileDestination({ (url, response) -> (targetURL: URL, options: HTTPDownloadRequestBuilder.DestinationFileOptions) in
                return (
                    URL(fileURLWithPath: "/Users/somesh-8758/Downloads/somefile.mp4")
                    ,
                    []
                )
            })
            .completionHandler({ _ in
                semaphore.signal()
                print("Downloaded Successfully")
            })
            .build()
        
        semaphore.wait()
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
