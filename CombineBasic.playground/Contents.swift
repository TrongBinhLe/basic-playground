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


//II. CUSTOM SUBSCRIBE

/*Khai báo phải kế thừa lại protocol Subscriber, trong đó:
Input là kiểu dữ liệu cho giá trị nhận được. Nó phải trùng với kiểu dữ liệu Output của Publisher.
Failure là kiểu dữ liệu cho error. Nếu không bao giờ nhận được error thì sử dụng Never.
Có 3 function tiếp theo cần phải implement:
receive(subscription:) : khi nhận được subscription từ Publisher. Lúc này Subscriber vẫn có quyền quyết định việc lấy bao nhiêu dữ liệu từ Publisher
receive(_ input:) : khi Publisher phát đi các dữ liệu thì Subscriber nhận được. Mỗi lần nhận như vậy thì Subscriber sẽ điều chỉnh lại việc request lấy thêm hay là không.
 Đối tượng sử dụng là Demand.
receive(completion:) : khi nhận được competion từ Publisher.
 
 
 Khi bạn đã có 1 đối tượng Subscriber. Và muốn đăng kí tới Publisher thì sử dụng hàm subscribe của Publisher.
 publisher.subscribe(subscriber)
 
 Và chỉ lúc nào subscriber kết nối tới, khi đó publisher mới phát đi dữ liệu. Đây là điều cực kì quan trọng trong Combine.
 Subscriber hỗ trợ việc tự huỷ khi subscription ngắt kết nối. Việc huỷ đó giúp cho bộ nhớ tự động giải phóng đi các đối tượng không cần thiết. Chúng ta có 2 kiểu huỷ:
 Tự động huỷ thông AnyCancellable, đó là việc tạo ra các subscriber bằng sink hoặc assign
 Huỷ bằng tay với việc subscriber gọi hàm cancel() của nó.
 
 //2. Cách tạo Subscriber
    2.1. Assign
 */

class Dog {
  var name: String
  
  init(name: String) {
    self.name = name
  }
}
let dog = Dog(name: "Pochi")
print("Dog name is \(dog.name)")

let subscriber = Subscribers.Assign(object: dog, keyPath: \.name)

//Tiến hành tạo publisher và phát dữ liệu đi.
let publisher1 = Just("Milu")
publisher1.subscribe(subscriber)
print("Dog name is \(dog.name)")


  // 2.2. Sink

let subscriber2 = Subscribers.Sink<String, Never> { completed in
    print(completed)
} receiveValue: { name  in
    dog.name = name
}

let publisher2 = PassthroughSubject<String, Never>()
publisher2.subscribe(subscriber2)

publisher2.send("Lu")
print("Dog name is \(dog.name)")
publisher2.send(completion: .finished)
print("Dog name is \(dog.name)")

/***____________**2.3. ANYCANCELABLE----__________
 Đây là 1 type-erasing class nhằm tạo ra 1 đối tượng sẽ tự động huỷ. Khi nó huỷ thì các subscription sẽ bị huỷ theo. Và các Subscriber có implement nó cũng tự động huỷ theo.
 Ngoài ra, nó còn cung cấp thêm 1 phương thức cancel để cho subscriber tuỳ ý tự huỷ.
 Từ Publisher thì với 2 function của nó là sink và assign sẽ tạo ra đối tượng AnyCancellable.
 
 */
//sink đính kèm theo 1 subscriber là 1 closure để xử lý các giá trị nhận được
let publisher4 = PassthroughSubject<String, Never>()
let cancellable = publisher4.sink(receiveCompletion: { (completion) in
  print(completion)
}) { (name) in
  dog.name = name
}
//assign  đưa dữ liệu phát ra tới property của 1 đối tượng.
let publisher5 = PassthroughSubject<String, Never>()
let cancellable1 = publisher4.assign(to: \.name, on: dog)

//Và 1 điều cần chú ý là bạn không thể tạo ra nhiều đối tượng cancellable cho một lần subscribe . Việc quản lý từng đứa như vậy cũng khá vất vả. Tốt nhất bạn cần phải quản lý tập trung.
var subscriptions1 = Set<AnyCancellable>()
let publisher6 = PassthroughSubject<String, Never>()
//subscription 1
publisher6
  .sink(receiveCompletion: { (completion) in
    print(completion)
  }) { (value) in
    print(value)
  }
  .store(in: &subscriptions1)
//subscription 2
publisher6
  .assign(to: \.name, on: dog)
  .store(in: &subscriptions1)


class ViewModel {
  //...
  var subscriptions = Set<AnyCancellable>()
  
  //...
  deinit {
    subscriptions.removeAll()
  }
}


/*********3. CUSTOM SUBSCRIBER-----------------*/
 /*3.1. Define Class
  Đây là phần chính của bài. Khi bạn muốn thứ của riêng mình, thì sao không thử việc tạo 1 class Subscriber riêng.
  Bắt đầu với việc define 1 class có tên là IntSubscriber kế thừa trực tiếp từ Subscriber
  */
final class IntSubscriber: Subscriber {
  
  typealias Input = Int
  typealias Failure = Never
  
  func receive(subscription: Subscription) {
    subscription.request(.max(1))
  }
  
  func receive(_ input: Int) -> Subscribers.Demand {
    print("Received value", input)
    return .unlimited
  }
  
  func receive(completion: Subscribers.Completion<Never>) {
    print("Received completion", completion)
  }
}

//Tiếp tục, tạo publisher và thử kết nối tới.
let publisher7 = (1...10).publisher
let subscriber4 = IntSubscriber()
publisher7.subscribe(subscriber4)

//https://fxstudio.dev/combine-transforming-operators-trong-10-phut/
/* III. COMBINE - TRANSFORMING OPERATORS*/

