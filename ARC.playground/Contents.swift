// Link reference: https://viblo.asia/p/tim-hieu-ve-automatic-reference-countingarc-va-quan-ly-bo-nho-trong-swift-1VgZvBVRZAw


import Foundation

class User {
    var name:String
    private(set) var phones: [Phone] = []
    var subscription: [CarrierSubscription] = []
    
    init(name: String) {
        self.name = name
        print("User \(name) is initialize")
    }
    deinit {
        print("User \(name) is being deallocated")
    }
    
    func addPhone(phone: Phone) {
        phones.append(phone)
        phone.owner = self
    }
}

class Phone {
    
    let model: String
    weak var owner: User?
    var carrierSubcription: CarrierSubscription?
    
    init(model: String) {
        self.model = model
        
        print("Phone \(model) is initialize")
    }
    
    deinit {
        print("Phone\(model) is being deallocated")
    }
    
    func provision(carrierSubcription: CarrierSubscription) {
        self.carrierSubcription = carrierSubcription
    }
    func decommision() {
        self.carrierSubcription = nil
    }
    
}

class CarrierSubscription {
    let name: String
    let countryCode: String
    let number: String
    unowned let user: User
    
    // Computed property: gan bang 1 closure tra ve mot so dien thoai day du bang String. Lazy co nghia la no kog
    // bi assign cho den khi su dung. Tuc la khong cap bo nho cho bien nay
    // Bắt buộc phải dùng lazy bởi vì bên trong closure, ta sử dụng self.countryCode và self.number,
    // mà những thứ này không thể available trừ khi hàm init chạy xong.
    lazy var completePhoneNumber: () -> String = { [unowned self] in
        self.countryCode + " " + self.number
    }
    
    init(name: String, countryCode: String, number: String, user: User) {
        self.name = name
        self.countryCode = countryCode
        self.number = number
        self.user = user
        
        user.subscription.append(self)
        
        print("CarrierSubcription \(name) initialize")
    }
    
    deinit {
        print("CarrierSubcription \(name) is being deallocated")
    }
    
    
}

do{
    let user1 = User(name: "Join") // user1 reference đến class User
    let iPhone = Phone(model: "Iphone 6 plus") // iPhone reference đến class Phone
    user1.addPhone(phone: iPhone) // Để ý code một tí, chúng ta có thể thấy, object iPhone có reference "owner" đến object user1, và object user1 cũng có reference "phones" đến object iPhone.
//    let subcription1 = CarrierSubscription(name: "VietNam", countryCode: "0007", number: "312341", user: user1)
//    iPhone.provision(carrierSubcription: subcription1)
//    print(subcription1.completePhoneNumber())
}

/* Tuy nhiên ta sẽ có câu hỏi được đặt ra là: tại sao phải sử dụng unowned? hoặc,
khi nào thì sử dụng unowned? Tại sao không qui về hết var + weak cho đơn giản? Câu trả lời
cho câu hỏi này đã có ngay ở trên: đó là khi ta cần phải sử dụng những property có reference
chéo nhưng lại bắt buộc phải có (tức là sử dụng let) - như trường hợp property User bên trong CarrierSubscription! */


//Reference Cycles with Closures
/*nếu 1 closure được assigned như 1 property của 1 class, và closure
 sử dụng instance property của class đó, bạn sẽ có 1 reference cycle.
 Nói cách khác, object giữ 1 reference tới closure thông qua 1 stored property,
 closure lại giữ 1 reference tới object thông qua captured value of self*/


/*--------------II.Capturing Self với Swift 4.2-----------*/
// https://viblo.asia/p/capturing-self-voi-swift-42-3Q75wBmDlWb

var dog = Dog()
doSomething(then: {
  dog.bark() // dog must be captured so it will live long enough
})

/**
 Trình biên dịch Swift tự động quản lý việc này cho bạn. Con chó sẽ được lưu lại (do đó làm tăng reference đến nó)
 và bạn có thể đảm bảo rằng mặc dù cá thể chó ra khỏi phạm vi hiện tại, block vẫn giữ nó.
 Đôi khi bạn không muốn hành vi này. Lý do phổ biến nhất là trường hợp bạn cần gọi một phương thức self bên trong block.
 Block sẽ giữ self và do đó tạo một biểu đồ phụ thuộc hai chiều, còn được gọi là retain cycle.
 Việc này là rất nên tránh bởi vì nó có nghĩa là self không bao giờ có thể được giải phóng nếu block còn tồn tại. Thông thường, các block được lưu trữ dưới dạng các thuộc tính ví dụ hoặc dưới dạng observers cho KVO hoặc notifications và thời gian tồn tại của chúng bị ràng buộc với self.
 Nếu bạn đã làm điều này, xin chúc mừng ... bạn đã bị rò rỉ bộ nhớ.

 
 Tránh hiện tượng Retain Cycles
 let dog = Dog()
 doSomething(then: { [weak dog] in
     // dog is now Optional<Dog>
     dog?.bark()
 )
 
 hoac
 
 doSomething(then: { [weak self] in
     self?.doSomethingElse()
 )
 
 Bằng cách định nghĩa weak cho self, bạn đang nói với block là không thực hiện tham chiếu tới self.
 
 
 Strong-Weak
 
 Nếu bạn cần đảm bảo rằng các mục trong block thực thi, bạn có thể tạo một tham chiếu mạnh mới bên trong khối.
 
 doSomething(then: { [weak self] in
     guard let strongSelf = self { else return }
     strongSelf.doSomethingElse()
 )

 Trong ví dụ trên, chúng ta đảm bảo rằng tham chiếu strongSelf của chúng ta tồn tại trong phạm vi của khối.
 Phương pháp này khá phổ biến trong các dự án Swift, nhưng luôn cảm thấy hơi kỳ quặc.
 Bạn cũng có thể viết thế này:
 guard let `self` = self else { return }
 
 */
