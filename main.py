from yelp_scraper import *
from yelp_mysql_database import *

def load_user_data():
    configs = get_mysql_config()

    mydb = mysql.connector.connect(
        host=configs[0],
        user=configs[1],
        password=configs[2],

    )

    mycursor = mydb.cursor()
    print(mycursor. execute("SELECT * FROM privatedb.usernames"))

    mycursor.execute("")


if __name__ == "__main__":
    #get_business_data("20-06-13 01-57-15 API file.json")
    #remove_duplicates("yelp_data_business_reviews.csv")
    #get_review_data_from_business_json()
    #correct_json("newfiletest", "newfiletest")
    yelp_json_to_csv('yelp_json_coffee_shop_reviews.json')
    #get_business_data("20-06-13 01-57-58 API file.json")
    # configs = get_mysql_config()
    # cursor = connect_to_mysql(configs)
    # create_mysql_database(cursor)


    # configs = get_mysql_config()
    #
    # mydb = mysql.connector.connect(
    #     host=configs[0],
    #     user=configs[1],
    #     password=configs[2],
    #
    # )
    #
    # mycursor = mydb.cursor()
    # print(mycursor.execute("SELECT * FROM privatedb.usernames"))
    #
    # mycursor.execute("")
    #






