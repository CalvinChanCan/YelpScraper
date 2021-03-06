from shutil import copyfile
import os.path
from mysql_connection import *
import MySQLdb
import mysql.connector
from os import path
import os
import glob
import io
import pprint
import pandas as pd
import jsonlines
from bs4 import BeautifulSoup
import requests
import pandas
from datetime import datetime
import json
import re
from itertools import zip_longest
import csv

from YelpAPI import get_my_key


# Yelp API Endpoints
# Business Search      URL -- 'https://api.yelp.com/v3/businesses/search'
# Business Match       URL -- 'https://api.yelp.com/v3/businesses/matches'
# Phone Search         URL -- 'https://api.yelp.com/v3/businesses/search/phone'

# Business Details     URL -- 'https://api.yelp.com/v3/businesses/{id}'
# Business Reviews     URL -- 'https://api.yelp.com/v3/businesses/{id}/reviews'


def get_business_details_api(business_id):
    API_KEY = get_my_key()
    ENDPOINT = 'https://api.yelp.com/v3/businesses/' + business_id

    HEADERS = {'Authorization': 'bearer %s' % API_KEY}

    response = requests.get(url=ENDPOINT, headers=HEADERS)

    business_data = response.json()

    print(json.dumps(business_data, indent=3))

    now = datetime.now()
    current_time = now.strftime("%y-%m-%d %H-%M-%S")
    filename = current_time + " " + business_id + " API file.json"

    file = open("./archive/" + filename, "w")
    file.write(json.dumps(business_data, indent=3))
    file.close()

    get_business_data(filename)


def get_business_data(json_api_filename):
    yelp_business_filename = 'yelp_data_business.csv'

    if path.exists(yelp_business_filename):
        myfile = open(yelp_business_filename, 'a+', encoding='utf-8',
                      newline='')
        business_csv = csv.writer(myfile, quoting=csv.QUOTE_ALL)
    else:
        myfile = open(yelp_business_filename, 'w', encoding='utf-8',
                      newline='')

        business_csv = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        business_csv.writerow(
            ["yelp_business_id", "yelp_business_name", "price", "latitude",
             "longitude", "address1", "address2", "address3", "city",
             "zip_code", "country", "state", "display_address", "rating",
             "review_count"])

    yelp_business_categories = 'yelp_data_business_categories.csv'

    if path.exists(yelp_business_categories):
        categories_file = open(yelp_business_categories, 'a+', encoding='utf-8',
                               newline='')
        categories_csv = csv.writer(categories_file, quoting=csv.QUOTE_ALL)
    else:
        categories_file = open(yelp_business_categories, 'w', encoding='utf-8',
                               newline='')
        categories_csv = csv.writer(categories_file, quoting=csv.QUOTE_ALL)
        categories_csv.writerow(
            ["yelp_business_id", "yelp_business_name", "category"])

    with open(json_api_filename) as json_file:
        data = json.load(json_file)

        try:
            for p in data['businesses']:
                # yelp_business_id = p['id']
                # yelp_business_name = p['name']
                # try:
                #     price = len(p['price'])
                # except:
                #     price = None
                # latitude = p['coordinates']['latitude']
                # longitude = p['coordinates']['longitude']
                # address1 = p['location']['address1']
                # address2 = p['location']['address2']
                # address3 = p['location']['address3']
                # city = p['location']['city']
                # zip_code = p['location']['zip_code']
                # review_count = p['review_count']
                #
                # while len(zip_code) < 5:
                #     zip_code = "0" + zip_code
                #
                # country = p['location']['country']
                # state = p['location']['state']
                # display_address = p['location']['display_address'][0]
                # rating = p['rating']
                #
                # business_csv.writerow(
                #     [yelp_business_id, yelp_business_name, price, latitude,
                #      longitude,
                #      address1, address2, address3, city, zip_code, country,
                #      state, display_address, rating, review_count])
                #
                # for each_category in p['categories']:
                #     categories_csv.writerow([yelp_business_id, yelp_business_name,
                #                              each_category['title']])
                write_business_data(p, business_csv, categories_csv)
        except:
            #write_business_data(data, business_csv, categories_csv)
            write_business_data_in_list(data, business_csv, categories_csv)

    myfile.close()
    categories_file.close()
    # remove_duplicates(yelp_business_filename,
    #                   "yelp_data_business_processed.csv")
    remove_duplicates(yelp_business_filename)
    remove_duplicates(yelp_business_categories)

    # os.remove(yelp_business_filename)
    # dirname = os.path.dirname(__file__)
    # filename = os.path.join(dirname, "yelp_data_business_processed.csv")
    # renamed_file = os.path.join(dirname, "yelp_data_business.csv")
    # os.rename(filename, renamed_file)
    # os.rename("yelp_data_business_processed.csv", "yelp_data_business.csv")


