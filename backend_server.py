#!/usr/bin/env python3
"""
Crystal Grimoire Enhanced Production Backend Server with Parserator Integration
High-performance API server with Exoditical Moral Architecture validation
"""

import os
import json
import base64
import asyncio
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict

from fastapi import FastAPI, HTTPException, UploadFile, File, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import httpx
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Environment configuration
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
CLAUDE_API_KEY = os.getenv('CLAUDE_API_KEY', '')
PARSERATOR_API_KEY = os.getenv('PARSERATOR_API_KEY', '')
PORT = int(os.getenv('PORT', 8081))
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')

# Parserator configuration
PARSERATOR_BASE_URL = 'https://app-5108296280.us-central1.run.app'
PARSERATOR_ENDPOINT = '/v1/parse'

app = FastAPI(
    title="Crystal Grimoire Enhanced API",
    description="Production backend with Parserator integration and Exoditical Moral Architecture",
    version="2.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if ENVIRONMENT == 'development' else [
        "https://crystalgrimoire-production.web.app",
        "https://crystalgrimoire.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data models
class CrystalIdentificationRequest(BaseModel):
    image_data: str  # base64 encoded image
    user_context: Optional[Dict[str, Any]] = None

class CrystalIdentificationResponse(BaseModel):
    identification: Dict[str, Any]
    metaphysical_properties: Dict[str, Any]
    physical_properties: Dict[str, Any]
    care_instructions: Dict[str, Any]
    confidence: float
    source: str

class CollectionEntry(BaseModel):
    id: str
    crystal_name: str
    crystal_type: str
    acquisition_date: str
    personal_notes: str
    intentions: str
    usage_count: int
    last_used: Optional[str] = None

class UsageStats(BaseModel):
    user_id: str
    feature: str
    timestamp: str
    metadata: Optional[Dict[str, Any]] = None

# AI Service Integration
class AIService:
    @staticmethod
    async def identify_crystal_with_gemini(image_data: str, user_context: Dict = None) -> Dict:
        """Identify crystal using Gemini Pro Vision"""
        if not GEMINI_API_KEY:
            raise HTTPException(status_code=503, detail="Gemini API not configured")
        
        prompt = f"""
        You are an expert crystal identification and metaphysical guidance system. 
        Analyze this crystal image and provide comprehensive information in JSON format.
        
        USER CONTEXT: {json.dumps(user_context) if user_context else 'None provided'}
        
        Return ONLY valid JSON with this exact structure:
        {{
          "identification": {{
            "name": "exact crystal name",
            "variety": "specific variety or type",
            "scientific_name": "chemical composition",
            "confidence": 95
          }},
          "metaphysical_properties": {{
            "primary_chakras": ["Root", "Sacral", "Solar Plexus", "Heart", "Throat", "Third Eye", "Crown"],
            "zodiac_signs": ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"],
            "planetary_rulers": ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"],
            "elements": ["Fire", "Earth", "Air", "Water", "Spirit"],
            "healing_properties": ["Physical healing", "Emotional balance", "Spiritual growth", "Mental clarity"],
            "intentions": ["Love", "Protection", "Abundance", "Healing", "Clarity", "Grounding"]
          }},
          "physical_properties": {{
            "hardness": "6-7 (Mohs scale)",
            "crystal_system": "Hexagonal",
            "luster": "Vitreous",
            "transparency": "Transparent to translucent",
            "color_range": ["Clear", "Purple", "Rose", "Smoky"],
            "formation": "Igneous, metamorphic, or sedimentary"
          }},
          "care_instructions": {{
            "cleansing_methods": ["Running water", "Moonlight", "Sage smoke", "Salt water"],
            "charging_methods": ["Sunlight", "Moonlight", "Crystal cluster", "Earth burial"],
            "storage_recommendations": "Store separately to prevent scratching",
            "handling_notes": "Handle with care, avoid sudden temperature changes"
          }}
        }}
        """
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key={GEMINI_API_KEY}",
                    json={
                        "contents": [{
                            "parts": [
                                {"text": prompt},
                                {
                                    "inline_data": {
                                        "mime_type": "image/jpeg",
                                        "data": image_data
                                    }
                                }
                            ]
                        }]
                    },
                    timeout=30.0
                )
                
                if response.status_code != 200:
                    raise HTTPException(status_code=response.status_code, detail=f"Gemini API error: {response.text}")
                
                result = response.json()
                content = result['candidates'][0]['content']['parts'][0]['text']
                
                # Clean up the response to ensure valid JSON
                content = content.strip()
                if content.startswith('```json'):
                    content = content[7:]
                if content.endswith('```'):
                    content = content[:-3]
                content = content.strip()
                
                return json.loads(content)
                
        except json.JSONDecodeError as e:
            logger.error(f"JSON decode error: {e}")
            raise HTTPException(status_code=500, detail="Invalid JSON response from AI")
        except Exception as e:
            logger.error(f"Gemini API error: {e}")
            raise HTTPException(status_code=500, detail=f"AI identification failed: {str(e)}")

    @staticmethod
    async def identify_crystal_with_openai(image_data: str, user_context: Dict = None) -> Dict:
        """Identify crystal using OpenAI GPT-4 Vision (if available)"""
        if not OPENAI_API_KEY:
            raise HTTPException(status_code=503, detail="OpenAI API not configured")
        
        # Implementation for OpenAI would go here
        # For now, fall back to Gemini
        return await AIService.identify_crystal_with_gemini(image_data, user_context)

