import XCTest
@testable import HTTP

struct User: Codable {
    var userid: Int? = 1
    var id: Int
    var title: String
    var completed: Bool
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
        /*
            .downloadRequestBuilder { (builder) in
                builder
                    .url("https://image.shutterstock.com/image-photo/bright-spring-view-cameo-island-260nw-1048185397.jpg")
                    .catch({
                        print($0.value.localizedDescription)
                    })
                    .progressHandler({
                        print($0.percentage, $0.formattedCompletedSize(in: .mb))
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
        */
        sleep(100)
    }
    
    var request: HTTPRequest!
    var timer: Timer!
    func testDownloadRequest() {
        let semaphore = DispatchSemaphore(value: 0)
        var date = Date()
        var bytesWritten: Int64 = 0
        var currentSpeed: Double = 0
        request = HTTP.shared
            .downloadRequestBuilder()
            .url(URL(string: "https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_12_beta_6/Xcode_12_beta_6.xip"))
            .catch({
                self.request.resume()
                print($0.value.localizedDescription)
            })
            .progressHandler({
                let currentDate = Date()
                let elapsedTime = currentDate.timeIntervalSince(date)
                bytesWritten += $0.bytesWritten
                if elapsedTime >= 1.0 {
                    currentSpeed = Double(bytesWritten)/1024
                    currentSpeed /= elapsedTime
                    date = currentDate
                    bytesWritten = 0
                }
                print("Percentage: \($0.percentage)%\t\t","Completed: \($0.formatteDynamicCompletedSize())  of  \($0.formattedDynamicTotalSize())\t Speed: \(Int(currentSpeed))KB/s")
            })
            .header(["Cookie" : "s_cc=true; s_fid=6A69BF932FC35D6E-2E09A11DBBC280B1; s_sq=%5B%5BB%5D%5D; s_vi=[CS]v1|2F7046C00515AF33-4000066EA4482AB2[CE]; s_vnum_n2_us=19|3,4|5; ADCDownloadAuth=UN%2BQrGHzHRviPE2NB7bBIMLOPWwWwKm7g2bETcFmemEVFHwp6P3QJeWPFICUs2Wq4Ko68J9%2Fva5g%0D%0Alvq6gOk1zJyDArfNDfytlFNaEmneuvOIt1c1v24oEtXuh5I0L33NLje%2Bv%2BwLh7bCBDdGYG1VJjQX%0D%0AcfKWMOMRXq1UKg5XyLLNK%2FgZ%0D%0A; PHPSESSID=1fd02a81cce3a008b0785d3b56494fc6; dslang=US-EN; DSESSIONID=74a1av21mg63inml3176jna775917k2vun60l2um6v5u0affe4o; acn01=NvEs2j/QDZfn/plRnODuDGMTM3zGTA/j/gAAieDniOwX; myacinfo=DAWTKNV20c58aff606155624db9265f93372f699f0edc53602ce5d7a5cbe55f453bffda43c9993405363482f86fe4fd336f4d99846e5d6d5a60743b84181b4455a1b1352ca5f6e682ff240ac9f8e022b0bd286b7fe1a82b803f48edc9d90e7844452697962dd50b50775abf788433effeb820a6acb988e1495587e6b58fb391b82bb0f39517d22c303adf3d2025527d96ae52ebbfa65ab5aa3aa662888ac7c8405fd155756b9f23f664fc7d5d26f852e8abf33c95eacdeb4b359e22d42af9d9cb3602bc1e17823b2d4010b6397221c6ca51fa3dea075ab5f7abd9740ade18b50e1f6aab6a4818eaaf06a2aad0655e1a9d255641003ef935e72f82b14ab1d2eb4808c38b831613166633962366162623066346263616433336663326431616635636231633661306434666236MVRYV2; site=USA; ccl=lQ7DEOBZAxxdAmugNmFsbA==; geo=IN; XID=995bfed7812b5f882ba5f4571e9d30af; dssf=1; dssid2=18917336-ba2d-4293-bd88-59006a6b8625; itspod=34; xp_ab=1#Jv0scgz+-2+GY7ecau1#WqjkRLH+-2+dGTt92c2#isj11bm+-2+fSkdyx_1; xp_abc=dGTt92c2#fSkdyx_1; commerce-authorization-token=AAAAAAAAAAGF0CY1vF9HvVzewUwxDxKqWiMyfdE9JLPfHn1u3eEUyWjO5Zz/hAsPRbT8Ah5i9ar3oBBYv8qD8FnbMO1/0Off2hGHTqklTD/49+Dy6FfSNaOw3BMhRTk6bOcvMnmEYc4q4TTeIPblgUwsIGf3ZWmW4YkWE21tXdKTAuwJexKxbOIrXO5VR+berXyZFvXY+zwG65/msUmSckyipSkfdsBCiMuJTDz6JhBVlP4QWCtUReFIBmLRpKTfLx172pNhXiHZjczbb9oC/RQmHD5V7K0+tt6uPhZKBksy8rxOxHIvJg==; commerce-ds-session-id=ESWZ00002428d61a761d96116b5a8c65b7ef3cb85eVKZZDUDON1eed5f24-9c6c-4333-861d-988dfb8b4b4e51473079c87b86b782e86024e9f192e23c376d86b09b400885586c1da17fdce387eb8971569ec24d16fff14b9a945070ac0d210d502e010c5f48cf3984697170a172bb52a2921bd9c56b169db943afc4d490f62c5243d310ff664b60f6abcb091ab8ff037a44e955535d1cff5c47d56ee148010fbdda9de7e5b5301c8ca1189420611a9f8fecb8f5d548aeb6237d64753532ce1101b624aa2c2dcb8c3cf1f2ca3070229312a85031d24293da04d13ee56074de08ea88eb7ddb144f13186aa226585a47; optimizelyBuckets=%7B%7D; optimizelySegments=%7B%22341793217%22%3A%22direct%22%2C%22341794206%22%3A%22false%22%2C%22341824156%22%3A%22safari%22%2C%22341932127%22%3A%22none%22%7D; as_sfa=Mnx1c3x1c3x8ZW5fVVN8Y29uc3VtZXJ8aW50ZXJuZXR8MHwwfDE; xp_ci=3z44MJQSzFitz4UNzBcPzHg1dluPG; optimizelyEndUserId=oeu1591940731215r0.29064960202022894; pxro=2"])
            .fileDestination({ (_, _) -> (targetURL: URL, options: HTTPDownloadRequestBuilder.DestinationFileOptions) in
                return (
                    URL(fileURLWithPath: "/Users/somesh-8758/Downloads/Xcode_12_beta_6.xip")
                    ,
                    []
                )
            })
            .completionHandler({ _ in
                print("Downloaded Successfully")
                //bash.execute(commandName: "pmset", arguments: ["sleepnow"])
                semaphore.signal()
            })
            .build()
        
        semaphore.wait()
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