def write_business_data(json_data, business_csv, categories_csv):
    yelp_business_id = json_data['id']
    yelp_business_name = json_data['name']
    try:
        price = len(json_data['price'])
    except:
        price = None
    latitude = json_data['coordinates']['latitude']
    longitude = json_data['coordinates']['longitude']
    address1 = json_data['location']['address1']
    address2 = json_data['location']['address2']
    address3 = json_data['location']['address3']
    city = json_data['location']['city']
    zip_code = json_data['location']['zip_code']
    review_count = json_data['review_count']

    while len(zip_code) < 5:
        zip_code = "0" + zip_code

    country = json_data['location']['country']
    state = json_data['location']['state']
    display_address = json_data['location']['display_address'][0]
    rating = json_data['rating']

    business_csv.writerow(
        [yelp_business_id, yelp_business_name, price, latitude,
         longitude,
         address1, address2, address3, city, zip_code, country,
         state, display_address, rating, review_count])

    for each_category in json_data['categories']:
        categories_csv.writerow([yelp_business_id, yelp_business_name,
                                 each_category['title']])

def write_business_data_in_list(json_data, business_csv, categories_csv):
    for each_item in json_data:

        yelp_business_id = each_item['id']
        yelp_business_name = each_item['name']
        try:
            price = len(each_item['price'])
        except:
            price = None
        latitude = each_item['coordinates']['latitude']
        longitude = each_item['coordinates']['longitude']
        address1 = each_item['location']['address1']
        address2 = each_item['location']['address2']
        address3 = each_item['location']['address3']
        city = each_item['location']['city']
        zip_code = each_item['location']['zip_code']
        review_count = each_item['review_count']

        while len(zip_code) < 5:
            zip_code = "0" + zip_code

        country = each_item['location']['country']
        state = each_item['location']['state']
        display_address = each_item['location']['display_address'][0]
        rating = each_item['rating']

        business_csv.writerow(
            [yelp_business_id, yelp_business_name, price, latitude,
             longitude,
             address1, address2, address3, city, zip_code, country,
             state, display_address, rating, review_count])

        for each_category in each_item['categories']:
            categories_csv.writerow([yelp_business_id, yelp_business_name,
                                     each_category['title']])

def get_review_data_from_business_json(json_api_file):
    reviews_json_filename = 'yelp_data_reviews.json'

    with open(json_api_file) as json_file:
        data = json.load(json_file)
        try:
            for each_business in data['businesses']:
                business_url = each_business['url'].split("?", 1)[0]
                get_reviews_json(business_url, reviews_json_filename)
                print("----------")
        except:
            try:
                for each_business in data:
                    business_url = each_business['url'].split("?", 1)[0]
                    get_reviews_json(business_url, reviews_json_filename)
                    print("----------")
            except:
                # Handle the empty json object
                pass
    correct_json(reviews_json_filename)
    yelp_review_json_to_csv("yelp_data_reviews2.json")
    #
    # correct_json(reviews_json_filename)
    # yelp_review_json_to_csv("yelp_data_reviews2.json")


