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

from fastapi import FastAPI, HTTPException, UploadFile, File, BackgroundTasks, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import httpx
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
import uuid

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

# Initialize Firebase Admin SDK
try:
    cred = credentials.Certificate("firebase-service-account.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    logger.info("Firebase Admin SDK initialized successfully.")
except Exception as e:
    logger.error(f"Error initializing Firebase Admin SDK: {e}")
    db = None # Set db to None if initialization fails

crystals_collection = db.collection('crystals') if db else None

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

# CrystalIdentificationResponse is deprecated in favor of UnifiedCrystalData for this endpoint.
# class CrystalIdentificationResponse(BaseModel):
#     identification: Dict[str, Any]
#     metaphysical_properties: Dict[str, Any]
#     physical_properties: Dict[str, Any]
#     care_instructions: Dict[str, Any]
#     confidence: float
#     source: str

# CollectionEntry is deprecated in favor of UnifiedCrystalData for main crystal operations.
# class CollectionEntry(BaseModel):
#     id: str
#     crystal_name: str
#     crystal_type: str
#     acquisition_date: str
#     personal_notes: str
#     intentions: str
#     usage_count: int
#     last_used: Optional[str] = None

class UsageStats(BaseModel):
    user_id: str
    feature: str
    timestamp: str
    metadata: Optional[Dict[str, Any]] = None

# Unified Data Models (based on UNIFIED_DATA_MODEL.md)

class VisualAnalysis(BaseModel):
    primary_color: str
    secondary_colors: List[str] = []
    transparency: str
    formation: str
    size_estimate: Optional[str] = None # Not in all examples, make optional

class Identification(BaseModel):
    stone_type: str
    crystal_family: str
    variety: Optional[str] = None # Not in all examples, make optional
    confidence: float

class EnergyMapping(BaseModel):
    primary_chakra: str
    secondary_chakras: List[str] = []
    chakra_number: int # Assuming this is derived or provided
    vibration_level: Optional[str] = None # Not in all examples, make optional

class AstrologicalData(BaseModel):
    primary_signs: List[str] = []
    compatible_signs: List[str] = []
    planetary_ruler: Optional[str] = None # Not in all examples, make optional
    element: Optional[str] = None # Not in all examples, make optional

class NumerologyData(BaseModel):
    crystal_number: int
    color_vibration: int
    chakra_number: int # Repeated from EnergyMapping, but present in model
    master_number: int

class CrystalCore(BaseModel):
    id: str # auto_generated_uuid
    timestamp: str # iso_string
    confidence_score: float
    visual_analysis: VisualAnalysis
    identification: Identification
    energy_mapping: EnergyMapping
    astrological_data: AstrologicalData
    numerology: NumerologyData

class UserIntegration(BaseModel):
    user_id: Optional[str] = None # Allow anonymous/system crystals
    added_to_collection: Optional[str] = None # timestamp
    personal_rating: Optional[int] = None # 1-10
    usage_frequency: Optional[str] = None # daily|weekly|monthly|occasional
    user_experiences: List[str] = []
    intention_settings: List[str] = []

class AutomaticEnrichment(BaseModel):
    crystal_bible_reference: Optional[str] = None
    healing_properties: List[str] = []
    usage_suggestions: List[str] = []
    care_instructions: List[str] = []
    synergy_crystals: List[str] = []
    mineral_class: Optional[str] = None # Added for rule-based classification

class UnifiedCrystalData(BaseModel):
    crystal_core: CrystalCore
    user_integration: Optional[UserIntegration] = None
    automatic_enrichment: Optional[AutomaticEnrichment] = None

# Numerology Constants and Calculation
NUMEROLOGY_LETTER_VALUES = {
    'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9,
    'j': 1, 'k': 2, 'l': 3, 'm': 4, 'n': 5, 'o': 6, 'p': 7, 'q': 8, 'r': 9,
    's': 1, 't': 2, 'u': 3, 'v': 4, 'w': 5, 'x': 6, 'y': 7, 'z': 8
}

def calculate_name_numerology_number(name: str) -> int:
    if not name or not isinstance(name, str):
        return 0

    name_lower = name.lower()
    total = 0
    for char in name_lower:
        total += NUMEROLOGY_LETTER_VALUES.get(char, 0)

    # Reduce to single digit (1-9), unless it's a master number 11, 22, 33 (though the spec only shows 1-9 reduction)
    # The example "AMETHYST = 30 = 3+0 = 3" suggests simple reduction.
    # For "sum all digits" and "reduce to single digit":
    while total > 9:
        s = str(total)
        total = sum(int(digit) for digit in s)
        # Handle cases like 19 -> 10 -> 1, ensure it fully reduces if intermediate sum is > 9
        if total <=9: # if fully reduced, break
            break
        # if total is 11, 22, 33, it could be a master number, but the spec says reduce to 1-9
        # and example shows 30 -> 3. So, we continue reducing.
    return total if total != 0 else 0 # Return 0 if name was empty or invalid chars only

def map_ai_response_to_unified_data(ai_response: Dict) -> UnifiedCrystalData:
    core_data = ai_response.get("crystal_core", {})
    enrichment_data = ai_response.get("automatic_enrichment", {})

    # Visual Analysis
    va_data = core_data.get("visual_analysis", {})
    visual_analysis = VisualAnalysis(
        primary_color=va_data.get("primary_color", "Unknown"),
        secondary_colors=va_data.get("secondary_colors", []),
        transparency=va_data.get("transparency", "Unknown"),
        formation=va_data.get("formation", "Unknown"),
        size_estimate=va_data.get("size_estimate")
    )

    # Identification
    id_data = core_data.get("identification", {})
    identification = Identification(
        stone_type=id_data.get("stone_type", "Unknown"),
        crystal_family=id_data.get("crystal_family", "Unknown"),
        variety=id_data.get("variety"),
        confidence=id_data.get("confidence", 0.0)
    )

    # Energy Mapping & Astrological Data from Color
    em_data = core_data.get("energy_mapping", {})
    ad_data = core_data.get("astrological_data", {})

    ai_primary_chakra = em_data.get("primary_chakra", "Unknown")
    ai_chakra_number = em_data.get("chakra_number", 0)
    ai_secondary_chakras = em_data.get("secondary_chakras", [])
    ai_primary_signs = ad_data.get("primary_signs", [])

    # --- NEW MAPPING LOGIC based on simplified AI response ---
    # ai_response is now expected to be a flatter JSON object.
    # We will use .get() extensively to access potential keys.

    # Visual Analysis
    visual_analysis = VisualAnalysis(
        primary_color=ai_response.get("primary_color", "Unknown"),
        secondary_colors=ai_response.get("secondary_colors", []),
        transparency=ai_response.get("transparency", "Unknown"),
        formation=ai_response.get("formation", "Unknown"),
        size_estimate=ai_response.get("size_estimate")
    )

    # Identification
    identification = Identification(
        stone_type=ai_response.get("stone_name", ai_response.get("name", "Unknown")), # Allow 'name' or 'stone_name'
        crystal_family=ai_response.get("crystal_family", "Unknown"),
        variety=ai_response.get("variety"),
        confidence=ai_response.get("identification_confidence", 0.0)
    )

    # Energy Mapping & Astrological Data from Color & AI
    ai_primary_chakra = ai_response.get("primary_chakra", "Unknown")
    ai_chakra_number = ai_response.get("chakra_number", 0) # AI might provide this directly
    ai_secondary_chakras = ai_response.get("secondary_chakras", [])
    ai_primary_signs = ai_response.get("primary_zodiac_signs", [])

    # Detailed Color-to-Chakra-Signs Mapping (from UNIFIED_DATA_MODEL.md)
    COLOR_CHAKRA_SIGN_MAP = {
        "red": {"primary_chakra": "root", "number": 1, "signs": ["aries", "scorpio"]},
        "orange": {"primary_chakra": "sacral", "number": 2, "signs": ["leo", "sagittarius"]},
        "yellow": {"primary_chakra": "solar_plexus", "number": 3, "signs": ["gemini", "virgo"]},
        "green": {"primary_chakra": "heart", "number": 4, "signs": ["taurus", "libra"]},
        "pink": {"primary_chakra": "heart", "number": 4, "signs": ["taurus", "libra"]}, # Added pink
        "blue": {"primary_chakra": "throat", "number": 5, "signs": ["aquarius", "gemini"]},
        "purple": {"primary_chakra": "third_eye", "number": 6, "signs": ["pisces", "sagittarius"]},
        "violet": {"primary_chakra": "crown", "number": 7, "signs": ["pisces", "aquarius"]},
        "white": {"primary_chakra": "crown", "number": 7, "signs": ["cancer", "pisces"]},
        "clear": {"primary_chakra": "all_chakras", "number": 0, "signs": ["all"]}, # 'all_chakras' special case
        "black": {"primary_chakra": "root", "number": 1, "signs": ["capricorn", "scorpio"]},
        "brown": {"primary_chakra": "root", "number": 1, "signs": ["capricorn", "virgo"]} # Added brown
    }

    # Use color mapping if AI data is missing or default
    mapped_chakra_info = COLOR_CHAKRA_SIGN_MAP.get(visual_analysis.primary_color.lower())

    final_primary_chakra = ai_primary_chakra
    final_chakra_number = ai_chakra_number
    final_secondary_chakras = ai_secondary_chakras # For now, secondary chakras are not in this map
    final_primary_signs = ai_primary_signs

    if mapped_chakra_info:
        if final_primary_chakra == "Unknown" or final_primary_chakra == "":
            final_primary_chakra = mapped_chakra_info["primary_chakra"]
        if final_chakra_number == 0 and mapped_chakra_info["number"] != 0 : # Allow AI to specify 0 for "all_chakras" if it did
            final_chakra_number = mapped_chakra_info["number"]
        if not final_primary_signs and mapped_chakra_info["signs"] != ["all"]: # Don't override if AI gave signs
             # Add signs from map if AI didn't provide any, and they are not 'all'
            final_primary_signs = list(set(final_primary_signs + mapped_chakra_info["signs"]))


    energy_mapping = EnergyMapping(
        primary_chakra=final_primary_chakra,
        secondary_chakras=final_secondary_chakras, # AI or default empty
        chakra_number=final_chakra_number,
        vibration_level=em_data.get("vibration_level")
    )

    astrological_data = AstrologicalData(
        primary_signs=final_primary_signs, # Potentially updated by color map
        compatible_signs=ad_data.get("compatible_signs", []),
        planetary_ruler=ad_data.get("planetary_ruler"),
        element=ad_data.get("element")
    )

    # Numerology Data
    num_data = core_data.get("numerology", {})
    ai_crystal_number = num_data.get("crystal_number", 0)
    ai_color_vibration = num_data.get("color_vibration", 0)
    ai_master_number = num_data.get("master_number", 0)

    # If AI provides chakra_number for numerology, use it, else use the one from energy_mapping
    ai_numerology_chakra_number = num_data.get("chakra_number")
    final_numerology_chakra_number = ai_numerology_chakra_number if ai_numerology_chakra_number is not None else final_chakra_number

    # Calculate crystal_number from stone_type if not provided by AI or is 0
    calculated_crystal_number = calculate_name_numerology_number(identification.stone_type)
    final_crystal_number = ai_crystal_number if ai_crystal_number != 0 else calculated_crystal_number

    # Calculate master_number (as per UNIFIED_DATA_MODEL.md example calculation)
    # master_number = (nameValue + colorValue + chakraValue) % 9 || 9;
    # Here, nameValue is final_crystal_number, colorValue is ai_color_vibration, chakraValue is final_numerology_chakra_number

    calculated_master_number = 0
    if final_crystal_number != 0 and final_numerology_chakra_number != 0: # color_vibration can be 0
        current_sum = final_crystal_number + ai_color_vibration + final_numerology_chakra_number
        calculated_master_number = current_sum % 9
        if calculated_master_number == 0: # Handles the '|| 9' part for sums that are multiples of 9
            calculated_master_number = 9

    final_master_number = ai_master_number if ai_master_number !=0 else calculated_master_number

    # Ensure chakra_number in numerology is consistent with energy_mapping if not set by AI for numerology
    if final_numerology_chakra_number == 0 and energy_mapping.chakra_number !=0:
        final_numerology_chakra_number = energy_mapping.chakra_number


    numerology = NumerologyData(
        crystal_number=final_crystal_number,
        color_vibration=ai_color_vibration, # Potentially from a future color vibration map
        chakra_number=final_numerology_chakra_number,
        master_number=final_master_number
    )

    # Crystal Core
    crystal_core = CrystalCore(
        id=str(uuid.uuid4()),
        timestamp=datetime.utcnow().isoformat(),
        confidence_score=core_data.get("confidence_score", 0.0),
        visual_analysis=visual_analysis,
        identification=identification,
        energy_mapping=energy_mapping,
        astrological_data=astrological_data,
        numerology=numerology
    )

    # Automatic Enrichment
    ae_data = enrichment_data # alias for brevity

    # Attempt to derive mineral_class if not provided by AI and identification.crystal_family is known
    derived_mineral_class = None
    ai_mineral_class = ai_response.get("mineral_class") # Check if AI provides it directly

    if not ai_mineral_class and identification.crystal_family and identification.crystal_family != "Unknown":
        CRYSTAL_FAMILY_TO_MINERAL_CLASS = {
            "quartz": "Silicate",
            "feldspar": "Silicate",
            "beryl": "Silicate",
            "tourmaline": "Silicate",
            "garnet": "Silicate",
            "mica": "Silicate", # Common family
            "pyroxene": "Silicate", # Common family
            "amphibole": "Silicate", # Common family
            "zeolite": "Silicate", # Common family
            "corundum": "Oxide",  # (Sapphire, Ruby)
            "hematite": "Oxide", # Already a stone_type, but if family is hematite
            "magnetite": "Oxide",
            "spinel": "Oxide",
            "calcite": "Carbonate",
            "aragonite": "Carbonate",
            "malachite": "Carbonate",
            "azurite": "Carbonate",
            "siderite": "Carbonate",
            "dolomite": "Carbonate",
            "gypsum": "Sulfate",
            "barite": "Sulfate",
            "celestite": "Sulfate",
            "apatite": "Phosphate",
            "turquoise": "Phosphate",
            "pyrite": "Sulfide",
            "galena": "Sulfide",
            "sphalerite": "Sulfide",
            "halite": "Halide", # Rock Salt
            "fluorite": "Halide",
            # Native Elements like Gold, Silver, Copper, Sulfur can be tricky if family isn't specified well
        }
        derived_mineral_class = CRYSTAL_FAMILY_TO_MINERAL_CLASS.get(identification.crystal_family.lower())

    automatic_enrichment = AutomaticEnrichment(
        crystal_bible_reference=ai_response.get("crystal_bible_reference"),
        healing_properties=ai_response.get("healing_properties", []),
        usage_suggestions=ai_response.get("usage_suggestions", []),
        care_instructions=ai_response.get("care_instructions", []),
        synergy_crystals=ai_response.get("synergy_crystals", []),
        mineral_class=ai_mineral_class or derived_mineral_class # Prioritize AI, then rule
    )

    # UserIntegration will be minimal for now
    user_integration = UserIntegration()

    return UnifiedCrystalData(
        crystal_core=crystal_core,
        automatic_enrichment=automatic_enrichment,
        user_integration=user_integration
    )

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
        The goal is to populate the 'CrystalCore' and 'AutomaticEnrichment' sections of our UnifiedCrystalData model.
        
        USER CONTEXT: {json.dumps(user_context) if user_context else 'None provided'}
        
        Return ONLY valid JSON with the following structure. Populate all fields as accurately as possible.
        If a list can have multiple values, provide them. If a value is unknown, use null or an empty list as appropriate.
        You are an expert crystal identification and metaphysical guidance system.
        Analyze the provided crystal image and return a single, valid JSON object containing comprehensive information.

        USER CONTEXT: {json.dumps(user_context) if user_context else 'None provided'}

        Please provide the following details in the JSON response, using the specified or similar keys.
        If a value is unknown or not applicable, you can omit the key or use a null/empty value.
        Strive for accuracy and completeness.

        KEY INFORMATION TO INCLUDE:
        - "overall_confidence_score": Your confidence (0.0 to 1.0) in the overall identification and data provided.

        - "identification_details": {{
            "stone_name": "string (common name, e.g., Amethyst)",
            "variety": "string (e.g., Chevron Amethyst, Siberian Amethyst, optional)",
            "crystal_family": "string (e.g., Quartz, Feldspar, Beryl, optional)",
            "identification_confidence": "float (0.0 to 1.0, confidence in the stone_name itself)"
          }}

        - "visual_characteristics": {{
            "primary_color": "string",
            "secondary_colors": ["string", "string", "..."],
            "transparency": "string (e.g., Transparent, Translucent, Opaque)",
            "formation": "string (e.g., Cluster, Point, Tumbled, Geode, Raw, Massive)",
            "size_estimate": "string (e.g., Small, Medium, Large, optional)"
          }}

        - "physical_properties_summary": {{
            "hardness": "string (Mohs scale, e.g., '7', optional)",
            "crystal_system": "string (e.g., Hexagonal, Trigonal, Cubic, optional)"
          }}

        - "metaphysical_aspects": {{
            "primary_chakra": "string (e.g., Third Eye, Root Chakra)",
            "secondary_chakras": ["string", "string", "... (optional)"],
            "vibration_level": "string (e.g., High, Medium, Low, Very High, optional)",
            "primary_zodiac_signs": ["string", "string", "... (associated Zodiac signs)"],
            "planetary_rulers": ["string", "string", "... (associated planets, optional)"],
            "elements": ["string", "string", "... (associated elements, e.g., Water, Earth, optional)"]
          }}

        - "numerology_insights": {{ // Your best estimate for numerological values, if possible
            "crystal_number_association": "integer (optional)",
            "color_vibration_number": "integer (optional)",
            "chakra_number_for_numerology": "integer (optional, e.g., 6 for Third Eye)",
            "master_numerology_number_suggestion": "integer (optional)"
          }}

        - "enrichment_details": {{
            "healing_properties": ["string", "string", "... (key healing benefits)"],
            "usage_suggestions": ["string", "string", "... (how to use the crystal)"],
            "care_instructions": ["string (cleansing methods)", "string (charging methods)", "string (storage advice)"],
            "synergy_crystals": ["string (compatible crystal names)", "string", "... (optional)"],
            "crystal_bible_reference": "string (e.g., 'The Crystal Bible, page 123', optional)",
            "mineral_class": "string (e.g., Silicate, Oxide, Carbonate, optional)"
          }}

        Ensure the entire output is a single valid JSON object.
        Example for a key: "stone_name": "Amethyst"
        Example for a list: "healing_properties": ["Promotes calmness", "Enhances intuition"]
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
                # Remove markdown ```json and ``` if present
                if content.startswith("```json") and content.endswith("```"):
                    content = content[7:-3].strip()
                elif content.startswith("```") and content.endswith("```"): # More generic markdown block
                    content = content[3:-3].strip()

                logger.debug(f"Cleaned AI Response: {content}")
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

@app.post("/api/crystal/identify", response_model=UnifiedCrystalData)
async def identify_crystal(request: CrystalIdentificationRequest):
    """Identify crystal from image using AI and return UnifiedCrystalData"""
    try:
        logger.info(f"Crystal identification request received for UnifiedCrystalData response.")
        
        ai_json_response: Dict
        # source_ai: str # Potentially useful if we want to store which AI gave the response

        if GEMINI_API_KEY:
            ai_json_response = await AIService.identify_crystal_with_gemini(
                request.image_data, 
                request.user_context
            )
            # source_ai = "gemini-pro-vision"
        elif OPENAI_API_KEY:
            # Assuming identify_crystal_with_openai is updated or will be to return a similar structure
            ai_json_response = await AIService.identify_crystal_with_openai(
                request.image_data, 
                request.user_context
            )
            # source_ai = "gpt-4-vision"
        else:
            raise HTTPException(status_code=503, detail="No AI services configured for identification.")

        # Map the raw AI JSON response to our UnifiedCrystalData model
        unified_data = map_ai_response_to_unified_data(ai_json_response)

        # Optionally, could log the source_ai or add it to a non-persistent part of the response if needed
        # For now, the UnifiedCrystalData model doesn't have a field for AI source.

        return unified_data
        
    except Exception as e:
        logger.error(f"Crystal identification error (UnifiedCrystalData): {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/crystal/collection", response_model=List[UnifiedCrystalData])
async def get_crystal_collection():
    """Get user's crystal collection"""
    # This now lists all crystals from Firestore, using the new UnifiedCrystalData model
    return await list_crystals()

# @app.post("/api/crystal/save")
# async def save_crystal(entry: CollectionEntry):
#     """Save crystal to user's collection"""
#     # This endpoint is temporarily commented out due to incompatibility with UnifiedCrystalData.
#     # It previously expected CollectionEntry and called create_crystal, which now expects UnifiedCrystalData.
#     # Needs refactoring or a dedicated adapter if it's to be kept.
#     logger.info(f"Saving crystal via /api/crystal/save: {entry.crystal_name}")
#     # created_crystal = await create_crystal(entry) # This line is now incompatible
#     return {
#         "status": "error",
#         "message": "Endpoint temporarily disabled",
#         "crystal_id": entry.id,
#         "saved_at": datetime.utcnow().isoformat()
#     }

# Firestore CRUD for Crystals
@app.post("/api/crystals", response_model=UnifiedCrystalData)
async def create_crystal(crystal_data: UnifiedCrystalData):
    if not crystals_collection:
        raise HTTPException(status_code=503, detail="Firestore not available")

    # --- User ID Validation Placeholder ---
    # When full authentication is implemented:
    # 1. Extract authenticated_user_id from the request's auth token (e.g., provided by a dependency).
    # 2. Compare with crystal_data.user_integration.user_id.
    # Example:
    # if authenticated_user_id != crystal_data.user_integration.user_id:
    #     raise HTTPException(status_code=403, detail="User ID in token does not match user_id in request body.")
    # --- End Placeholder ---

    if not crystal_data.user_integration or not crystal_data.user_integration.user_id:
        raise HTTPException(status_code=422, detail="UserIntegration with a valid user_id is required to save a crystal to a collection.")

    try:
        # Use crystal_core.id as the document ID in Firestore
        doc_ref = crystals_collection.document(crystal_data.crystal_core.id)
        await asyncio.to_thread(doc_ref.set, crystal_data.model_dump())
        return crystal_data
    except Exception as e:
        logger.error(f"Error creating crystal: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create crystal: {str(e)}")

@app.get("/api/crystals/{crystal_id}", response_model=UnifiedCrystalData)
async def read_crystal(crystal_id: str):
    if not crystals_collection:
        raise HTTPException(status_code=503, detail="Firestore not available")
    try:
        doc_ref = crystals_collection.document(crystal_id)
        doc = await asyncio.to_thread(doc_ref.get)
        if doc.exists:
            return UnifiedCrystalData(**doc.to_dict())
        else:
            raise HTTPException(status_code=404, detail="Crystal not found")
    except HTTPException as e: # Re-raise HTTPException
        raise e
    except Exception as e:
        logger.error(f"Error reading crystal {crystal_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to read crystal: {str(e)}")

@app.get("/api/crystals", response_model=List[UnifiedCrystalData])
async def list_crystals():
    if not crystals_collection:
        raise HTTPException(status_code=503, detail="Firestore not available")
    try:
        crystals_list = []
        docs = await asyncio.to_thread(crystals_collection.stream)
        for doc in docs:
            crystals_list.append(UnifiedCrystalData(**doc.to_dict()))
        return crystals_list
    except Exception as e:
        logger.error(f"Error listing crystals: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list crystals: {str(e)}")

@app.put("/api/crystals/{crystal_id}", response_model=UnifiedCrystalData)
async def update_crystal(crystal_id: str, crystal_update: UnifiedCrystalData):
    if not crystals_collection:
        raise HTTPException(status_code=503, detail="Firestore not available")
    try:
        doc_ref = crystals_collection.document(crystal_id)
        # Ensure the ID in the path matches the ID in the body's crystal_core
        if crystal_id != crystal_update.crystal_core.id:
            raise HTTPException(status_code=400, detail="Crystal ID mismatch in path and body's crystal_core.id")

        # Check if document exists before updating
        # No need to fetch the doc just to check existence if we're overwriting with set()
        # However, it's good practice to ensure you're not accidentally creating a new doc with PUT
        # For this implementation, doc_ref.set() will create or overwrite.
        # If strict update (only if exists) is needed, a get() then update() or a transaction would be better.
        # Let's keep the existing check for safety.
        doc_check = await asyncio.to_thread(doc_ref.get)
        if not doc_check.exists:
            raise HTTPException(status_code=404, detail="Crystal not found for update")

        await asyncio.to_thread(doc_ref.set, crystal_update.model_dump())
        return crystal_update
    except HTTPException as e: # Re-raise HTTPException
        raise e
    except Exception as e:
        logger.error(f"Error updating crystal {crystal_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update crystal: {str(e)}")

@app.delete("/api/crystals/{crystal_id}", response_model=Dict[str, str])
async def delete_crystal(crystal_id: str):
    if not crystals_collection:
        raise HTTPException(status_code=503, detail="Firestore not available")
    try:
        doc_ref = crystals_collection.document(crystal_id)

        # Check if document exists before deleting
        doc = await asyncio.to_thread(doc_ref.get)
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Crystal not found for deletion")

        await asyncio.to_thread(doc_ref.delete)
        return {"status": "success", "message": f"Crystal {crystal_id} deleted successfully"}
    except HTTPException as e: # Re-raise HTTPException
        raise e
    except Exception as e:
        logger.error(f"Error deleting crystal {crystal_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete crystal: {str(e)}")

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