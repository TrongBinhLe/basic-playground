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
/*---------- III. COMBINE - TRANSFORMING OPERATORS----------------------*/

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

//--------4. REPLACING UPSTREAM OUTPUT --------
//4.1. replaceNil(with:)
["A",  nil, "B"].publisher
        .replaceNil(with: "-")
        .sink { print($0) }
//4.2. replaceEmpty(with:)
let empty = Empty<Int, Never>()
    empty
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)

//-------------5. SCAN----------------------
/**Tạo 1 publisher bằng cách biến đổi 1 Array Integer từ 0 tới 5 thông qua toán tử publisher
 Biển đổi từng phần tử của pub bằng toán tử scan với giá trị khởi tạo là 0
 Scan sẽ phát ra các phần tử mới bằng cách kết hợp 2 giá trị lại
 Cái khởi tạo là đầu tiên -> cái nhận được là thứ 2 -> cái tạo ra mới được phát đi và trở thành lại cái đầu tiên.*/

//VD1
let pub = (0...5).publisher
    
    pub
        .scan(0) { $0 + $1 }
        .sink { print ("\($0)", terminator: " ") }
        .store(in: &subscriptions)

//VD2

let publs = (1...10).publisher
publs.scan([]) { numbers, value -> [Int] in
    numbers + [value]
}.sink {
    print($0)
    
}

//-----------IV> COMBINE – FILTERING OPERATORS-----------------
/**---1.1FILTER
 Sử dụng toán tử filter để tiến hành lọc các phần tử được phát ra từ publisher. Dễ hiểu nhất là thử làm việc với 1 closure trả về giá trị bool
 **/

let numbers = (1...10).publisher
numbers
    .filter { $0.isMultiple(of: 3) }
    .sink { n in
        print("\(n) is a multiple of 3!")
    }
    .store(in: &subscriptions)


/*1.2.---------- REMOVE DUPLICATES*/
//Chú ý, toán tử removeDuplicates chỉ bỏ đi các phần tử liên tiếp mà giống nhau, giữ lại duy nhất một phần tử. Còn nếu các phần tử giống nhau mà không liên tiếp thì vẫn bình thường.

let words = "Hôm nay nay , trời trời nhẹ lên cao cao . Tôi Tôi buồn buồn không hiểu vì vì sao tôi tôi buồn."
    .components(separatedBy: " ")
    .publisher
words
    .removeDuplicates()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

/**2. ------------------COMPACTING AND IGNORE------------------*/
//-----------2.1. COMPACTMAP ---------------
//Hiểu đơn giản thì nó cũng như map, biến đổi các phần tử với kiểu giá trị này thành kiểu giá trị khác và lượt bỏ đi các giá trị không đạt theo điều kiện.

let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
strings
    .compactMap { Float($0) }
    .sink(receiveValue: {  print($0) })
    .store(in: &subscriptions)

//----------2.2. IGNOREOUTPUT--------------
/*Với toán tử ignoreOutput , thì sẽ loại trừ hết tất cả các phần tử được phát ra. Tới lúc nhận được completion thì sẽ kết thúc.*/
let numb = (1...10_000_000).publisher
numb
    .ignoreOutput()
    .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
    .store(in: &subscriptions)

/*------------3. FINDING VALUES---------------*/

//------3.1. first(where:)--------------------
/*
 Ta có 1 Array Int từ 0 đến 9 và biến nó thành 1 publisher.
 Sau đó dùng hàm print với tiền tố in ra là numbers –> để kiểm tra các giá trị có nhận được lần lượt hay không?
 Sử dụng toán tử first để tìm giá trị đầu tiên phù hợp với điều kiện là chia hết cho 2
 Sau đó subscription nó và in giá trị nhận được ra.
 Ta thấy, sau khi gặp giá trị đầu tiền phù hợp điều kiện thì publisher sẽ gọi completion.
 */
let numbs = (1...9).publisher
numbs
  .print("numbers")
  .first(where: { $0 % 2 == 0 })
  .sink(receiveCompletion: { print("Completed with: \($0)") },
        receiveValue: { print($0) })
  .store(in: &subscriptions)

//--------3.2. last(where:)----------------

/*
 Đối trọng lại với first. Sẽ tìm ra phần tử cuối cùng được phát đi phù hợp với điều kiện. Miễn là trước khi có completion
 */