//2. Collecting values
//Với ví dụ trên, ta được 1 Array Int thay vì từng Int khi sử dụng .collect(). Còn nếu dùng collect(3), thì ta được mỗi giá trị là 1 Array Int với 3 phần tử Int.
var subscriptions2 = Set<AnyCancellable>()
let publisher8 = (1...99).publisher
publisher8
  .collect(10)
  .sink(receiveCompletion: { complete in
    print(complete)
  }) { value in
    print(value)
  }
  .store(in: &subscriptions2)


//3.----------------- Map ----------------------
/*Giải thích:
 Tạo ra một formatter của Number. Nhiệm vụ nó biến đổi từ số thành chữ
 Tạo ra 1 publisher từ một array Integer
 Sử dụng toán tử .map để biến đối tường giá trị nhận được thành kiểu string
 Các toán tử còn lại thì như đã trình bày các phần trước rồi*/
var subscriptions3 = Set<AnyCancellable>()
let formatter = NumberFormatter()
formatter.numberStyle = .spellOut
    [22, 7, 1989].publisher
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions3)
// 3.2. -------------------- Map key path ---------------------

struct Dog1 {
  var name: String
  var age: Int
}
let publisher10 = [Dog1(name: "MiMi", age: 3),
                 Dog1(name: "MiLy", age: 2),
                 Dog1(name: "PoChi", age: 1),
                 Dog1(name: "ChiPu", age: 3)].publisher
publisher10
  .map(\.name)
  .sink(receiveValue: { print($0) })
  .store(in: &subscriptions)
//Ta có class Dog
//Tạo 1 publisher từ việc biến đổi 1 Array Dog. Lúc này Output của publisher là Dog
//Sử dụng map(\.name) để tạo 1 publisher mới với Output là String. String là kiểu dữ liệu cho thuộc tính name của class Dog
//sink và store như bình thường

// 3.3 -------------TRYMAP------------------------

/*Khi bạn làm những việc liên quan tới nhập xuất, kiểm tra, media, file … thì hầu như phải sử dụng try catch nhiều. Nó giúp cho việc đảm bảo chương trình của bạn không bị crash. Tất nhiên, nhiều lúc bạn phải cần biến đổi từ kiểu giá trị này tới một số kiểu giá trị mà có khả năng sinh ra lỗi. Khi đó bạn hãy dùng tryMap như một cứu cánh. */

Just("Đây là đường dẫn tới file XXX nè")
        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
        .sink(receiveCompletion: { print("Finished ", $0) },
              receiveValue: { print("Value ", $0) })
        .store(in: &subscriptions)

//3.4 --------------- Flat Map -------------------
/*
 Trước tiên thì ta cần hệ thống lại một chú về em map và em flatMap
 map là toán tử biến đổi kiểu dữ liệu Output. Ví dụ: Int -> String…
 flatMap là toán tử biến đổi 1 publisher này thành 1 publisher khác
 Mới hoàn toàn
 Khác với thèn publisher gốc kia
 Thường sử dụng flatMap để truy cập vào các thuộc tính trong của 1 publisher. Để hiểu thì bạn xem minh hoạ đoạn code sau:
 Trước tiên tạo 1 struct là Chatter, trong đó có name và message. Chú ý, message là một CurrentValueSubject, nó chính là publisher.
 */

public struct Chatter {
    public let name: String
    public let message: CurrentValueSubject<String, Never>
    public init (name: String, message: String) {
        self.name = name
        self.message = CurrentValueSubject(message)
    }
}

let teo = Chatter(name:"Teo", message: "Teo join in room")
let ti = Chatter(name: "Ti", message: "Ti join in room")

let chat = PassthroughSubject<Chatter, Never>()
chat.flatMap {
    $0.message
}.sink { value in
    print(value)
}

chat.send(teo)
  //2 : Tèo hỏi
  teo.message.value = "TÈO: Tôi là ai? Đây là đâu?"
  //3 : Tí vào room
  chat.send(ti)
  //4 : Tèo hỏi thăm
  teo.message.value = "TÈO: Tí khoẻ không."
  //5 : Tí trả lời
  ti.message.value = "TÍ: Tao không khoẻ lắm. Bị Thuỷ đậu cmnr mày."
  
  let thuydau = Chatter(name: "Thuỷ đậu", message: " --- THUỶ ĐẬU đã vào room ---")
  //6 : Thuỷ đậu vào room
  chat.send(thuydau)
  thuydau.message.value = "THUỶ ĐẬU: Các anh gọi em à."
  
  //7 : Tèo sợ
  teo.message.value = "TÈO: Toang rồi."

/*chat là 1 publisher, chúng ta send các giá trị của nó đi (Chatter). Đó là các phần tử được join vào room
Vì mỗi phần tử đó có thuộc tính là 1 publisher (messgae). Để đối tượng chatter có thể phát tin nhắn đi, thay vì phải join lại room.  Nên khi subscribe nếu không dùng flatMap thì sẽ ko nhận được giá trị từ các stream của các publisher join vào trước.
flatMap giúp cho việc hợp nhất các stream của các publisher thành 1 stream và đại diện chung là 1 publisher mới với kiểu khác các publisher kia.
Tất nhiên, khi các publisher riêng lẻ send các giá trị đi, thì chat vẫn nhận được và hợp chất chúng lại cho subcriber của nó.
Cuối câu chuyện bạn cũng thấy là THUỶ ĐẬU đã join vào. Vì vậy, muốn khống chế số lượng publisher thì sử dụng thêm tham số maxPublishers */


chat
  .flatMap(maxPublishers: .max(2)) { $0.message }
  .sink { print($0) }
  .store(in: &subscriptions)

