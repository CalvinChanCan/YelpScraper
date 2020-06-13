import os
import glob
import pandas as pd
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
            get_reviews2(p['url'].split("?", 1)[0], p['id'], p['name'])
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

        for each_review in soup.findAll("div", {"itemprop": "review"}):

            rating = each_review.find("meta", {"itemprop": "ratingValue"})[
                'content']
            author = each_review.find("meta", {"itemprop": "author"})[
                'content']

            review_date = \
                each_review.find("meta", {"itemprop": "datePublished"})[
                    'content']

            description = each_review.find("p", {
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
            [each_row[0], each_row[1], username, each_row[3], each_row[4], new_review])

        # outfile


if __name__ == "__main__":
    #get_businesses("korean")
    #print_business_data("20-06-10 16-31-00 API file.json")
    get_reviews("https://www.yelp.com/biz/cathay-center-weymouth", "test","Cathay Center")