let numbers1 = PassthroughSubject<Int, Never>()
numbers1
  .last(where: { $0 % 2 == 0 })
  .sink(receiveCompletion: { print("Completed with: \($0)") },
        receiveValue: { print($0) })
  .store(in: &subscriptions)
numbers1.send(1)
numbers1.send(2)
numbers1.send(3)
numbers1.send(4)
numbers1.send(5)
numbers1.send(completion: .finished)


//--------4.Dropping Values---------------
// Các toán tử này sẽ giúp loại bỏ đi nhiều phần tử. Mà không cần quan tâm gì nhiều tới điều kiện. Chỉ quan tâm tới thứ tự và số lượng.

//------- 4.1. dropFirst
// Toán tử này sẽ có 1 tham số là số lượng các giá trị sẽ được bỏ đi. Với ví dụ trên thì phần tử thứ 9 sẽ được in ra, các phần tử trước nó sẽ bị loại bỏ đi.
let numbers2 = ["a","b","c","e","f","g","h","i","k","l","m","n"].publisher
    numbers2
        .dropFirst(8)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
//--------4.2. drop(while:)-------------
/*Toán tử này là phiên bản nâng cấp hơn. Khi bạn không xác định được số lượng các phần tử cần phải loại trừ đi. Thì sẽ đưa cho nó 1 điều kiện.
 Và trong vòng while, thì phần tử nào thoả mãn điều kiện sẽ bị loại trừ. Cho đến khi gặp phần tử đầu tiên không toản mãn.
 Từ phần tử đó trở về sau (cho đến lúc kết thúc) thì các subcribers sẽ nhận được các giá trị đó
 */
let numbers3 = (1...10).publisher
numbers3
  .drop(while: {
    print("x")
    return $0 % 5 != 0
  })
  .sink(receiveValue: { print($0) })
  .store(in: &subscriptions)

//-------4.3. drop(untilOutputFrom:) -------------
/*Một bài toán được đưa ra như sau:
Bạn tap liên tục vào một cái nút
Lúc nào có trạng thái isReady thì sẽ nhận giá trị từ cái nút bấm đó*/
let isReady = PassthroughSubject<Void, Never>()
 let taps = PassthroughSubject<Int, Never>()
 
 taps
   .drop(untilOutputFrom: isReady)
   .sink(receiveValue: { print($0) })
   .store(in: &subscriptions)
 
 (1...15).forEach { n in
   taps.send(n)
   
   if n == 3 {
     isReady.send()
   }
 }


 /**
  isReady là 1 subject. Với kiểu Void nên chi phát tín hiệu chứ không có giá trị được gởi đi
  taps là một subject với Output là Int
  Tiến hành subcription taps, trước đó thì gọi toán tử drop(untilOutputFrom:) để lắng nghe sự kiện phát ra từ isReady
  For xem như là chạy liên tục, mỗi lần thì taps sẽ phát đi 1 giá trị
  Với n == 3, thì isReady sẽ phát
  */


//------------5. Limiting values----------------
/*
 Đối trọng với drop thì toán tử prefix sẽ làm điều ngược lại ngược lại:
 prefix(:) Giữ lại các phần tử từ lúc đầu tiên tới index đó (với index là tham số truyền vào)
 prefix(while:) Giữ lại các phần tử cho đến khi điều kiện không còn thoả mãn nữa
 prefix(untilOutputFrom:) Giữ lại các phần tử cho đến khi nhận được sự kiện phát của 1 publisher khác
 */
let numbers4 = (1...10).publisher
  
  numbers4
    .prefix(2)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