def get_reviews_json(yelp_restaurant_url, out_json_filename):
    num_of_reviews = 0

    r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

    soup = BeautifulSoup(r.content, features="lxml")

    try:
        page_detail = soup.find("span", {
            "class": "lemon--span__373c0__3997G text__373c0__2Kxyz text-color--black-extra-light__373c0__2OyzO text-align--left__373c0__2XGa-"}).string
        num_of_pages = int(page_detail.replace("1 of ", ''))
        max_reviews = num_of_pages * 20
    except Exception as e:
        print(e)
        input("Press any key to continue")

        r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

        soup = BeautifulSoup(r.content, features="lxml")

        page_detail = soup.find("span", {
            "class": "lemon--span__373c0__3997G text__373c0__2Kxyz text-color--black-extra-light__373c0__2OyzO text-align--left__373c0__2XGa-"}).string
        num_of_pages = int(page_detail.replace("1 of ", ''))

        max_reviews = num_of_pages * 20

    for num_of_reviews in range(0, max_reviews, 20):
        try:
            r = requests.get(
                yelp_restaurant_url + "?start=" + str(num_of_reviews))

            soup = BeautifulSoup(r.content, features="lxml")

            yelp_json_list = soup.findAll("script",
                                          {"type": "application/json"})

            json_data = yelp_json_list[2].contents[0].strip()
        except Exception as e:
            print(e)
            input("Press any key to continue")
            r = requests.get(
                yelp_restaurant_url + "?start=" + str(num_of_reviews))

            soup = BeautifulSoup(r.content, features="lxml")

            yelp_json_list = soup.findAll("script",
                                          {"type": "application/json"})

            json_data = yelp_json_list[2].contents[0].strip()

        json_data = json_data.replace("<!--", "")
        json_data = json_data.replace("-->", "")

        y = json.loads(json_data)
        print(y)
        with open(out_json_filename, 'a+', encoding='utf8') as outfile:
            json.dump(y, outfile, indent=4, separators=(',', ': '),
                      sort_keys=True)
            outfile.write(",\n")
            print("-----------")


def get_businesses_api(search_term, page):
    API_KEY = get_my_key()
    ENDPOINT = 'https://api.yelp.com/v3/businesses/search'
    HEADERS = {'Authorization': 'bearer %s' % API_KEY}

    offset = (page * 50) + 1

    PARAMETERS = {'term': search_term,
                  'limit': 50,
                  'radius': 10000,
                  'location': 'Boston, MA',
                  'offset': offset
                  }

    response = requests.get(url=ENDPOINT,
                            params=PARAMETERS,
                            headers=HEADERS)

    business_data = response.json()

    print(json.dumps(business_data, indent=3))

    now = datetime.now()
    current_time = now.strftime("%y-%m-%d %H-%M-%S")
    filename = current_time + " " + search_term + " API file.json"

    file = open("./archive/" + filename, "w")
    file.write(json.dumps(business_data, indent=3))
    file.close()

    get_business_data(filename)


def merge_csv(file1, file2):
    all_filenames = [file1, file2]
    combined_csv = pd.concat([pd.read_csv(f) for f in all_filenames])
    combined_csv.to_csv("combined_csv.csv", index=False, encoding='utf-8-sig')


def clean_csv(infile):
    infile_obj = open(infile, encoding='utf-8')

    csvfile = csv.reader(infile_obj, delimiter=',')

    outfile_obj = open('outfile.csv', 'w', encoding='utf-8', newline='')
    outfile = csv.writer(outfile_obj, delimiter=',', quoting=csv.QUOTE_ALL)

    for each_row in csvfile:
        username = each_row[2]
        review = each_row[5]

        new_review = review.replace('\n', '').replace('\"', '')
        outfile.writerow(
            [each_row[0], each_row[1], username, each_row[3], each_row[4],
             new_review])

        # outfile


def parse_jsonl(filename):
    # with jsonlines.open(filename) as reader:
    #     for obj in reader:
    #         print(obj)
    with open(filename, encoding='utf-8') as json_file:
        data = json.load(json_file)
        print(data)


def correct_json(readfile):
    f = open(readfile + "temp", "w", encoding='utf-8', newline='')

    with open(readfile, "r", encoding='utf-8') as json_file:

        f.writelines("[\n")
        for each_line in json_file:
            if (each_line == "{\n"):
                write_line = "\t{\n"
            elif (each_line == "}\n"):
                write_line = "\t},\n"
            else:
                write_line = "\t" + each_line

            f.writelines(write_line)

        f.writelines("\t{\n")
        f.writelines("\t}\n")
        f.writelines("\n]")

    f.close()
    json_file.close()

    os.remove(readfile)
    os.rename(readfile + "temp", readfile)