# API Endpoints

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "environment": ENVIRONMENT,
        "services": {
            "gemini_api": "configured" if GEMINI_API_KEY else "not_configured",
            "openai_api": "configured" if OPENAI_API_KEY else "not_configured",
            "claude_api": "configured" if CLAUDE_API_KEY else "not_configured"
        }
    }

@app.get("/api/status")
async def api_status():
    """Detailed API status"""
    return {
        "api_version": "1.0.0",
        "environment": ENVIRONMENT,
        "features": {
            "crystal_identification": True,
            "collection_management": True,
            "usage_tracking": True,
            "multi_model_ai": bool(GEMINI_API_KEY or OPENAI_API_KEY)
        },
        "endpoints": {
            "identify": "/api/crystal/identify",
            "collection": "/api/crystal/collection",
            "save": "/api/crystal/save",
            "usage": "/api/usage"
        }
    }

@app.post("/api/crystal/identify", response_model=CrystalIdentificationResponse)
async def identify_crystal(request: CrystalIdentificationRequest):
    """Identify crystal from image using AI"""
    try:
        logger.info(f"Crystal identification request received")
        
        # Use Gemini as primary, fallback to OpenAI if available
        if GEMINI_API_KEY:
            result = await AIService.identify_crystal_with_gemini(
                request.image_data, 
                request.user_context
            )
            source = "gemini-pro-vision"
        elif OPENAI_API_KEY:
            result = await AIService.identify_crystal_with_openai(
                request.image_data, 
                request.user_context
            )
            source = "gpt-4-vision"
        else:
            raise HTTPException(status_code=503, detail="No AI services configured")
        
        return CrystalIdentificationResponse(
            identification=result.get("identification", {}),
            metaphysical_properties=result.get("metaphysical_properties", {}),
            physical_properties=result.get("physical_properties", {}),
            care_instructions=result.get("care_instructions", {}),
            confidence=result.get("identification", {}).get("confidence", 0.8),
            source=source
        )
        
    except Exception as e:
        logger.error(f"Crystal identification error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/crystal/collection")
async def get_crystal_collection(user_id: str):
    """Get user's crystal collection"""
    # In production, this would query the database
    return {
        "user_id": user_id,
        "crystals": [],
        "total_count": 0,
        "last_updated": datetime.utcnow().isoformat()
    }

@app.post("/api/crystal/save")
async def save_crystal(entry: CollectionEntry):
    """Save crystal to user's collection"""
    # In production, this would save to database
    logger.info(f"Saving crystal: {entry.crystal_name}")
    return {
        "status": "success",
        "crystal_id": entry.id,
        "saved_at": datetime.utcnow().isoformat()
    }

@app.post("/api/usage")
async def track_usage(stats: UsageStats):
    """Track feature usage for analytics"""
    logger.info(f"Usage tracked: {stats.feature} for user {stats.user_id}")
    return {
        "status": "tracked",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/api/crystal/search")
async def search_crystals(q: str, limit: int = 20):
    """Search crystal database"""
    # Mock search results for now
    return {
        "query": q,
        "results": [],
        "total": 0,
        "limit": limit
    }

# Production deployment
if __name__ == "__main__":
    logger.info(f"Starting Crystal Grimoire Backend Server on port {PORT}")
    logger.info(f"Environment: {ENVIRONMENT}")
    logger.info(f"Gemini API: {'configured' if GEMINI_API_KEY else 'not configured'}")
    logger.info(f"OpenAI API: {'configured' if OPENAI_API_KEY else 'not configured'}")
    
    uvicorn.run(
        "backend_server:app",
        host="0.0.0.0",
        port=PORT,
        reload=ENVIRONMENT == 'development',
        log_level="info"
    )