//Giữa lại 2 phần tử đầu tiên nhận được, các phần tử còn lại thì bỏ qua
let numbers5 = (1...10).publisher
  numbers5
    .prefix(while: { $0 < 7 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
//Các phần tử đầu tiên mà bé hơn 7 thì sẽ được in ra. Tại phần tử nào mà đã thoả mãn điều kiện, thì từ đó trở về sau sẽ bị skip.
let isReady1 = PassthroughSubject<Void, Never>()
let taps1 = PassthroughSubject<Int, Never>()
  taps
    .prefix(untilOutputFrom: isReady1)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  (1...15).forEach { n in
    taps1.send(n)
    
    if n == 5 {
      isReady.send()
    }
  }


//---------V.COMBINE – COMBINING OPERATORS --------

//--------1. PREPENDING----------------
//--------1.1. prepend(Output)
let publisher9 = [3, 4].publisher
    publisher9
        .prepend(1, 2)
        .prepend(-2, -1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
/*Xem đoạn code trên ta thấy:
Có thể gọi prepend nhiều lần
Không giới hạn số lượng giá trị truyền vào
Cái sau sẽ in ra trước, nghĩa là: -2 -> -1 -> 0 -> 1 -> 2 -> 3 -> 4
*/

// -------1.2. prepend(Sequence)-------

let publisher11 = [5, 6, 7].publisher
  
  publisher11
    .prepend([3, 4])
    .prepend(Set(1...2))
    .prepend(stride(from: 6, to: 11, by: 2))
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

//-------1.3. prepend(Publisher)------
//2 toán tử trên thì bạn cần có dữ liệu có sẵn và không chủ động trong việc thay đổi. Còn với toán tử này sử dụng 1 publisher để chuẩn bị thì mọi việc có vẻ vui hơn
//Nhìn qua thì khá dễ hiểu. publisher1 được chuẩn bị các giá trì từ publisher2. Nó sẽ in hết giá trị của publisher2 ra mới đến publisher1

let publ1 = [3, 4].publisher
let publ2 = [1, 2].publisher
  
  publ1
    .prepend(publ2)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

//Tiếp tục nào:
let publ3 = [3, 4].publisher
let publ4 = PassthroughSubject<Int, Never>()
  
  publ3
    .prepend(publ4)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
  publ4.send(1)
  publ4.send(2)
  publ4.send(completion: .finished)

//Khi sử dụng prepend thì tới khi nào publisher trong tham số, có completion thì các giá trị của nó mới được phát đi. Sau đó mới tới các giá trị của publisher chính.


//------------2.APPENDING------
// Ngược lại với prepend thì append bổ sung các giá trị ra phía sau cùng cho publisher. Điều quan trọng là các giá trị đó sẽ được phát sau khi publisher phát đi completion.
let publisher14 = PassthroughSubject<Int, Never>()
  publisher14
    .append(3, 4)
    .append(5)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  publisher14.send(1)
  publisher14.send(2)
  publisher14.send(completion: .finished)


//---------3. ADVANCED COMBINING ---------


//--- 3.1. SWITCHTOLASTEST
/*Dùng trong trường hợp kết hợp nhiều publisher. Và bạn chỉ cần publisher nào cuối cùng phát ra giá trị thì nhận nó.
 */
let publisher01 = PassthroughSubject<Int, Never>()
  let publisher02 = PassthroughSubject<Int, Never>()
  let publisher03 = PassthroughSubject<Int, Never>()
  // 2
  let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
  // 3
  publishers
    .switchToLatest()
    .sink(receiveCompletion: { _ in print("Completed!") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  // 4
  publishers.send(publisher01)
  publisher01.send(1)
  publisher01.send(2)
  // 5
  publishers.send(publisher02)
  publisher01.send(3)
  publisher02.send(4)
  publisher02.send(5)
  // 6
  publishers.send(publisher03)
  publisher02.send(6)
  publisher03.send(7)
  publisher03.send(8)
  publisher03.send(9)
  // 7
  publisher03.send(completion: .finished)
  publishers.send(completion: .finished)


//Tạo các publisher với Output là Int
//Tạo 1 publisher để gọp các publisher kia, với Output chính là publisher với kiểu Output là Int
//Sử dụng toán tử switchToLastest cho publishers và tiến hành subscription nó để in các giá trị nhận được
//publishers send đi publisher1 –> publisher1 send đi 1 và 2 –> nhận được 1 & 2
//publishers send đi publisher2 –> 1 phát 3, không nhận đc 3 –> 2 phát 4 & 5, nhận đc 4 & 5
//Sau khi send publisher3 đi thì 2 phát 6 sẽ không nhận đc
//Gởi kết thúc

//Đoạn code ví dụ cho việc áp dụng vào bài toán thực tiễn trong ứng dụng. Khi nhấn vào nút download thì sẽ download 1 image. Nếu như nhấn liên tiếp rất nhiều lần thì sẽ lấy cái cuối cùng.
let url = URL(string: "https://source.unsplash.com/random")!
  // 1
  func getImage() -> AnyPublisher<UIImage?, Never> {
      return URLSession.shared
                       .dataTaskPublisher(for: url)
                       .map { data, _ in UIImage(data: data) }
                       .print("image")
                       .replaceError(with: nil)
                       .eraseToAnyPublisher()
  }
  // 2
  let taps2 = PassthroughSubject<Void, Never>()
  taps2
    .map { _ in getImage() } // 3
    .switchToLatest() // 4
    .sink(receiveValue: { _ in })
    .store(in: &subscriptions)
  // 5
  taps2.send()
  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    taps2.send()
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
    taps2.send()
  }


//-------------3.2. MERGE(WITH:)-------------------
let publisher04 = PassthroughSubject<Int, Never>()
let publisher05 = PassthroughSubject<Int, Never>()
 publisher04
   .merge(with: publisher05)
   .sink(receiveCompletion: { _ in print("Completed") },
         receiveValue: { print($0) }).store(in: &subscriptions)
 publisher04.send(1)
 publisher05.send(2)
 publisher05.send(3)
 publisher04.send(4)
 publisher05.send(5)
 publisher04.send(completion: .finished)
 publisher05.send(completion: .finished)

//Tạo ra 2 em publisher
//Merge em 2 và em 1
//2 em thay nhau bắn cho tới khi kết thúc
//Và khi nào cả 2 publisher kết thúc thì mới kết thúc chung


// ------3.3. combineLastest----------------

let publisher06 = PassthroughSubject<Int, Never>()
let publisher07 = PassthroughSubject<String, Never>()
  // 2
  publisher06
    .combineLatest(publisher07)
    .sink(receiveCompletion: { _ in print("Completed") },
          receiveValue: { print("P1: \($0), P2: \($1)") })
    .store(in: &subscriptions)
  // 3
  publisher06.send(1)
  publisher06.send(2)
  
  publisher07.send("a")
  publisher07.send("b")
  
  publisher06.send(3)
  
  publisher07.send("c")
  // 4
  publisher06.send(completion: .finished)
  publisher07.send(completion: .finished)

//P1: 2, P2: a
//P1: 2, P2: b
//P1: 3, P2: b
//P1: 3, P2: c
//Completed

/* Giải thích:
Tạo ra 2 publisher với các kiểu Output lần lượt là Int & String
Sử dụng toán tử combineLastest cho 2 publisher & subscription như bao lần trước đây
Sử dụng publisher1 phát 1 và 2 -> không có gì xảy ra. Vì publisher2 chưa có giá trị nào hết
Publisher2 bắn a & b -> nhận được 2,a và 2,b
publisher1 bắn 3 -> nhận đc 3,b
publisher2 bắn c -> nhận được 3,c
Kết thúc cả 2 cùng kết liễu. */



// ------3.4 ZIP-------------
/*
Đây là toán tử khá là thú vị, nó tương tự như kiểu Tuple trong Swift, bằng cách kết hợp nhiều kiểu giá trị lại với nhau.
Còn trong Combine thì đó là sự kết hợp các Output của các publisher lại.
Với zip thì nó sẽ chờ & nén từng cặp giá trị lại với nhau. Ví dụ:
pub1 phát 1 & 2
pub2 phát a & b
nhận được 2 cái (1,a) & (2,b)
Khi nào đủ Output thì nó sẽ phát cho subscriber các cặp giá trị.  */


let publisher08 = PassthroughSubject<Int, Never>()
let publisher09 = PassthroughSubject<String, Never>()
publisher08
  .zip(publisher09)
  .sink(receiveCompletion: { _ in print("Completed") },
        receiveValue: { print("P1: \($0), P2: \($1)") })
  .store(in: &subscriptions)
publisher08.send(1)
publisher08.send(2)
publisher09.send("a")
publisher09.send("b")
publisher08.send(3)
publisher09.send("c")
publisher09.send("d")
publisher08.send(completion: .finished)
publisher09.send(completion: .finished)

/*
Và đây là kết quả chương trình:
P1: 1, P2: a
P1: 2, P2: b
P1: 3, P2: c
Completed */

// -------------VI.COMBINE – TIME MANIPULATION OPERATORS -------------------

// --------------1. DELAY -----------------------

let valuesPerSecond = 1.0
let delayInSeconds = 2.0

let sourcePublisher = PassthroughSubject<Date, Never>()
let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)

// subcription

sourcePublisher.sink { completed in
    print("Source completed: ", completed)
} receiveValue: { print("Source: ", $0) }.store(in: &subscriptions)

delayedPublisher
   .sink(receiveCompletion: { print("Delay complete: \($0) - \(Date()) ") }) { print("Delay: \($0) - \(Date()) ")}
   .store(in: &subscriptions)

//emit values by timer
DispatchQueue.main.async {
    var runCount = 0
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        sourcePublisher.send(Date())
        runCount += 1
        if runCount > 10 {
            timer.invalidate()
            runCount = 0
            sourcePublisher.send(completion: .finished)
        }
    }
}

/*Giải thích:
sourcePublisher là 1 subject
delayPublisher được tạo ra nhờ toán tử delay của publisher trên
Tiến hành subscription và cứ mỗi giây cho sourcePublisher phát đi
Thì sau 1 khoảng thời gian được cài đặt trên thì delayPublisher sẽ phát tiếp */

// ------------2. COLLECTING VALUES ----------------

let valuesPerSecond1 = 1.0
let collectTimeStride1 = 4
let sourcePublisher1 = PassthroughSubject<Int, Never>()
let collectedPublisher1 = sourcePublisher
        .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride1)))
        .flatMap { dates in dates.publisher }
