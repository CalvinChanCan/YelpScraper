import json
import csv


def convert_json_to_csv(filename):
    header = ['business_id', 'business_name', 'review_count', 'rating',
              'latitude', 'longitude', 'price', 'city', 'zip_code',
              'state', 'country', 'display_address', 'phone']
    csv_file = open('converted_json.csv', 'w', newline='')
    csv_writer = csv.writer(csv_file)

    csv_writer.writerow(header)

    with open(filename) as json_file:
        json_object = json.load(json_file)

        for each_business in json_object['businesses']:
            json_str = json.dumps(each_business, indent=5)
            business_id = each_business['id']
            business_name = each_business['name']
            review_count = each_business['review_count']
            rating = each_business['rating']
            coordinates = each_business['coordinates']
            latitude = each_business['coordinates']['latitude']
            longitude = each_business['coordinates']['longitude']

            if "price" not in each_business:
                price = ""
            else:
                price = each_business['price']

            print(price)

            location = each_business['location']
            city = each_business['location']['city']
            zip_code = each_business['location']['zip_code'].zfill(5)
            state = each_business['location']['state']
            country = each_business['location']['country']
            display_address = each_business['location']['display_address']

            address = display_address[0] + ", " + display_address[1]


            phone = each_business['phone']

            csv_writer.writerow([business_id, business_name, review_count,
                                 rating, latitude, longitude, price, city,
                                 zip_code, state, country, address,
                                 phone])





if __name__ == "__main__":
    convert_json_to_csv('20-06-04 16-00-04 API file.json')
