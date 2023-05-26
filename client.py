from user import User

class Client(User):
    def __init__(self,accountNumber,password,firstName,lastName,nationalId,dateOfBrith,interestRate):
        super().__init__(accountNumber,password,firstName,lastName,nationalId,dateOfBrith,'client')
        self.interestRate = interestRate

    def set_interestRate(self,interestRate):
        self.interestRate = interestRate

    def get_interestRate(self):
        return self.interestRate