//subscription
sourcePublisher1
    .sink(receiveCompletion: { print("\(Date()) - 🔵 complete: ", $0) }) { print("\(Date()) - 🔵: ", $0)}
    .store(in: &subscriptions)
collectedPublisher1
   .sink(receiveCompletion: { print("\(Date()) - 🔴 complete: \($0)") }) { print("\(Date()) - 🔴: \($0)")}
   .store(in: &subscriptions)
DispatchQueue.main.async {
    sourcePublisher1.send(0)
  
    var count = 1
    Timer.scheduledTimer(withTimeInterval: 1.0 / valuesPerSecond, repeats: true) { _ in
        sourcePublisher1.send(count)
        count += 1
        if(count > 10 ){
            sourcePublisher1.send(completion: .finished)
        }
    }
}


/*
 Result :
 2020-03-02 08:49:01 +0000 - 🔵:  0
 2020-03-02 08:49:02 +0000 - 🔵:  1
 2020-03-02 08:49:03 +0000 - 🔵:  2
 2020-03-02 08:49:04 +0000 - 🔵:  3
 2020-03-02 08:49:05 +0000 - 🔴: 0
 2020-03-02 08:49:05 +0000 - 🔴: 1
 2020-03-02 08:49:05 +0000 - 🔴: 2
 2020-03-02 08:49:05 +0000 - 🔴: 3
 2020-03-02 08:49:05 +0000 - 🔵:  4
 2020-03-02 08:49:06 +0000 - 🔵:  5
 2020-03-02 08:49:07 +0000 - 🔵:  6
 2020-03-02 08:49:08 +0000 - 🔵:  7
 2020-03-02 08:49:09 +0000 - 🔴: 4
 2020-03-02 08:49:09 +0000 - 🔴: 5
 2020-03-02 08:49:09 +0000 - 🔴: 6
 2020-03-02 08:49:09 +0000 - 🔴: 7
 2020-03-02 08:49:09 +0000 - 🔵:  8
 2020-03-02 08:49:10 +0000 - 🔵:  9
 ...
 
 Tạo 1 publisher từ 1 PassthroughSubject với Output là Int
 Tạo tiếp 1 publisher nữa từ publisher trên với toán tử collect
 Tiến hành subscription 2 publisher để xem giá trị sau mỗi lần nhận được
 Cho vào vòng lặp vô tận để quan sát kết quả
 Ta thấy
 Nếu không có flatMap thì cứ sau 1 khoản thời gian được cài đặt collectTimeStride thì các giá trị sẽ được thu thập. Và kiểu giá trị của nó là một Array
 Sử dụng flatMap để biến đổi chúng cho dễ nhìn hơn
 
 Bỏ flatMap thì kết quả in ra trông như thế này:
 2020-03-02 08:53:30 +0000 - 🔵:  0
 2020-03-02 08:53:31 +0000 - 🔵:  1
 2020-03-02 08:53:32 +0000 - 🔵:  2
 2020-03-02 08:53:33 +0000 - 🔵:  3
 2020-03-02 08:53:34 +0000 - 🔴: [0, 1, 2, 3]
 2020-03-02 08:53:34 +0000 - 🔵:  4
 2020-03-02 08:53:35 +0000 - 🔵:  5
 2020-03-02 08:53:36 +0000 - 🔵:  6
 2020-03-02 08:53:37 +0000 - 🔵:  7
 2020-03-02 08:53:38 +0000 - 🔴: [4, 5, 6, 7]
 2020-03-02 08:53:38 +0000 - 🔵:  8
 2020-03-02 08:53:39 +0000 - 🔵:  9
 2020-03-02 08:53:40 +0000 - 🔵:  10
 2020-03-02 08:53:41 +0000 - 🔵:  11
 2020-03-02 08:53:42 +0000 - 🔴: [8, 9, 10, 11]
 2020-03-02 08:53:42 +0000 - 🔵:  12
 ...
 let collectedPublisher2 = sourcePublisher
         .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
         .flatMap { dates in dates.publisher }

 Ta chú ý điểm byTimeOrCount, có nghĩa là:
 Nếu đủ số lượng thu thập theo collectMaxCount –> thì sẽ bắn giá trị đi
 Nếu chưa đủ giá trị mà tới thời gian thu thập collectTimeStride thì vẫn gom hàng và bắn
 */


