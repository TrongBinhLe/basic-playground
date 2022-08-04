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
    let user1 = User(name: "Join")
    let iPhone = Phone(model: "Iphone 6 plus")
    user1.addPhone(phone: iPhone)
    let subcription1 = CarrierSubscription(name: "VietNam", countryCode: "0007", number: "312341", user: user1)
    iPhone.provision(carrierSubcription: subcription1)
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
