# Importing the required libraries
from machine import ADC, Pin, I2C
from network import WLAN, STA_IF
from time import sleep
import utime
from urequests import request
import json
from lcd_i2c import LCD
from random import randint
from gc import collect

# Defining the UID file
UID_FILE_NAME = 'uid.txt'

# Defining the SSID and password
SSID = 'OnePlus7'
PASSWORD = 'nishantpanchal2908'

# Declaring a list of UID
list_of_uids = []

# Declaring the API_KEY
api_key = 'r6ceRUK4eE7Iez5heqJyDalib5e3CJcCuVJxY8jnq9vqwW5gGZJQLAN6HMFkQVbs'

# Initializing the LCD
i2c = I2C(0, scl=Pin(22), sda=Pin(21), freq=800000) # SCL 13 and SDA 12
lcd = LCD(addr=0x27, cols=16, rows=2, i2c=i2c)
lcd.begin()
lcd.backlight()
lcd.no_cursor()

# Writing data to CSV
def write_to_file(filename: str, value_of_uid: int):
    with open(filename, 'a') as write_file:
        write_file.write(str(value_of_uid))  # Convert the integer to a string
        write_file.write('\n') # Writing a blank line
        print("Successfully written to the file")
        collect()  # Collecting the cache
    
# Connecting to the network
def connect_to_wifi(ssid, password):
    lcd.home()
    lcd.clear()
    wlan = WLAN(STA_IF) # Defining the WLAN stations
    if wlan.isconnected(): # If already connected to any Wi-Fi network
        lcd.print("Already")
        lcd.set_cursor(col=0, row=1)
        lcd.print("Connected")
        print("Wi-Fi already connected")
        return
    else:
        wlan.active(True) # Turning the STA_IF station ON
        ssids = [str(station[0])[2:-1] for station in wlan.scan()] # Getting the list of available network around
        if ssid in ssids: # If the SSID in the nearby stations
            try:
                lcd.home()
                lcd.clear()
                wlan.connect(ssid, password) # Connecting to the network
                print("Successfully connected")
                lcd.print("Successfully")
                lcd.set_cursor(col=0, row=1)
                lcd.print("Connected")
                print("Wi-Fi successfully connected")
            except:
                lcd.home()
                lcd.clear()
                lcd.print("Please check")
                lcd.set_cursor(col=0, row=1)
                lcd.print("the credentials")
                print("Please check the credentials") # Otherwise print wrong credentials
        else:
            lcd.home()
            lcd.clear()
            lcd.print("Consider turning")
            lcd.set_cursor(col=0, row=1)
            lcd.print("your hotspot on")
            sleep(3)
            lcd.clear()
            lcd.home()
            lcd.print("Retrying after")
            lcd.set_cursor(row=1, col=0)
            lcd.print("3 seconds")
            print("Retrying after 5 seconds") # Trying after 5 seconds
            collect() # Collecting the cache
            sleep(3)
            lcd.clear()
            lcd.home()
            lcd.print("Retrying..")
            print("Retrying")
            connect_to_wifi(ssid, password)
            
# Reading if the device needs to be turned on
def read_data():
    # Defining the URL
    url = "https://ap-south-1.aws.data.mongodb-api.com/app/data-egfvn/endpoint/data/v1/action/findOne"
    # Defining the payload in JSON
    payload = json.dumps({
        "collection": "VP_Collection",
        "database": "VP_Data",
        "dataSource": "AtlasCluster",
        "filter": {
            "ID": "MainSwitch"
        }
    })
    headers = {
      'Content-Type': 'application/json',
      'Access-Control-Request-Headers': '*',
      'api-key': api_key,
    }
    # POST the request with the header and the payload
    try:
        response = request("POST", url, headers=headers, data=payload)
        # If object needs to be turned on
        if str(response.json()['document']['Switch']) == 'ON':
            lcd.clear()
            lcd.home()
            lcd.print("Turning the")
            lcd.set_cursor(col=0, row=1)
            lcd.print("Device ON")
            return
        else:
            collect() # Collect the cache
            read_data()
    except:
        read_data()

# Generating the UID
def generate_uid():
    random_number = randint(100000, 999999) # UID between 100000 and 999999
    if random_number in list_of_uids: # If UID already exists then
        generate_uids() # Generate another UID
    else:
        lcd.clear()
        lcd.home()
        lcd.print("UID: ")
        lcd.set_cursor(col=6, row=0)
        lcd.print(str(random_number))
        return random_number # Else return the original UID