def yelp_review_json_to_csv(readfile):
    yelp_user_dict = {}

    business_hours_filename = "yelp_data_business_hours.csv"
    reviews_filename = "yelp_data_business_reviews.csv"
    user_filename = "yelp_data_users.csv"

    if path.exists(business_hours_filename):
        business_hours_file = open(business_hours_filename, "a+",
                                   encoding='utf-8', newline='')
        # business_hours_csv = csv.writer(business_hours_file, delimiter=',',
        #                                 quoting=csv.QUOTE_ALL)
        business_hours_csv = csv.writer(business_hours_file, delimiter=',')
    else:
        business_hours_file = open(business_hours_filename, "w",
                                   encoding='utf-8', newline='')
        business_hours_csv = csv.writer(business_hours_file, delimiter=',')
        business_hours_csv.writerow(
            ["business_id", "business_name", "day_of_week", "hours_opened"])

    if path.exists(reviews_filename):
        reviews_file = open(reviews_filename, "a+", encoding='utf-8',
                            newline='')
        # reviews_csv = csv.writer(reviews_file, delimiter=',', quoting=csv.QUOTE_ALL)
        reviews_csv = csv.writer(reviews_file, delimiter=',')
    else:
        reviews_file = open(reviews_filename, "w", encoding='utf-8',
                            newline='')
        reviews_csv = csv.writer(reviews_file, delimiter=',')
        reviews_csv.writerow(
            ["review_id", "business_id", "business_name", "user_yelp_id",
             "user_name",
             "review_date", "review_rating", "review_feedback_cool",
             "review_feedback_funny", "review_feedback_useful",
             "business_owner_reply", "review_written"])
    if path.exists(user_filename):

        user_file = open(user_filename, "a+", encoding='utf-8', newline='')
        # user_csv = csv.writer(user_file, delimiter=',', quoting=csv.QUOTE_ALL)
        user_csv = csv.writer(user_file, delimiter=',')
    else:
        user_file = open(user_filename, "w", encoding='utf-8', newline='')
        user_csv = csv.writer(user_file, delimiter=',')
        user_csv.writerow(
            ["user_yelp_id", "user_name", "user_city", "user_state",
             "user_elite",
             "user_friend_count", "user_review_count", "user_photo_count"])

    with open(readfile, encoding='utf-8') as json_file:
        data = json_file.read()
        json_data = json.loads(data)

        for review_page in json_data:
            try:
                business_root = review_page['bizDetailsPageProps']
            except:
                continue

            # Business Hours
            hours_opened = []
            for each_hour in business_root['bizHoursProps']['hoursInfoRows']:
                hours_opened.append(each_hour['hoursInfo']['hours'][0])

            while (len(hours_opened) < 7):
                hours_opened.append('Closed')

            # Business Data
            business_name = business_root['businessName']
            business_id = business_root['businessId']

            try:
                business_site = \
                    business_root['bizContactInfoProps']['businessWebsite'][
                        'linkText']
            except Exception as e:
                business_site = ''

            for each_review in \
                    review_page['bizDetailsPageProps']['reviewFeedQueryProps'][
                        'reviews']:
                # User Data
                user_data = each_review['user']
                user_name = user_data['altText']
                user_location = user_data['displayLocation']

                try:
                    user_city = user_location.split(",")[0]
                    user_state = user_location.split(",")[1].strip(" ")
                except Exception as e:
                    user_city = ""
                    user_state = ""

                user_elite = user_data['eliteYear']
                user_friend_count = user_data['friendCount']
                user_yelp_id = user_data['link'].replace(
                    "/user_details?userid=", "")

                user_photo_count = user_data['photoCount']
                user_review_count = user_data['reviewCount']

                if user_yelp_id == "":
                    pass
                elif user_yelp_id not in yelp_user_dict:
                    user_csv.writerow(
                        [user_yelp_id, user_name, user_city, user_state,
                         user_elite,
                         user_friend_count, user_review_count,
                         user_photo_count])

                    yelp_user_dict[user_yelp_id] = None

                # Review data
                try:
                    business_owner_reply = each_review['businessOwnerReplies'][
                        0]
                except:
                    business_owner_reply = ""

                review_id = each_review['id']
                review_written = each_review['comment']['text']
                review_rating = each_review['rating']
                review_feedback_cool = each_review['feedback']['counts']['cool']
                review_feedback_funny = each_review['feedback']['counts'][
                    'funny']
                review_feedback_useful = each_review['feedback']['counts'][
                    'useful']
                review_date = each_review['localizedDate']

                review_written = review_written.replace("&amp;#39;", "\'") \
                    .replace("<br&gt", "").replace("&amp;#34;", "\"") \
                    .replace("\n", "")
                review_written = review_written.replace("  ", " ").replace(";;",
                                                                           "").replace(
                    ";-", ":").replace("&amp;amp;", "&")

                for i in range(0, 6, 1):
                    business_hours_csv.writerow(
                        [business_id, business_name, i, hours_opened[i]])

                reviews_csv.writerow(
                    [review_id, business_id, business_name, user_yelp_id,
                     user_name,
                     review_date, review_rating, review_feedback_cool,
                     review_feedback_funny, review_feedback_useful,
                     business_owner_reply, review_written])

        print("------------")
    # remove_duplicates(business_hours_filename,
    #                   "yelp_data_business_hours_processed.csv")
    # remove_duplicates(reviews_filename, "yelp_data_reviews_processed.csv")
    # remove_duplicates(user_filename, "yelp_data_users_processed.csv")

    business_hours_file.close()
    reviews_file.close()
    user_file.close()

    remove_duplicates(business_hours_filename)
    remove_duplicates(reviews_filename)
    remove_duplicates(user_filename)

    # os.remove(business_hours_filename)
    # os.remove(reviews_filename)
    # os.remove(user_filename)

    # copyfile(r"C:\Users\chanc\PycharmProjects\YS\yelp_data_business_hours.csv",
    #          r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads")
    #
    # copyfile(
    #     r"C:\Users\chanc\PycharmProjects\YS\yelp_data_business_reviews.csv.csv",
    #     r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads")
    #
    # copyfile(r"C:\Users\chanc\PycharmProjects\YS\yelp_data_users.csv",
    #          r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads")
    #


