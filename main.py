from yelp_scraper import *
from yelp_mysql_database import *
from os import walk


def load_user_data():
    configs = get_mysql_config()

    mydb = mysql.connector.connect(
        host=configs[0],
        user=configs[1],
        password=configs[2],

    )

    mycursor = mydb.cursor()
    print(mycursor.execute("SELECT * FROM privatedb.usernames"))

    mycursor.execute("")


def get_all_pages(search_term):
    for i in range(0, 19, 1):
        get_businesses(search_term, i)


def get_list_of_files_in_dir(directory):
    from os import listdir
    from os.path import isfile, join

    onlyfiles = [f for f in listdir(directory) if isfile(join(directory, f))]
    return onlyfiles


if __name__ == "__main__":
    directory = "./archive"
    filelist = get_list_of_files_in_dir(directory)
    for each_file in filelist:
        print(each_file)
        get_business_data(directory + "/" + each_file)
# get_business_data("20-06-13 01-57-15 API file.json")
# remove_duplicates("yelp_data_business_reviews.csv")
# get_review_data_from_business_json()
# correct_json("newfiletest", "newfiletest")
# yelp_json_to_csv('yelp_json_coffee_shop_reviews.json')
# get_business_data("20-06-13 01-57-58 API file.json")
# get_business_data("20-06-17 23-06-33 API file.json")
# get_business_data("20-06-13 01-57-58 API file.json")


# get_business_data("20-06-13 15-24-02 coffee API file.JSON")
# get_business_data("20-06-17 23-06-33 coffee API file.JSON")
# get_business_data("20-06-17 23-25-21 coffee API file.JSON")
# get_business_data("20-06-17 23-26-30 coffee API file.JSON")
# get_business_data("20-06-17 23-27-15 coffee API file.JSON")
# get_business_data("20-06-17 23-27-19 coffee API file.JSON")
# get_business_data("20-06-17 23-27-21 coffee API file.JSON")
# get_business_data("20-06-17 23-27-24 coffee API file.JSON")
# get_business_data("20-06-17 23-27-27 coffee API file.JSON")
# get_business_data("20-06-17 23-27-29 coffee API file.JSON")
# get_business_data("20-06-17 23-27-31 coffee API file.JSON")
# get_business_data("20-06-17 23-27-34 coffee API file.JSON")


# get_businesses("coffee")
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
