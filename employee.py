from user import User

class Employee(User):
    def __init__(self,accountNumber,password,firstName,lastName,nationalId,dateOfBrith):
        super().__init__(accountNumber,password,firstName,lastName,nationalId,dateOfBrith,'employee')