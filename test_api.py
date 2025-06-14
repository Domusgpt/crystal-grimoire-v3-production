#!/usr/bin/env python3
"""
Test Crystal Grimoire V3 Enhanced Backend APIs
"""

import requests
import json
import time

def test_api():
    base_url = "http://localhost:8081"
    
    print("🔮 Testing Crystal Grimoire V3 Enhanced Backend")
    print(f"📡 Base URL: {base_url}")
    print()
    
    # Test 1: Health Check
    try:
        print("1️⃣ Testing Health Check...")
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health: {data['status']}")
            print(f"   Version: {data['version']}")
            print(f"   Gemini API: {data['apis']['gemini']}")
            print(f"   Firebase: {data['apis']['firebase']}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Health check error: {e}")
    
    print()
    
    # Test 2: Moon Phase
    try:
        print("2️⃣ Testing Moon Phase...")
        response = requests.get(f"{base_url}/api/moon/current-phase", timeout=5)
        if response.status_code == 200:
            data = response.json()
            moon = data['moon_phase']
            print(f"✅ Current Moon Phase: {moon['name']} {moon['emoji']}")
        else:
            print(f"❌ Moon phase failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Moon phase error: {e}")
    
    print()
    
    # Test 3: Moon Ritual for Full Moon
    try:
        print("3️⃣ Testing Moon Rituals...")
        response = requests.get(f"{base_url}/api/moon/rituals/full", timeout=5)
        if response.status_code == 200:
            data = response.json()
            ritual = data['ritual']
            print(f"✅ Full Moon Ritual: {ritual['name']}")
            print(f"   Focus: {ritual['focus']}")
            print(f"   Duration: {ritual['duration']} minutes")
            print(f"   Crystals: {', '.join(ritual['recommended_crystals'][:3])}...")
        else:
            print(f"❌ Moon ritual failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Moon ritual error: {e}")
    
    print()
    
    # Test 4: System Status
    try:
        print("4️⃣ Testing System Status...")
        response = requests.get(f"{base_url}/api/status", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ System Status: {data['status']}")
            services = data['services']
            for service, status in services.items():
                emoji = "✅" if status == "online" else "❌"
                print(f"   {emoji} {service}: {status}")
        else:
            print(f"❌ System status failed: {response.status_code}")
    except Exception as e:
        print(f"❌ System status error: {e}")
    
    print()
    
    # Test 5: Dream Journal Creation
    try:
        print("5️⃣ Testing Dream Journal...")
        dream_data = {
            "user_id": "test_user_123",
            "dream_content": "I dreamed of flying over a crystal mountain with purple amethyst everywhere. The moon was full and bright.",
            "crystals_present": ["amethyst", "clear_quartz"],
            "dream_date": "2025-01-05T07:00:00Z",
            "additional_data": {
                "lucidity": "moderate",
                "emotional_tone": "peaceful"
            }
        }
        
        response = requests.post(
            f"{base_url}/api/dreams/create", 
            json=dream_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Dream Entry Created: {data['dream_id']}")
            moon = data['moon_phase']
            print(f"   Moon Phase: {moon['name']} {moon['emoji']}")
            elements = data['extracted_elements']
            print(f"   Emotional Tone: {elements.get('emotional_tone', 'N/A')}")
            print(f"   Themes: {', '.join(elements.get('themes', [])[:3])}")
        else:
            print(f"❌ Dream creation failed: {response.status_code}")
            print(f"   Response: {response.text[:200]}...")
    except Exception as e:
        print(f"❌ Dream creation error: {e}")
    
    print()
    print("🎯 API Testing Complete!")

if __name__ == "__main__":
    test_api()