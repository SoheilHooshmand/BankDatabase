import  mysql.connector
from client import Client
from employee import Employee
from sqlite3 import OperationalError

mydb = mysql.connector.connect(
     host = "localhost",
     user = "root",
     password = "Sf$77777"
)
mycursor = mydb.cursor()
mycursor.execute('use db_p2')
def register():
     accountNumber = input("Enter accountNumber: ")
     password = input('Enter password: ')
     firstName = input("Enter firstname: ")
     lastname = input("Enter lastname: ")
     nationalId = input("Enter nationalId: ")
     dateOfBrith = input("Enter date of brith: ")
     type = int(input("Chose your type:1-client,2-employee"))
     user = None
     if type == 1:
          interestRate = input("Enter interestRate: ")
          user = Client(accountNumber,password,firstName,lastname,nationalId,dateOfBrith,interestRate);
     elif type == 2:
          user = Employee(accountNumber,password,firstName,lastname,nationalId,dateOfBrith)
     if user is not None and isinstance(user,Client):
          mycursor.callproc('register', [user.accountNumber,user.password,user.firstName,user.lastName,user.nationalId,user.dataOfBrith,user.type,user.interestRate])
          mycursor.stored_results()
          mydb.commit()
     elif user is not None and isinstance(user,Employee):
          mycursor.callproc('register',
                            [user.accountNumber, user.password, user.firstName, user.lastName, user.nationalId,
                             user.dataOfBrith, user.type, 0])
          mycursor.stored_results()
          mydb.commit()

def login():
     result = ""
     username = input("Enter your username: ")
     password = input("Enter your password: ")
     mycursor.callproc("log",[username,password])
     mydb.commit()
     for result in mycursor.stored_results():
          result = result.fetchall()[0]
     if len(result) > 0:
          return False
     else:
          return True

def deposit():
     amount = input("Enter amount: ")
     mycursor.callproc('deposit',[amount])
     mycursor.stored_results()
     mydb.commit()
def withdraw():
     amount = input("Enter amount: ")
     mycursor.callproc("withdraw",[amount])
     mycursor.stored_results()
     mydb.commit()
def transfer():
     amount = input("Enter amount:")
     accountNumber = input("Enter account number:")
     mycursor.callproc('transfer',[accountNumber,amount])
     mycursor.stored_results()
     mydb.commit()
def check_balances():
     mycursor.callproc('check_balance',[])
     mycursor.stored_results()
     mydb.commit()
     for result in mycursor.stored_results():
          print(result.fetchall()[0][0])
def interest_payment():
     mycursor.callproc('interest_payment',[])
     mycursor.stored_results()
     mydb.commit()
def update_balance():
     mycursor.callproc("new_procedure",[])
     # mycursor.stored_results()
     mydb.commit()
def menu():
     type = ""
     mycursor.execute('select username from login_log where login_time = (select max(login_time) from login_log)')
     username = mycursor.fetchall()
     mycursor.execute(f"select type from account where username = '{username[0][0]}'")
     type = mycursor.fetchall()
     if type[0][0] == 'client':
         while True:
               print("1-deposit\n2-withdraw\n3-transfer\n4-check_balance\n5-logout")
               choise = int(input("Enter your choice: "))
               if choise == 1:
                    deposit()
               elif choise == 2:
                    withdraw()
               elif choise == 3:
                    transfer()
               elif choise == 4:
                    check_balances()
               elif choise == 5:
                    break

     elif type[0][0] == 'employee':
          while True:
               print("1-update balance\n2-interest_payment\n3-logout")
               choice = int(input("Enter your choice: "))
               if choice == 1 :
                    update_balance()
               elif choice == 2:
                    interest_payment()
               elif choice == 3:
                    break

def start():
     while True:
          print("1-login\n2-register\n3-exist")
          choice = int(input("Enter your choice: "))
          if choice == 1:
               result = login()
               if result == True:
                   menu()
               else :
                    print("Please register")
          elif choice == 2:
               register()
          elif choice == 3:
               break
start()