//--------3. HOLDING OFF ON EVENT---------------

//3.1. DEBOUNCE

func printDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.S"
    return formatter.string(from: Date())
}

let typingHelloWord: [(TimeInterval, String)] = [
      (0.0, "H"),
      (0.1, "He"),
      (0.2, "Hel"),
      (0.3, "Hell"),
      (0.5, "Hello"),
      (0.6, "Hello "),
      (2.0, "Hello W"),
      (2.1, "Hello Wo"),
      (2.2, "Hello Wor"),
      (2.4, "Hello Worl"),
      (2.5, "Hello World")
]

// subject
let sub = PassthroughSubject<String, Never>()
// debounce publisher

let debounce = sub.debounce(for: .seconds(1.0), scheduler: DispatchQueue.main).share()
// subscription
sub.sink { string in
    print("\(printDate()) - 🔵 : \(string)")
}.store(in: &subscriptions)

debounce.sink { string in
    print("\(printDate()) - 🔴 : \(string)")
}.store(in: &subscriptions)

// loop

let now = DispatchTime.now()
for item in typingHelloWord {
    DispatchQueue.main.asyncAfter(deadline: now + item.0) {
        sub.send(item.1)
    }
}

/*
 Giải thích:
 typingHelloWorld là để giả lập việc gõ bàn phím với kiểu dữ liệu là Array Typle gồm
 Thời gian gõ
 Ký tự gõ
 Tạo subject với Output là String
 Tạo tiếp debounce với time là 1.0 -> nghĩa là cứ sau 1 giây, nếu subject không biến động gì thì sẽ phát giá trị đi
 hàm share() để đảm bảo tính đồng nhất khi có nhiều subcriber subscribe tới nó
 Phần subscription để xem kết quả
 For và hẹn giờ lần lượt theo dữ liệu giả lập để subject gởi giá trị đi.
 
 15:59:39.0 - 🔵 : H
 15:59:39.1 - 🔵 : He
 15:59:39.2 - 🔵 : Hel
 15:59:39.4 - 🔵 : Hell
 15:59:39.6 - 🔵 : Hello
 15:59:39.7 - 🔵 : Hello
 15:59:40.7 - 🔴 : Hello
 15:59:41.2 - 🔵 : Hello W
 15:59:41.2 - 🔵 : Hello Wo
 15:59:41.2 - 🔵 : Hello Wor
 15:59:41.7 - 🔵 : Hello Worl
 15:59:41.7 - 🔵 : Hello World
 15:59:42.7 - 🔴 : Hello World
 */

