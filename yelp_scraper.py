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

def print_business_data(json_api_file):
    with open('outfile2.csv', 'w', encoding='utf-8',
              newline='') as myfile:
        wr = csv.writer(myfile)
        wr.writerow(
            ["business_id", "business_name", "author", "review_date", "rating",
             "review"])

        myfile.close()

    with open(json_api_file) as json_file:
        data = json.load(json_file)
        for p in data['businesses']:
            print(p)
            print(p['id'])
            print(p['name'])
            print(p['coordinates'])
            print(p['location'])
            print(p['rating'])
            print(p['review_count'])
            print(p['url'])
            print(p['url'].split("?", 1)[0])
            get_reviews_json(p['url'].split("?", 1)[0], p['id'], p['name'])
            print("----------")


def get_reviews(yelp_restaurant_url, business_id, business_name):
    num_of_reviews = 0

    r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

    soup = BeautifulSoup(r.content, features="lxml")

    page_detail = soup.find("span", {
        "class": "lemon--span__373c0__3997G text__373c0__2Kxyz text-color--black-extra-light__373c0__2OyzO text-align--left__373c0__2XGa-"}).string
    num_of_pages = int(page_detail.replace("1 of ", ''))

    print(num_of_pages)
    max_reviews = num_of_pages * 20

    for num_of_reviews in range(0, max_reviews, 20):
        r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

        soup = BeautifulSoup(r.content, features="lxml")

        print(soup)

        for review_page in soup.findAll("div", {"itemprop": "review"}):
            rating = review_page.find("meta", {"itemprop": "ratingValue"})[
                'content']
            author = review_page.find("meta", {"itemprop": "author"})[
                'content']

            review_date = \
                review_page.find("meta", {"itemprop": "datePublished"})[
                    'content']

            description = review_page.find("p", {
                "itemprop": "description"}).string

            description = description.replace('\n\n', '\n')
            description = description.replace('&amp;', '&')
            description = re.sub(' +', ' ', description)

            print("Rating:" + rating)
            print("Author:" + author)
            print("ReviewDate:" + review_date)
            print("Description:" + description)

            with open('outfilev2.csv', 'a', encoding='utf-8',
                      newline='') as myfile:
                wr = csv.writer(myfile)
                wr.writerow(
                    [business_id, business_name, author, review_date, rating,
                     description])
            myfile.close()
            print("-----------")


def get_reviews_json(yelp_restaurant_url, business_id, business_name):
    num_of_reviews = 0

    r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

    soup = BeautifulSoup(r.content, features="lxml")

    try:
        page_detail = soup.find("span", {
            "class": "lemon--span__373c0__3997G text__373c0__2Kxyz text-color--black-extra-light__373c0__2OyzO text-align--left__373c0__2XGa-"}).string
        num_of_pages = int(page_detail.replace("1 of ", ''))

        print(num_of_pages)
        max_reviews = num_of_pages * 20
    except Exception as e:
        print(e)
        input("Press any key to continue")

        r = requests.get(yelp_restaurant_url + "?start=" + str(num_of_reviews))

        soup = BeautifulSoup(r.content, features="lxml")

        page_detail = soup.find("span", {
            "class": "lemon--span__373c0__3997G text__373c0__2Kxyz text-color--black-extra-light__373c0__2OyzO text-align--left__373c0__2XGa-"}).string
        num_of_pages = int(page_detail.replace("1 of ", ''))

        print(num_of_pages)
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
        with open('data.jsonl', 'a+', encoding='utf8') as outfile:
            json.dump(y, outfile, indent=4, separators=(',', ': '),
                      sort_keys=True)
            outfile.write(",\n")
            print("-----------")


def get_businesses(search_term):
    API_KEY = get_my_key()
    ENDPOINT = 'https://api.yelp.com/v3/businesses/search'
    HEADERS = {'Authorization': 'bearer %s' % API_KEY}

    PARAMETERS = {'term': search_term,
                  'limit': 50,
                  'radius': 10000,
                  'location': 'Boston, MA'}

    response = requests.get(url=ENDPOINT,
                            params=PARAMETERS,
                            headers=HEADERS)

    business_data = response.json()

    print(json.dumps(business_data, indent=3))

    now = datetime.now()
    current_time = now.strftime("%y-%m-%d %H-%M-%S")
    filename = current_time + " API file.json"

    file = open(filename, "w")
    file.write(json.dumps(business_data, indent=3))
    file.close()


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


def correct_json():
    f = open("somenewfile", "w", encoding='utf-8')

    with open('newfile', encoding='utf-8') as json_file:

        f.writelines("[\n")
        for each_line in json_file:
            if (each_line == "{\n"):
                write_line = "\t{\n"
            elif (each_line == "}\n"):
                write_line = "\t},\n"
            else:
                write_line = "\t" + each_line

            f.writelines(write_line)

        f.writelines("\n]")


def yelp_json_reader(filename):
    with open(filename, encoding='utf-8') as json_file:
        data = json_file.read()
        json_data = json.loads(data)

        criteria = json_data[0]['bizDetailsPageProps']['bizHoursProps']

        for each_key in criteria.keys():
            print(each_key)

        print("------------")

        for review_page in json_data:
            business_root = review_page['bizDetailsPageProps']

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
                business_site = business_root['bizContactInfoProps']['businessWebsite']['linkText']
            except Exception as e:
                business_site = ''

            for each_review in review_page['bizDetailsPageProps']['reviewFeedQueryProps']['reviews']:
                # User Data
                user_data = each_review['user']
                user_name = user_data['altText']
                user_location = user_data['displayLocation']
                user_elite_location = user_data['eliteYear']
                user_friend_count = user_data['friendCount']
                user_yelp_id = user_data['link']
                user_photo_count = user_data['photoCount']
                user_review_count = user_data['reviewCount']

                # Review data
                business_owner_reply = each_review['businessOwnerReplies']
                review_rating = each_review['rating']
                review_feedback_cool = each_review['feedback']['counts']['cool']
                review_feedback_funny = each_review['feedback']['counts']['funny']
                review_feedback_useful = each_review['feedback']['counts']['useful']
                review_date = each_review['localizedDate']



        print("------------")



if __name__ == "__main__":
    # get_businesses("coffee")
    # print_business_data("20-06-10 16-31-00 API file.json")
    # print_business_data("20-06-13 15-24-02 API file.json")

    # correct_json()
    yelp_json_reader("somenewfile")

    # f = open("newfile", "w", encoding='utf-8')
    #
    #
    # with open("data2.jsonl", encoding='utf-8') as json_file:
    #     for each_line in json_file:
    #         # print(each_line)
    #         if (each_line == "}\n"):
    #             write_line = "},\n"
    #         else:
    #             write_line = each_line
    #         f.writelines(write_line)
