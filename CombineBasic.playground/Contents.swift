import UIKit
import Combine

/*********PUBLISHER TU PRORERTY CUA CLASS-------------------------***************
 
 //Để tránh việc ảnh hưởng tới code cũ trong dự án của bạn. Thì Combine cũng cung cấp thêm 1 wrapper cho property là @Published.
 Nó sẽ biến 1 store property truyền thống thành 1 Publisher. Khi sử dụng, bạn chỉ cần thêm từ khoá $ phái trước để dùng nó như 1 Publisher.
 Mọi thứ còn lại vẫn không thay đổi gì nhiều*/

class User {
    @Published var name: String
    @Published var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
}

let user = User(name: "Trong Binh Le", age: 30)
_ = user.$age.sink { print($0)
}

user.age = 31


/** ---------------- JUST ---------------- *********
 Đây là 1 Publisher đặc biệt. Nó sẽ phát ra 1 giá trị duy nhất tới subscriber và sau đó là finished. Khi khởi tạo 1 Just thì bạn cần phải cung cấp giá trị ban đầu cho nó.
 Kiểu giá trị của Output sẽ dựa vào kiểu giá trị bạn cung cấp.
 Giá trị của Just vẫn có thể là:
 value
 error
 finished
 */

let just = Just("Hello world")
//subscription 1
_ = just
    .sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })
//subscription 2
_ = just .sink(
  receiveCompletion: {
    print("Received completion (another)", $0)
  },
  receiveValue: {
    print("Received value (another)", $0)
})



/******************SUBJECT--------------------------****/

/*Với các kiểu trên, bạn sẽ thấy 1 điều là dữ liệu sẽ được phát đi. Tiếp theo là kết thúc. Như vậy thì lập trình bật đồng bộ ở đâu? và luồng dữ liệu bất đồng bộ ở đâu?
Cụ thể hơn, chúng ta sẽ cần 1 thứ, có thể phát dữ liệu đi bất cứ lúc nào nó muốn. Việc kết thúc cũng tuỳ ý nó quyết định.
Đó là Subject, và nó:
Ý nghĩa của Subject là nó cũng là 1 loại Publisher
Là thực thể kết nối giữa code Combine và Non-Combine
PassthroughSubject : lúc nào phát thì sẽ nhận được giá trị
CurrentValueSubject : không quan tâm lúc nào phát, chỉ cần subscription là có giá trị (cuối cùng)*/


/*  4.1. PassthroughSubject
PassthoughtSubject cho phép phát các giá trị đi. Cũng như các loại Publisher khác thì cũng cần phải khai báo kiểu Output & Failure. Khi các subcriber có cùng kiểu, thì mới có thể subcribe tới được.
Có thể có nhiều subscriber đăng kí tới. Tuy nhiên, chúng sẽ nhận được giá trị khi nào mà subject phát đi. Đây là điểm quan trọng nhất. Và sau khi subject kết thúc thì các subscription cũng kết thúc, nên các subscriber sẽ không nhận được gì thêm sau đó.*/

let subject = PassthroughSubject<Int, Never>()
// send value
subject.send(0)
//subscription 1
_ = subject.sink(receiveValue: { (value) in
  print("🔵 : \(value)")
})
// send values
subject.send(1)
subject.send(2)
subject.send(3)
subject.send(4)
//subscription 2
_ = subject.sink(receiveValue: { (value) in
  print("🔴 : \(value)")
})
// send value
subject.send(5)
// Finished
subject.send(completion: .finished)
// send value
subject.send(6)

/*4.2. CurrentValueSubject*
 Cũng là một loại Publisher đặc biệt. Nhưng subject này cho phép bạn:
 Khởi tạo với một giá trị ban đầu.
 Định nghĩa kiểu dữ liệu cho Output và Failure
 Khi một đối tượng subcriber thực hiện subcribe tới hoặc khi có một subscription mới. Thì lúc đó, Subject sẽ phát đi giá trị ban đầu (lúc khởi tạo) hoặc giá trị cuối cùng của nó.
 Tự động nhận được giá trị khi subscription, chứ không phải lúc nào phát thì mới nhận. Đây là điều khác biệt với PassThoughtSubject
 */

let subject1 = CurrentValueSubject<Int, Never>(0)
//subscription 1
_ = subject.sink(receiveValue: { (value) in
  print("🔵 : \(value)")
})
// send values
subject1.send(1)
subject1.send(2)
subject1.send(3)
subject1.send(4)
//subscription 2
_ = subject1.sink(receiveValue: { (value) in
  print("🔴 : \(value)")
})
// send value
subject1.send(5)
// Finished
subject1.send(completion: .finished)
// send value
subject1.send(6)


/**5.      --------------------------TYPE ERASURE--------------------------------
 Đôi khi bạn muốn subscribe tới publisher mà không cần biết quá nhiều về chi tiết của nó. Hoặc quá nhiều thứ đã biến đổi publisher của bạn. Bạn mệt mỏi khi nhớ các kiểu của chúng. Đây sẽ là giải pháp cho bạn:
 Type-erased publisher với class đại diện là AnyPublisher và cũng có quan hệ họ hàng với Publisher. Có thể mô tả như bạn có trải nghiệm déjà vu trong mơ. Nhưng sau này bạn sẽ thấy lại nó ở đâu đó, vì thực sự bạn đã thấy nó và nó đã xoá khỏi bộ nhớ của bạn. Đó là AnyPublisher (quá thật khó hiểu).
 Ngoài ra, ta còn có AnyCancellable cũng là 1 type-erased class. Bạn đã bắt gặp nó ở ví dụ trên. Các subscriber đều có quan hệ họ hàng với AnyCancellable & nó giúp cho quá trình tự huỷ của subscription xảy ra.
 Để tạo ra 1 type-erased publisher thì bạn sử dụng 1 subject và gọi 1 function eraseToAnyPublisher(). Khi đó kiểu giá trị cho đối tượng mới là AnyPublisher.
 Với AnyPublisher, thì không thể gọi function send(_:) được.
 Class này đã bọc và ẩn đi nhiều phương thức & thuộc tính của Publisher.
 Trong thực tế, bạn cũng không nên lạm dụng hay khuyến khích dùng nhiều kiểu này. Vì đôi khi bạn cần khai báo và xác định rõ kiểu giá trị nhận được.*/

var subscriptions = Set<AnyCancellable>()
//1: Tạo 1 Passthrough Subject
let subject2 = PassthroughSubject<Int, Never>()
//2: Tạo tiếp 1 publisher từ subject trên, bằng cách gọi function để sinh ra 1 erasure publisher
let publisher = subject2.eraseToAnyPublisher()
//3: Subscribe đối tượng type-erased publisher đó
publisher
.sink(receiveValue: { print($0) })
.store(in: &subscriptions)
//4: dùng Subject phát 1 giá trị đi
subject2.send(0)
//5: dùng erased publisher để phát --> ko đc : vì không có function này


