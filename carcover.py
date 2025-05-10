#!/usr/bin/env python3
# OLX Car Cover Scraper - Extracts car cover listings from OLX India

import requests
from bs4 import BeautifulSoup
import json
import csv
import time
import random
from datetime import datetime

def scrape_olx_car_covers(num_pages=3):
    """
    Scrape car cover listings from OLX India
    
    Args:
        num_pages: Number of pages to scrape (default 3)
        
    Returns:
        List of dictionaries containing car cover listings
    """
    base_url = "https://www.olx.in/items/q-car-cover"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
    }
    
    all_listings = []
    
    for page in range(1, num_pages + 1):
        url = f"{base_url}?page={page}"
        print(f"Scraping page {page}...")
        
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find all listing containers - this selector might need adjustment based on OLX's current HTML structure
            listing_containers = soup.select('li.EIR5N')
            
            for container in listing_containers:
                try:
                    # Extract relevant data
                    title_elem = container.select_one('span.fcSD0')
                    price_elem = container.select_one('span._2Ks63')
                    location_elem = container.select_one('span._2VQu4')
                    date_elem = container.select_one('span._2Vp0i')
                    link_elem = container.select_one('a')
                    
                    # Handle potential missing elements
                    title = title_elem.text.strip() if title_elem else "No Title"
                    price = price_elem.text.strip() if price_elem else "No Price"
                    location = location_elem.text.strip() if location_elem else "No Location"
                    date = date_elem.text.strip() if date_elem else "No Date"
                    link = "https://www.olx.in" + link_elem['href'] if link_elem and 'href' in link_elem.attrs else ""
                    
                    # Create listing dictionary
                    listing = {
                        'title': title,
                        'price': price,
                        'location': location,
                        'date': date,
                        'link': link
                    }
                    
                    all_listings.append(listing)
                except Exception as e:
                    print(f"Error extracting listing details: {e}")
            
            # Sleep between requests to avoid overloading the server
            if page < num_pages:
                sleep_time = random.uniform(1.5, 3.5)
                time.sleep(sleep_time)
                
        except Exception as e:
            print(f"Error fetching page {page}: {e}")
    
    print(f"Total listings scraped: {len(all_listings)}")
    return all_listings

def save_to_csv(listings, filename="olx_car_covers.csv"):
    """Save listings to CSV file"""
    if not listings:
        print("No listings to save.")
        return
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = listings[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for listing in listings:
            writer.writerow(listing)
    
    print(f"Data saved to {filename}")

def save_to_json(listings, filename="olx_car_covers.json"):
    """Save listings to JSON file"""
    if not listings:
        print("No listings to save.")
        return
    
    with open(filename, 'w', encoding='utf-8') as jsonfile:
        json.dump(listings, jsonfile, indent=2, ensure_ascii=False)
    
    print(f"Data saved to {filename}")

if __name__ == "__main__":
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Scrape listings from OLX
    listings = scrape_olx_car_covers(num_pages=3)
    
    if listings:
        # Save data to CSV and JSON
        csv_filename = f"olx_car_covers_{timestamp}.csv"
        json_filename = f"olx_car_covers_{timestamp}.json"
        
        save_to_csv(listings, csv_filename)
        save_to_json(listings, json_filename)
        
        print("Scraping completed successfully!")
    else:
        print("No data was scraped. Please check the website structure or your internet connection.")
        
        
#         Data Extraction Scripts



# This repository contains two data extraction scripts:

# OLX Car Cover Scraper - A Python script to extract car cover listings from OLX India
# AMFI NAV Extractor - A shell script to extract mutual fund data from AMFI

# OLX Car Cover Scraper
# Description
# This Python script scrapes car cover listings from OLX India. It extracts details such as title, price, location, date, and links for each listing and saves them in both CSV and JSON formats.
# Features

# Extracts multiple pages of search results (configurable)
# Saves data in both CSV and JSON formats
# Implements polite scraping with random delays between requests
# Error handling for robust operation
# Timestamps output files for easy tracking

# Requirements

# Python 3.6+
# Required packages: requests, beautifulsoup4

# Installation
# bashpip install requests beautifulsoup4
# Usage
# bashpython olx_scraper.py
# Output
# The script generates two files:

# olx_car_covers_[timestamp].csv - CSV format data
# olx_car_covers_[timestamp].json - JSON format data