def analog_readings(pin1: int, pin2: int):
    reading1 = [] # CO2
    reading2 = [] # CO
    adc1 = ADC(Pin(pin1))
    adc2 = ADC(Pin(pin2))
    
    start_time = utime.time()
    while utime.time() - start_time < 5:  # Collect readings for 10 seconds
        reading1.append(adc1.read()) # Reading the ADC and append to the list
        reading2.append(adc2.read()) # Reading the ADC and append to the list
        sleep(1)  # Delay for 1 second between readings
    
    average1 = sum(reading1) / len(reading1) # Calculating the average
    average2 = sum(reading2) / len(reading2)
    reading1.clear()
    reading2.clear()
    lcd.clear()
    lcd.home()
    lcd.print("CO2: ")
    lcd.set_cursor(col=6, row=0)
    lcd.print(str(average1))
    lcd.set_cursor(col=0, row=1)
    lcd.print("CO: ")
    lcd.set_cursor(col=6, row=1)
    lcd.print(str(average2))
    return average1/10000, average2/10000

# Inserting the data into database
def insert_data(value1: int, value2: int, uid: int):
    # Defining the payload in JSON object
    url = "https://ap-south-1.aws.data.mongodb-api.com/app/data-egfvn/endpoint/data/v1/action/insertOne"
    payload = json.dumps({
        "collection": "VP_Collection",
        "database": "VP_Data",
        "dataSource": "AtlasCluster",
        "document": {
            "Carbon Dioxide Value": value1,
            "Carbon Monoxide Value": value2,
            "UID": str(uid),
            "Object-Type": "Vehicle-Details",
            "Vehicle Number": "",
            "Engine Capacity": "",
            "Engine Stage": "",
            "Fuel": "",
        }
    })
    # Defining the headers
    headers = {
      'Content-Type': 'application/json',
      'Access-Control-Request-Headers': '*',
      'api-key': api_key,
      'Accept': 'application/json'
    }
    # POST the requrst with the payload and header
    response = request("POST", url, headers=headers, data=payload)

    print(response.status_code)
    print(response.json())
    # Checking if the request made was successful
    if response.status_code == 201:
        print("Data successfully posted")
        write_to_file('/uid.txt', uid)
        return uid
    else:
        print("Retrying")
        collect()
        insert_data(value1, value2, uid)

# Disconnecting the WIFI
def disconnect_wifi():
    wifi = WLAN(STA_IF)
    wlan.disconnect()
    sleep(2)
    return

# Checking if the process gets completed
def check_process_completed(uid: int):
    # Defining the URL
    url = "https://ap-south-1.aws.data.mongodb-api.com/app/data-egfvn/endpoint/data/v1/action/findOne"
    # Defining the payload in JSON
    payload = json.dumps({
        "collection": "VP_Collection",
        "database": "VP_Data",
        "dataSource": "AtlasCluster",
        "filter": {
            "Object-Type": "Vehicle-Details",
            "UID": uid,
        }
    })
    # Defining the headers
    headers = {
      'Content-Type': 'application/json',
      'Access-Control-Request-Headers': '*',
      'api-key': api_key,
    }
    # POST the request with the payload and header
    response = request("POST", url, headers=headers, data=payload)
    # Checking if the user has submitted the other details
    if len(str(response.json()['document']['Vehicle Number'])) > 3:
        lcd.home()
        lcd.clear()
        lcd.print("Turn the")
        lcd.set_cursor(col=0, row=1)
        lcd.print("Device OFF")
        disconnect_wifi()
        lcd.no_display()
        return
    else:
        collect()
        sleep(2)
        check_process_completed(uid)
        
def update_the_Switch():
    url = "https://ap-south-1.aws.data.mongodb-api.com/app/data-egfvn/endpoint/data/v1/action/updateOne"
    # Defining the payload in JSON
    payload = json.dumps({
        "collection": "VP_Collection",
        "database": "VP_Data",
        "dataSource": "AtlasCluster",
        "filter": {
            "ID": "MainSwitch"
        },
        "update": {
        "$set": {
            "Switch": "OFF"
        }
    }
    })
    # Defining the headers
    headers = {
      'Content-Type': 'application/json',
      'Access-Control-Request-Headers': '*',
      'api-key': api_key,
    }
    # POST the request with the payload and header
    response = request("POST", url, headers=headers, data=payload)
    # Checking if the user has submitted the other details
    print(response.status_code)
    print(response.text)

with open('/uid.txt', 'r') as file:
    # Read the contents of the file
    contents = file.read()

    # Split the contents into lines
    lines = contents.split('\n')

    # Initialize an empty list to store the values
    list_of_uids = []

    # Iterate over the lines
    for line in lines:
        # Append the line to the list of UIDs
        list_of_uids.append(line)
lcd.home()
lcd.clear()
lcd.print("Welcome to")
lcd.set_cursor(col=0, row=1)
lcd.print("Pollution Meter")
sleep(2)
connect_to_wifi(SSID, PASSWORD)
read_data()
co2, co = analog_readings(34, 35)
print(co2, co)
uid = generate_uid()
insert_data(co2, co, uid)
update_the_Switch()
write_to_file('/uid.txt', uid)