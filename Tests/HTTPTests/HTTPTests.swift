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
                        print(String(format: "%.2f", $0.fractionCompleted * 100.0) ,
                        String(format: "Size: %.2f", CGFloat($0.completedUnitCount)/CGFloat(1024*1024)))
                    })
                    .fileDestination({ (url, response) -> (targetURL: URL, options: HTTPDownloadRequest.DestinationFileOptions) in
                        return (
                            URL(fileURLWithPath: "/Users/somesh-8758/Downloads/\(url.lastPathComponent)")
                            ,
                            []
                        )
                    })
                    .completionHandler({
                        print($0.value.path)
                    })
                    .build()
        }
        sleep(100)
    }
    
    var request: HTTPDownloadRequest!
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
                
                print(String(format: "%.2f", $0.fractionCompleted * 100.0) ,
                      String(format: "Size: %.2f", CGFloat($0.completedUnitCount)/CGFloat(1024*1024)))
            })
            .header(["Cookie" : "PHPSESSID=deka0qaeo8d5735hp1ddiqb9h2; kt_ips=185.220.101.198; kt_tcookie=1; kt_is_visited=1; bulFreq_jz13qrwb=1&2&3&4&5&6&7&8; bulExpir_jz13qrwb=1590856950700; bulLoad_jz13qrwb=5; _ga=GA1.2.1760350831.1590854152; _gid=GA1.2.1841866655.1590854152; aawintermission=1; kt_member=392f5652b57bb8cb654c2f16b1e5ffa8; aawsmackeroo0=1"])
            .fileDestination({ (url, response) -> (targetURL: URL, options: HTTPDownloadRequest.DestinationFileOptions) in
                print(response?.mimeType)
                return (
                    URL(fileURLWithPath: "/Users/somesh-8758/Downloads/dani.mp4")
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