// 3.2 THROTTLE
/*
 Cũng từ 1 publisher khác tạo ra, thông qua việc thực thi toán tử throttle
 Cài đặt thêm giá trị thời gian điều tiết
 Trong khoảng thời gian điều tiết này, thì nó sẽ nhận và phát giá trị đầu tiên hay mới nhất nhận được từ publisher gốc (dựa theo tham số latest quyết định)
 */
//create subject
let subthrottle = PassthroughSubject<String, Never>()
// throttle publshed
let throttle = subthrottle.throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: true).share()

subthrottle.sink { string in
    print("\(printDate()) - 🔵 : \(string)")
}.store(in: &subscriptions)

throttle.sink { string in
    print("\(printDate()) - 🔴 : \(string)")
}.store(in: &subscriptions)

for item1 in typingHelloWord {
    DispatchQueue.main.asyncAfter(deadline: now + item1.0) {
        subthrottle.send(item1.1)
    }
}

/**
 Giải thích:
 Ở giây thứ 0.0 thì chưa có gì mới từ subject và throttle bắt đầu sau 1.0 giây
 Tới thời điểm 1.0 thì có dữ liệu là Hello vì nó đc phát đi bởi subject ở 0.6
 Nhưng tới 2.0 thì vẫn không có gì mới để throttle phát đi vì subject lúc đó mới phát Hello cách
 Tới thời điểm 3.0 thì subject đã có Hello world ở 2.5 rồi, nên throttle sẽ phát được
 16:04:51.8 - 🔵 : H
 16:04:51.9 - 🔵 : He
 16:04:52.0 - 🔵 : Hel
 16:04:52.1 - 🔵 : Hell
 16:04:52.3 - 🔵 : Hello
 16:04:52.4 - 🔵 : Hello
 16:04:52.8 - 🔴 : Hello
 16:04:53.8 - 🔵 : Hello W
 16:04:54.1 - 🔵 : Hello Wo
 16:04:54.1 - 🔵 : Hello Wor
 16:04:54.4 - 🔵 : Hello Worl
 16:04:54.4 - 🔵 : Hello World
 16:04:54.8 - 🔴 : Hello World
 Tóm tắt nhanh 2 em này:
 debounce lúc nào source ngừng một khoảng thời gian theo cài đặt, thì sẽ phát đi giá trị mới nhất
 throttle không quan tâm soucer dừng lại lúc nào, miễn tới thời gian điều tiết thì sẽ lấy giá trị (mới nhất hoặc đầu tiên trong khoảng thời gian điều tiết) để phát đi. Nếu không có chi thì sẽ âm thầm skip
 */