def remove_duplicates(filename):
    df = pd.read_csv(filename)
    df.drop_duplicates(inplace=True)
    df.to_csv(filename + "temp", index=False, quoting=csv.QUOTE_ALL)
    os.remove(filename)
    os.rename(filename + "temp", filename)


# if __name__ == "__main__":
#     yelp_json_to_csv("somenewfile")
#

def get_list_of_files_in_dir(directory):
    from os import listdir
    from os.path import isfile, join

    onlyfiles = [f for f in listdir(directory) if isfile(join(directory, f))]
    return onlyfiles


def merge_json_files(directory):
    filelist = get_list_of_files_in_dir(directory)
    result = []
    for each_file in filelist:
        with open(directory + "/" + each_file, "r") as infile:
            result.append(json.load(infile))

    with open("merged_file.json", "w") as outfile:

        for each_item in result:
            # print(json.dumps(each_item, indent=4))
            outfile.write(json.dumps(each_item, indent=4) + "\n")

    readfile = "merged_file.json"

    f = open(readfile + "temp", "w", encoding='utf-8', newline='')

    with open(readfile, "r", encoding='utf-8') as json_file:

        f.writelines("[\n")
        for each_line in json_file:
            if (each_line == "{\n"):
                write_line = "\t{\n"
            elif (each_line == "}\n"):
                write_line = "\t},\n"
            else:
                write_line = "\t" + each_line

            f.writelines(write_line)

        f.writelines("\t{\n")
        f.writelines("\t}\n")
        f.writelines("\n]")

    f.close()
    json_file.close()

    os.remove(readfile)
    os.rename(readfile + "temp", readfile)

    infile = open(readfile, "r")
    json_obj = json.load(infile)
    print(json_obj)

    unique_id = []
    output_array = []

    for each_business in json_obj:
        try:
            if each_business['businesses'][0]['id'] not in unique_id:
                print(each_business['businesses'][0])
                unique_id.append(each_business['businesses'][0]['id'])
                output_array.append(each_business['businesses'][0])
        except:
            print(each_business)
            try:
                if each_business['id'] not in unique_id:
                    print(each_business)
                    unique_id.append(each_business['id'])
                    output_array.append(each_business)
            except:
                pass

    with open("merged_file2.json", "w") as outfile:
        for each_item in output_array:
            outfile.write(json.dumps(each_item, indent=4) + "\n")

    correct_json("merged_file2.json")


def csv_remove_duplicate_by_key(infilename):
    infile = open(infilename, "r", encoding='utf-8')
    outfile = open(infilename + "temp", "w", encoding='utf-8',
                   newline='')
    infile_csv = csv.reader(infile)
    outfile_csv = csv.writer(outfile, quoting=csv.QUOTE_ALL)

    unique_dict = {}

    for each_line in infile_csv:
        print(each_line[0])
        if each_line[0] not in unique_dict:
            unique_dict[each_line[0]] = None
            outfile_csv.writerow(each_line)

    infile.close()
    outfile.close()
    os.remove(infilename)
    os.rename(infilename + "temp", infilename)
