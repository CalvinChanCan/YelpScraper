from mysql_connection import get_mysql_config
import mysql.connector

def connect_to_mysql(configs):

    mydb = mysql.connector.connect(
        host=configs[0],
        user=configs[1],
        password=configs[2],
    )

    mycursor = mydb.cursor()
    return mycursor

    # mycursor.execute("CREATE TABLE customers (name VARCHAR(255), address VARCHAR(255))")


def create_mysql_database(mycursor):
    mycursor.execute("DROP DATABASE IF EXISTS privateDB")
    mycursor.execute("CREATE DATABASE IF NOT EXISTS privateDB")


    mycursor("SELECT * FROM usernames")

