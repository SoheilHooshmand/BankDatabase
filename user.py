class User:
    def __init__(self,accountNumber,password,firstName,lastName,nationalId,dateOfBrith,type):
        self.accountNumber = accountNumber
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.nationalId = nationalId
        self.dataOfBrith = dateOfBrith
        self.type = type

    def set_accountNumber(self,accountNumber):
        self.accountNumber=accountNumber
    def set_password(self,password):
        self.password=password
    def set_firstName(self,firstName):
        self.firstName=firstName
    def set_lastName(self,lastName):
        self.lastName=lastName
    def set_nationalId(self,nationalId):
        self.nationalId=nationalId
    def set_dateOfBrith(self,dateOfBrith):
        self.dataOfBrith=dateOfBrith
    def set_type(self,type):
        self.type=type

    def get_accountNumber(self):
        return self.accountNumber
    def get_password(self):
        return self.password
    def get_firstName(self):
        return self.firstName
    def get_lastName(self):
        return self.lastName
    def get_nationalId(self):
        return self.nationalId
    def get_dateOfBrith(self):
        return self.dataOfBrith
    def get_type(self):
        return self.type

