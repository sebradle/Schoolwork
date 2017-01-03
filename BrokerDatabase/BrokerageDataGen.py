#!/usr/bin/env python3
# Carlos Adrian Gomez, Sean Bradley
# COMP420
from sys import argv
import random
from faker import Faker
from yahoo_finance import Share

###  Table insert order
# department ("Brokerage", "Legal", "Facilities", "Sales -> non-salaried", "Payroll", "HR -> non-salaried") w / descriptions

# Personal_info
# employee ("Assign to random dept id")
# manager

# salary
# non-salaried
# salaried employee
# office

# broker
# customers
# beneficiary

fake = Faker()
contact = {}
brokers_ssn = []
customers_ssn = []
num_depts = 6
departments = [['Brokerage', 'We sell stocks'], ['Legal', 'We\'\'ll sue!'], ['Facilities', 'We run day to day operations'], ['Payroll', 'We pay people'], ['HR', 'Toby works here'], ['Sales', 'We try to get clients']]
# let HR and Sales be non-salaried
num_rooms = 20
num_floors = 5
num_employees = 25

acct_types = ["Cash", "Educational", "Roth IRA", "Traditional"]

cust = [10, 14, 18, 20, 23]
stocks = ['MSFT', 'GOOG', 'AAPL', 'CSCO', 'AMZN', 'PACD', 'SRI', 'WAT', 'SNDK', 'SPLS', 'XOM', 'GE', 'SBUX','AMGEN', 'C', 'COF', 'AFGE', 'ANTX', 'S', 'ORCL', 'RST', 'TIF', 'CHGG']

def genDummyTransactions():
    for c in cust:
        num_stocks = random.randint(1, 10)
        #print("Customer {} buying {}".format(c,num_stocks));
        for i in range(0, num_stocks):
            stock = random.choice(stocks)
            print("select \'{}\' into @symbol;".format(stock))
            print("select (\'2016-04-12\' + interval rand()*30 day) into @d;")
            print("select @d;")
            print("select id into @hid FROM hist_stock WHERE hist_stock.symbol=@symbol AND hist_stock.hdate=@d;")
            print("INSERT INTO cust_transaction VALUES({}, @d, @symbol, 1, 'buy', @hid);".format(c))

def genDept():
    global departments
    i = 0
    for dept in departments:
        print("INSERT INTO department VALUES({}, \'{}\', \'{}\');".format(i + 1, departments[i][0], departments[i][1]))
        i = i + 1

def genWorkspace(rooms_per_floor, floors):
    workspaces = ["Office", "Cubicle"]
    for i in range(1, rooms_per_floor + 1):
        floor = random.randrange(floors) + 1
        val = random.random()
        wksp_type = workspaces[0]
        if val < 0.80:
            wksp_type = workspaces[1]
        print("INSERT INTO workspace VALUES({}, {}, \'{}\');".format(i, floor, wksp_type))

def genContact(ssn):
    global contact
    email = fake.email()
    phone = ''.join(ch for ch in fake.phone_number() if ch.isdigit())[:9]
    # fname = fake.first_name()
    # lname = fake.last_name()
    fname = ''.join(ch for ch in fake.first_name() if ch.isalpha())
    lname = ''.join(ch for ch in fake.last_name() if ch.isalpha())
    address = fake.street_address()
    city = fake.city()
    state = fake.state_abbr()
    print("INSERT INTO personal_info VALUES(\'{}\',  \'{}\', \'{}\', \'{}\', \'{}\', \'{}\', \'{}\', \'{}\');".format(ssn, fname, lname, email, phone, address, city, state))
    person_info = [email, phone, address, city, state]
    contact[ssn] = person_info
    return ssn

def genShare(ticker):
    share = Share(ticker)
    print(share.get_info())
    print(share.get_market_cap())
    # print(share.get_historical('2015-05-01', '2015-05-10'))

def randomSalary():
    return random.randrange(150000)

def genEmployee(num):
    global contact
    for i in range (0, num):
        ssn = ''.join(ch for ch in fake.ssn() if ch.isdigit())[:9]
        genContact(ssn)
        dept_id = random.randint(1, num_depts)
        room = random.randrange(num_rooms - 1) + 1
        salaried = False
        pay = randomSalary()
        bonus = randomSalary() * .5
        if i < 3:
            print("INSERT INTO employee VALUES(\'{}\', CURDATE(), {}, {});".format(ssn, dept_id, room))
            ## manager
            print("INSERT INTO manager VALUES(\'{}\', {}, {});".format(ssn, bonus, pay))
            salaried = True
        elif i >= 3 and i <= 9:
            global brokers_ssn
            print("INSERT INTO employee VALUES(\'{}\', CURDATE(), {}, {});".format(ssn, 1, room))
            brokers_ssn.append(ssn)
            commission = round(random.random(), 2)
            if commission is 1.0:
                commission = commission - 0.01
            print("INSERT INTO broker VALUES(\'{}\', {}, {});".format(ssn, commission, pay))
            salaried = True
        else:
            global departments
            print("INSERT INTO employee VALUES(\'{}\', CURDATE(), {}, {});".format(ssn, dept_id, room))
            wage = round((randomSalary() / 2087), 2) # div by work hours in a year
            if departments[dept_id - 1][0] in ('Sales', 'HR'):
                print("INSERT INTO nonsalaried_employee VALUES(\'{}\', {});".format(ssn, wage))
            pass
        
        if salaried:
            print("INSERT INTO salaried_employee VALUES(\'{}\', {});".format(ssn, pay))
            pass

def genBeneficiary(cust_ssn):
    ben_ssn = ''.join(ch for ch in fake.ssn() if ch.isdigit())[:9]
    genContact(ben_ssn)
    print("INSERT INTO beneficiary VALUES(\'{}\', \'{}\');".format(ben_ssn, cust_ssn))
    

def genCustomer(num):
    global customers_ssn, brokers_ssn, acct_types
    acct_counter = 1
    for i in range(0, num):
        ssn = ''.join(ch for ch in fake.ssn() if ch.isdigit())[:9]
        genContact(ssn)
        customers_ssn.append(ssn)
        broker = random.choice(brokers_ssn)
        if i < len(brokers_ssn):
            broker = brokers_ssn[i]
        print("INSERT INTO customer VALUES(\'{}\', \'{}\');".format(ssn, broker))
        init_bal = random.randrange(5000)
        print("INSERT INTO customer_account VALUES({}, \'{}\', {});".format(acct_counter, ssn, init_bal))
        print("INSERT INTO account_type VALUES({}, 'Cash', 0);".format(acct_counter))
        acct_counter += 1
        new_acct_type = None
        if init_bal > 3000:
            new_acct_type = random.choice(acct_types)
        elif init_bal > 1000 and init_bal < 3000:
            new_acct_type = random.choice(acct_types[:2])
        else:
            new_acct_type = 'Cash'
        if new_acct_type is not 'Cash':
            print("INSERT INTO customer_account VALUES({}, \'{}\', {});".format(acct_counter, ssn, init_bal))
            print("INSERT INTO account_type VALUES({}, \'{}\', 0);".format(acct_counter, new_acct_type))
            acct_counter += 1
        genBeneficiary(ssn)

def main():
    genWorkspace(num_rooms, num_floors)
    genDept()
    genEmployee(30)
    genCustomer(20)

if __name__ == '__main__':
    main()