//--------------4.TIMING OUT ------------------------

/*
 Toán tử này rất chi là dễ hiểu, bạn cần set cho nó 1 thời gian.
 Nếu quá thời gian đó mà publisher gốc không có phát bất cứ gì ra thì publisher timeout sẽ tự động kết thúc.
 Còn nếu có giá trị gì mới được phát trong thời gian timeout thì sẽ tính lại từ đầu.
 */

enum TimeOutError: Error {
    case timedOut
}

let subtimeout = PassthroughSubject<Void, TimeOutError>()

let timeOutPublish = subtimeout.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: {.timedOut})

subtimeout.sink(receiveCompletion: {print("\(printDate()) - 🔵 completion: ", $0)}){_ in print("\(printDate()) - 🔵 : event")}.store(in: &subscriptions)
timeOutPublish.sink(receiveCompletion: {print("\(printDate()) -  🔴 completion:", $0)}) { _ in print("\(printDate()) - 🔴 : event")}.store(in: &subscriptions)

print("\(printDate()) - BEGIN")

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    subtimeout.send()
}

//KQ:
/*
 16:09:56.6 - BEGIN
 16:09:58.8 - 🔵 : event
 16:09:58.8 - 🔴 : event
 16:10:03.9 - 🔴 completion:  failure(__lldb_expr_17.TimeoutError.timedOut)
 */
//----------VII. COMBINE SEQUENCE OPERATORS---------------
//----------1. FINDING VAULUES ---------------------------

// ---------1.1. MIN ---------------


//VD
let minsub = [1, -50, 246, 7].publisher

minsub.min().sink { value  in
    print("lowest value is \(value)")
}.store(in: &subscriptions)

