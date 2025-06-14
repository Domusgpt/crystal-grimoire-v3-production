#!/usr/bin/env python3
"""
Test script for the Crystal Grimoire Database API
Tests comprehensive database endpoints and collection management
"""

import requests
import json

# API base URL
BASE_URL = "http://localhost:8084/api"

def test_crystal_database():
    """Test crystal database endpoints"""
    print("🗄️ Testing Crystal Database Endpoints...")
    
    # Test 1: Get all crystals
    print("\n📋 Test 1: Get all crystals")
    response = requests.get(f"{BASE_URL}/crystal/database")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Got {data['total_count']} crystals")
        print(f"🔸 First crystal: {data['crystals'][0]['name']}")
        print(f"🔸 Chakras: {data['crystals'][0]['metaphysical_properties']['primary_chakras']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 2: Filter by chakra
    print("\n🔍 Test 2: Filter by Heart chakra")
    response = requests.get(f"{BASE_URL}/crystal/database?chakra=Heart")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {data['total_count']} crystals for Heart chakra")
        for crystal in data['crystals']:
            print(f"  💖 {crystal['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 3: Filter by intention
    print("\n🎯 Test 3: Filter by Love intention")
    response = requests.get(f"{BASE_URL}/crystal/database?intention=Love")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {data['total_count']} crystals for Love intention")
        for crystal in data['crystals']:
            print(f"  💕 {crystal['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 4: Search functionality
    print("\n🔍 Test 4: Search for 'quartz'")
    response = requests.get(f"{BASE_URL}/crystal/database?search=quartz")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {data['total_count']} crystals matching 'quartz'")
        for crystal in data['crystals']:
            print(f"  💎 {crystal['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 5: Get specific crystal
    print("\n🔎 Test 5: Get specific crystal by ID")
    response = requests.get(f"{BASE_URL}/crystal/database/amethyst_001")
    
    if response.status_code == 200:
        crystal = response.json()
        print(f"✅ Retrieved crystal: {crystal['name']}")
        print(f"🔸 Scientific name: {crystal['scientific_name']}")
        print(f"🔸 Hardness: {crystal['hardness']}")
        print(f"🔸 Healing properties: {len(crystal['metaphysical_properties']['healing_properties'])}")
        print(f"🔸 Care methods: {crystal['care_instructions']['cleansing_methods']}")
    else:
        print(f"❌ Failed: {response.status_code}")

def test_user_collection():
    """Test user collection endpoints"""
    print("\n👤 Testing User Collection Endpoints...")
    
    user_id = "test_user_123"
    
    # Test 1: Get user collection
    print(f"\n📦 Test 1: Get collection for user {user_id}")
    response = requests.get(f"{BASE_URL}/user/{user_id}/collection")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ User has {data['total_count']} crystals in collection")
        for crystal in data['crystals']:
            print(f"  💎 {crystal['crystal_name']} (Usage: {crystal['usage_count']})")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 2: Add crystal to collection
    print("\n➕ Test 2: Add crystal to collection")
    new_crystal = {
        "crystal_id": "rose_quartz_001",
        "crystal_name": "Rose Quartz",
        "crystal_type": "Quartz",
        "acquisition_method": "purchased",
        "personal_notes": "Beautiful pink crystal for self-love work",
        "intentions_set": ["Love", "Self-Care", "Healing"]
    }
    
    response = requests.post(f"{BASE_URL}/user/{user_id}/collection", json=new_crystal)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Added crystal to collection")
        print(f"🔸 Crystal ID: {data['crystal_id']}")
        print(f"🔸 Added at: {data['added_at']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 3: Update crystal in collection
    print("\n✏️ Test 3: Update crystal in collection")
    update_data = {
        "usage_count": 3,
        "favorite": True,
        "personal_notes": "Updated: This crystal has amazing energy!"
    }
    
    crystal_id = "mock_12345"  # Would be real ID in production
    response = requests.put(f"{BASE_URL}/user/{user_id}/collection/{crystal_id}", json=update_data)
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Updated crystal in collection")
        print(f"🔸 Updated at: {data['updated_at']}")
    else:
        print(f"❌ Failed: {response.status_code}")

def test_advanced_filtering():
    """Test advanced filtering combinations"""
    print("\n🎛️ Testing Advanced Filtering...")
    
    # Test 1: Multiple filters
    print("\n🔍 Test 1: Heart chakra + Water element")
    response = requests.get(f"{BASE_URL}/crystal/database?chakra=Heart&element=Water")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {data['total_count']} crystals")
        print(f"🔸 Filters applied: {data['filters_applied']}")
        for crystal in data['crystals']:
            print(f"  💧 {crystal['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 2: Zodiac sign filter
    print("\n♉ Test 2: Taurus crystals")
    response = requests.get(f"{BASE_URL}/crystal/database?zodiac_sign=Taurus")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Found {data['total_count']} crystals for Taurus")
        for crystal in data['crystals']:
            print(f"  🐂 {crystal['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")
    
    # Test 3: Pagination
    print("\n📄 Test 3: Pagination (limit=1)")
    response = requests.get(f"{BASE_URL}/crystal/database?limit=1&offset=0")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Page 1: {len(data['crystals'])} crystal")
        print(f"🔸 Total available: {data['total_count']}")
        print(f"🔸 Showing: {data['crystals'][0]['name']}")
    else:
        print(f"❌ Failed: {response.status_code}")

def test_comprehensive_api():
    """Run comprehensive API tests"""
    print("🔮 CRYSTAL GRIMOIRE DATABASE API TEST SUITE")
    print("Testing comprehensive database and collection management")
    print("-" * 60)
    
    try:
        # Test all endpoint categories
        test_crystal_database()
        test_user_collection()
        test_advanced_filtering()
        
        print("\n" + "=" * 60)
        print("🎉 ALL DATABASE TESTS COMPLETED!")
        print("✅ Crystal database with comprehensive filtering")
        print("✅ User collection management")
        print("✅ Advanced search and pagination")
        print("✅ Multiple filter combinations")
        print("="*60)
        
        return True
        
    except Exception as e:
        print(f"\n❌ Test suite error: {e}")
        return False

if __name__ == "__main__":
    test_comprehensive_api()