let minBy = ["12345",
                   "ab",
                   "hello world"]
    .compactMap { $0.data(using: .utf8) } // [Data]
    .publisher // Publisher<Data, Never>
  minBy
    .print("publisher")
    .min(by: { $0.count < $1.count })
    .sink(receiveValue: { data in
      let string = String(data: data, encoding: .utf8)!
      print("Smallest data is \(string), \(data.count) bytes")
    })
    .store(in: &subscriptions)

/*
 Trong đó, 1 Array String mà các phần tử trong đó khó so sánh. Nên
 Dùng compactMap để biến đổi pulisher với Output là String thành publisher với Output là Data.
 Vai trò toán tử compactMap giúp loại bỏ đi các phần thử không biến đổi được.
 min(by:) sẽ dùng một closure để kiểm tra số byte của 1 phần tử
 sink để subscribe và in ra giá trị như mình mong muốn
 */

//--------1.2.MAX---------------

//Tương tự như min và cũng có 2 cách sử dụng cho 2 kiểu đối tượng (so sánh được & không so sánh được).
let max = ["A", "F", "Z", "E"].publisher
  max
    .print("publisher")
    .max()
    .sink(receiveValue: { print("Highest value is \($0)") })
    .store(in: &subscriptions)

//---------1.3.FIRST-----------

//---------1.5. LAST AND LAST(WHERE:)
//Tương tự như first. Nhưng ngược lại. Chỉ khi nào publisher phát đi completion, thì mới tìm kiến phần tử giá trị cuối cùng được phát ra.
let last = ["A", "B", "C"].publisher
  last
    .print("publisher")
    .last()
    .sink(receiveValue: { print("Last value is \($0)") })
    .store(in: &subscriptions)

//---------1.6.OUTPUT(AT:)
//Tìm kiếm phần tử theo chỉ định index trên upstream của publisher.
let outputPub = ["A", "B", "C"].publisher
  outputPub
    .print("publisher")
    .output(at: 1)
    .sink(receiveValue: { print("Value at index 1 is \($0)") })
    .store(in: &subscriptions)
//Khi nhận được B ở index (1), thì sẽ in giá trị ra và tự kết liễu mình.

//----------1.7. OutPut(IN:)
//Để lấy ra 1 lúc nhiều phần tử ở nhiều index khác nhau. Thay vì cung cấp 1 giá trị đơn lẽ, có thể cung cấp 1 array thứ tự cho toán tử output(in:)
//Xem code ví dụ sau:


 let outPutIN = ["A", "B", "C", "D", "E"].publisher
    outPutIN
    .output(in: 1...3)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print("Value in range: \($0)") })
    .store(in: &subscriptions)

//Sẽ lấy các giá trị trong range là 1, 2 và 3 trong các giá trị được publisher phát đi.

//-----------2.4. ALLSATISFY --------------
//Toán tử này sẽ phát ra giá trị là Bool khi tất cả các giá trị của publisher thoả mãn điều kiện của nó.
//Xem code ví dụ sau:
  // 1
  let allSatisfy = stride(from: 0, to: 5, by: 2).publisher
  // 2
  allSatisfy
    .print("publisher")
    .allSatisfy { $0 % 2 == 0 }
    .sink(receiveValue: { allEven in
      print(allEven ? "All numbers are even"
                    : "Something is odd...")
    })
    .store(in: &subscriptions)
//Trong đó:
//Tạo ra 1 publisher phát ra các giá trị từ 0 đến 5, với bước nhảy là 2. Nghĩa là 0, 2, 4
//Kiểm tra điều kiện là tất cả giá trị của publisher đó đều chia hết cho 2 không



//  --–```3. Future
Đây cũng là 1 Publisher đặc biệt. Tìm hiểu thử:
Là một Class
Là một Publisher
Đối tượng này sẽ phát ra một giá trị duy nhất, sau đó kết thúc hoặc fail.
Nó sẽ thực hiện một lời hứa Promise. Đó là 1 closure với kiểu Result, nên sẽ có 1 trong 2 trường hợp:
Success : phát ra Output
Failure : phát ra Error
Khi hoạt động
Lần subscribe đầu tiên, nó sẽ thực hiện đầy đủ các thủ tục. Và phát ra giá trị, sau đó kết thúc hoặc thất bại
Lần subscribe tiếp theo, chỉ phát ra giá trị cuối cùng. Bỏ qua các bước thủ thục khác.
----
