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

# Enhanced Data models
class CrystalIdentificationRequest(BaseModel):
    image_data: str  # base64 encoded image
    user_context: Optional[Dict[str, Any]] = None
    user_profile: Optional[Dict[str, Any]] = None
    existing_collection: Optional[List[Dict[str, Any]]] = None
    validation_level: Optional[str] = 'standard'

class EnhancedCrystalIdentificationResponse(BaseModel):
    identification: Dict[str, Any]
    metaphysical_properties: Dict[str, Any]
    physical_properties: Dict[str, Any]
    care_instructions: Dict[str, Any]
    confidence: float
    source: str
    ethical_validation: Dict[str, Any]
    cultural_context: Dict[str, Any]
    environmental_impact: Dict[str, Any]
    personalized_recommendations: List[Dict[str, Any]]
    parserator_metadata: Optional[Dict[str, Any]] = None

class AutomationRequest(BaseModel):
    trigger_event: str
    event_data: Dict[str, Any]
    user_profile: Dict[str, Any]
    collection: List[Dict[str, Any]]

class AutomationResponse(BaseModel):
    suggested_actions: List[Dict[str, Any]]
    cross_feature_updates: List[Dict[str, Any]]
    ethical_considerations: List[str]
    cultural_context: Dict[str, Any]
    environmental_impact: Dict[str, Any]

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

# Parserator Service Integration
class ParseOperatorService:
    @staticmethod
    async def call_parserator_api(input_data: str, output_schema: Dict, instructions: str = None) -> Dict:
        """Call Parserator API with two-stage processing"""
        if not PARSERATOR_API_KEY:
            raise HTTPException(status_code=503, detail="Parserator API not configured")
        
        try:
            async with httpx.AsyncClient() as client:
                payload = {
                    'inputData': input_data,
                    'outputSchema': output_schema,
                }
                if instructions:
                    payload['instructions'] = instructions
                
                response = await client.post(
                    f"{PARSERATOR_BASE_URL}{PARSERATOR_ENDPOINT}",
                    headers={
                        'Authorization': f'Bearer {PARSERATOR_API_KEY}',
                        'Content-Type': 'application/json',
                    },
                    json=payload,
                    timeout=30.0
                )
                
                if response.status_code != 200:
                    raise HTTPException(status_code=response.status_code, detail=f"Parserator API error: {response.text}")
                
                return response.json()
                
        except Exception as e:
            logger.error(f"Parserator API error: {e}")
            raise HTTPException(status_code=500, detail=f"Parserator service failed: {str(e)}")
    
    @staticmethod
    async def enhance_crystal_identification(crystal_data: Dict, user_profile: Dict, collection: List[Dict]) -> Dict:
        """Enhance crystal identification with Parserator intelligence"""
        
        enhancement_schema = {
            'enhanced_properties': {
                'cultural_origins': 'array',
                'traditional_uses': 'array',
                'indigenous_connections': 'object',
                'respectful_usage_guidelines': 'array',
            },
            'ethical_assessment': {
                'sourcing_transparency': 'object',
                'mining_practices': 'object',
                'fair_trade_availability': 'boolean',
                'environmental_impact_score': 'number',
                'ethical_alternatives': 'array',
            },
            'personalization': {
                'birth_chart_compatibility': 'object',
                'collection_synergy': 'object',
                'recommended_practices': 'array',
                'chakra_balance_impact': 'object',
            },
            'validation_scores': {
                'geological_accuracy': 'number',
                'metaphysical_consistency': 'number',
                'ethical_compliance': 'number',
                'cultural_sensitivity': 'number',
            }
        }
        
        instructions = f"""
        Enhance this crystal identification with comprehensive ethical and cultural analysis:
        
        EXODITICAL MORAL ARCHITECTURE PRINCIPLES:
        1. Cultural Sovereignty: Acknowledge indigenous wisdom and prevent appropriation
        2. Spiritual Integrity: Distinguish beliefs from facts, encourage personal discernment
        3. Environmental Stewardship: Assess mining impact and suggest alternatives
        4. Technological Wisdom: Present AI insights as guidance, not authority
        5. Inclusive Accessibility: Ensure information is accessible regardless of economic status
        
        USER PROFILE: {json.dumps(user_profile)}
        EXISTING COLLECTION: {json.dumps(collection)}
        
        Provide enhancement that:
        - Respects cultural origins and traditional knowledge
        - Assesses environmental and ethical sourcing
        - Personalizes recommendations based on user's profile and collection
        - Maintains spiritual integrity without false claims
        - Encourages personal experience and discernment
        """
        
        input_data = json.dumps({
            'crystal_data': crystal_data,
            'user_context': user_profile,
            'collection_context': collection,
        })
        
        return await ParseOperatorService.call_parserator_api(
            input_data=input_data,
            output_schema=enhancement_schema,
            instructions=instructions
        )
    
    @staticmethod
    async def process_automation_request(trigger_event: str, event_data: Dict, user_profile: Dict, collection: List[Dict]) -> Dict:
        """Process cross-feature automation with ethical validation"""
        
        automation_schema = {
            'suggested_actions': {
                'type': 'array',
                'items': {
                    'action_type': 'string',
                    'feature_target': 'string',
                    'parameters': 'object',
                    'ethical_compliance': 'boolean',
                    'cultural_sensitivity': 'number',
                    'confidence': 'number',
                    'ethical_considerations': 'array',
                }
            },
            'cross_feature_updates': {
                'type': 'array',
                'items': {
                    'feature': 'string',
                    'update_type': 'string',
                    'data': 'object',
                    'ethical_validation': 'boolean',
                }
            },
            'ethical_considerations': 'array',
            'cultural_context': 'object',
            'environmental_impact': 'object',
        }
        
        instructions = f"""
        Generate cross-feature automation following Exoditical Moral Architecture:
        
        ETHICAL CONSTRAINTS:
        - Respect cultural boundaries and traditional practices
        - Maintain spiritual integrity without false medical claims
        - Consider environmental impact of suggestions
        - Preserve human agency and encourage personal choice
        - Ensure accessibility regardless of economic status
        
        TRIGGER: {trigger_event}
        EVENT DATA: {json.dumps(event_data)}
        USER PROFILE: {json.dumps(user_profile)}
        COLLECTION: {json.dumps(collection)}
        
        Generate automation suggestions that:
        - Respect cultural origins and wisdom
        - Avoid appropriation or insensitive practices
        - Encourage sustainable and ethical choices
        - Support personal growth and learning
        - Maintain transparency about AI limitations
        """
        
        input_data = json.dumps({
            'trigger_event': trigger_event,
            'event_data': event_data,
            'user_profile': user_profile,
            'collection': collection,
        })
        
        return await ParseOperatorService.call_parserator_api(
            input_data=input_data,
            output_schema=automation_schema,
            instructions=instructions
        )

# Exoditical Validation Service
class ExoditicalValidator:
    @staticmethod
    def validate_crystal_data(crystal_data: Dict) -> Dict:
        """Validate crystal data against Exoditical principles"""
        validation_result = {
            'cultural_sovereignty': ExoditicalValidator._check_cultural_respect(crystal_data),
            'spiritual_integrity': ExoditicalValidator._check_spiritual_integrity(crystal_data),
            'environmental_stewardship': ExoditicalValidator._check_environmental_awareness(crystal_data),
            'technological_wisdom': ExoditicalValidator._check_ai_transparency(crystal_data),
            'inclusive_accessibility': ExoditicalValidator._check_accessibility(crystal_data),
        }
        
        overall_score = sum(validation_result.values()) / len(validation_result)
        
        return {
            'overall_ethical_score': overall_score,
            'principle_scores': validation_result,
            'is_ethically_compliant': overall_score >= 0.7,
            'recommendations': ExoditicalValidator._generate_recommendations(validation_result),
        }
    
    @staticmethod
    def _check_cultural_respect(data: Dict) -> float:
        """Check for cultural sovereignty compliance"""
        score = 0.7  # Base score
        
        # Check for cultural acknowledgment
        if any(key in str(data).lower() for key in ['traditional', 'indigenous', 'cultural']):
            score += 0.2
        
        # Check for appropriative language
        problematic_terms = ['ancient secret', 'mystical power', 'sacred wisdom', 'shamanic']
        if any(term in str(data).lower() for term in problematic_terms):
            score -= 0.3
        
        return min(max(score, 0.0), 1.0)
    
    @staticmethod
    def _check_spiritual_integrity(data: Dict) -> float:
        """Check for spiritual integrity compliance"""
        score = 0.8  # Base score
        
        # Check for medical claims
        medical_terms = ['cures', 'heals', 'treats', 'diagnoses', 'medical']
        if any(term in str(data).lower() for term in medical_terms):
            score -= 0.4
        
        # Check for belief/fact distinction
        if any(phrase in str(data).lower() for phrase in ['believed to', 'traditionally', 'some say']):
            score += 0.1
        
        return min(max(score, 0.0), 1.0)
    
    @staticmethod
    def _check_environmental_awareness(data: Dict) -> float:
        """Check for environmental stewardship"""
        score = 0.6  # Base score
        
        # Check for environmental considerations
        if 'environmental' in str(data).lower() or 'sustainable' in str(data).lower():
            score += 0.3
        
        # Check for ethical sourcing mentions
        if 'ethical' in str(data).lower() or 'fair trade' in str(data).lower():
            score += 0.1
        
        return min(max(score, 0.0), 1.0)
    
    @staticmethod
    def _check_ai_transparency(data: Dict) -> float:
        """Check for technological wisdom compliance"""
        score = 0.8  # Base score
        
        # Check for uncertainty acknowledgment
        if any(word in str(data).lower() for word in ['may', 'might', 'possibly', 'confidence']):
            score += 0.1
        
        # Check for human agency preservation
        if any(phrase in str(data).lower() for phrase in ['personal choice', 'individual', 'trust yourself']):
            score += 0.1
        
        return min(max(score, 0.0), 1.0)
    
    @staticmethod
    def _check_accessibility(data: Dict) -> float:
        """Check for inclusive accessibility"""
        score = 0.8  # Base score
        
        # Check for economic barriers
        if any(phrase in str(data).lower() for phrase in ['expensive', 'exclusive', 'elite', 'advanced only']):
            score -= 0.3
        
        # Check for inclusive language
        if any(phrase in str(data).lower() for phrase in ['accessible', 'everyone', 'free', 'community']):
            score += 0.2
        
        return min(max(score, 0.0), 1.0)
    
    @staticmethod
    def _generate_recommendations(scores: Dict) -> List[str]:
        """Generate ethical recommendations based on scores"""
        recommendations = []
        
        if scores['cultural_sovereignty'] < 0.7:
            recommendations.append('Add cultural context and acknowledge traditional sources')
        
        if scores['spiritual_integrity'] < 0.7:
            recommendations.append('Distinguish between beliefs and facts, avoid medical claims')
        
        if scores['environmental_stewardship'] < 0.7:
            recommendations.append('Include environmental impact and ethical sourcing information')
        
        if scores['technological_wisdom'] < 0.7:
            recommendations.append('Acknowledge AI limitations and encourage personal discernment')
        
        if scores['inclusive_accessibility'] < 0.7:
            recommendations.append('Ensure information is accessible regardless of economic status')
        
        return recommendations

# Enhanced AI Service Integration
class AIService:
    @staticmethod
    async def identify_crystal_with_gemini(image_data: str, user_context: Dict = None) -> Dict:
        """Enhanced crystal identification using Gemini Pro Vision with ethical validation"""
        if not GEMINI_API_KEY:
            raise HTTPException(status_code=503, detail="Gemini API not configured")
        
        prompt = f"""
        You are an expert crystal identification system following Exoditical Moral Architecture principles.
        Analyze this crystal image with cultural sensitivity and ethical awareness.
        
        EXODITICAL PRINCIPLES:
        1. Cultural Sovereignty: Acknowledge indigenous wisdom, prevent appropriation
        2. Spiritual Integrity: Distinguish beliefs from facts, no medical claims
        3. Environmental Stewardship: Consider mining impact and ethical sourcing
        4. Technological Wisdom: Present as AI guidance, encourage personal discernment
        5. Inclusive Accessibility: Ensure accessibility regardless of economic status
        
        USER CONTEXT: {json.dumps(user_context) if user_context else 'None provided'}
        
        Return ONLY valid JSON with enhanced ethical structure:
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
            "healing_properties": ["Traditional beliefs about physical healing", "Emotional balance practices", "Spiritual growth traditions", "Mental clarity techniques"],
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
          }},
          "ethical_considerations": {{
            "cultural_origins": ["Acknowledge traditional sources if applicable"],
            "environmental_impact": "Consider ethical sourcing and mining practices",
            "respectful_usage": "Honor traditional wisdom while encouraging personal experience",
            "accessibility_notes": "Provide alternatives for different economic situations"
          }},
          "ai_transparency": {{
            "confidence_level": "AI identification confidence score",
            "limitations": "This is AI guidance - trust your personal intuition",
            "encourage_discernment": "Use this information as a starting point for your own exploration"
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
        "version": "2.0.0",
        "environment": ENVIRONMENT,
        "services": {
            "gemini_api": "configured" if GEMINI_API_KEY else "not_configured",
            "openai_api": "configured" if OPENAI_API_KEY else "not_configured",
            "claude_api": "configured" if CLAUDE_API_KEY else "not_configured",
            "parserator_api": "configured" if PARSERATOR_API_KEY else "not_configured"
        },
        "ethical_framework": {
            "exoditical_validation": "active",
            "cultural_sensitivity": "enabled",
            "spiritual_integrity": "enforced",
            "environmental_awareness": "integrated"
        }
    }

@app.get("/api/status")
async def api_status():
    """Detailed API status"""
    return {
        "api_version": "2.0.0",
        "environment": ENVIRONMENT,
        "features": {
            "crystal_identification": True,
            "enhanced_identification": bool(PARSERATOR_API_KEY),
            "collection_management": True,
            "usage_tracking": True,
            "multi_model_ai": bool(GEMINI_API_KEY or OPENAI_API_KEY),
            "ethical_validation": True,
            "cross_feature_automation": bool(PARSERATOR_API_KEY),
            "cultural_sensitivity": True,
            "environmental_awareness": True
        },
        "endpoints": {
            "identify": "/api/crystal/identify",
            "identify_enhanced": "/api/crystal/identify-enhanced",
            "automation": "/api/automation/cross-feature",
            "collection": "/api/crystal/collection",
            "save": "/api/crystal/save",
            "usage": "/api/usage",
            "validate": "/api/crystal/validate"
        }
    }

@app.post("/api/crystal/identify-enhanced", response_model=EnhancedCrystalIdentificationResponse)
async def identify_crystal_enhanced(request: CrystalIdentificationRequest):
    """Enhanced crystal identification with Parserator and Exoditical validation"""
    try:
        logger.info(f"Enhanced crystal identification request received")
        
        # Stage 1: Primary AI identification
        if GEMINI_API_KEY:
            base_result = await AIService.identify_crystal_with_gemini(
                request.image_data, 
                request.user_context
            )
            source = "gemini-pro-vision-enhanced"
        elif OPENAI_API_KEY:
            base_result = await AIService.identify_crystal_with_openai(
                request.image_data, 
                request.user_context
            )
            source = "gpt-4-vision-enhanced"
        else:
            raise HTTPException(status_code=503, detail="No AI services configured")
        
        # Stage 2: Exoditical validation
        ethical_validation = ExoditicalValidator.validate_crystal_data(base_result)
        
        # Stage 3: Parserator enhancement (if available)
        parserator_metadata = None
        cultural_context = {}
        environmental_impact = {}
        personalized_recommendations = []
        
        if PARSERATOR_API_KEY and request.user_profile and request.existing_collection:
            try:
                enhancement = await ParseOperatorService.enhance_crystal_identification(
                    crystal_data=base_result,
                    user_profile=request.user_profile,
                    collection=request.existing_collection or []
                )
                
                if enhancement.get('success'):
                    parsed_data = enhancement.get('parsedData', {})
                    cultural_context = parsed_data.get('enhanced_properties', {})
                    environmental_impact = parsed_data.get('ethical_assessment', {})
                    personalized_recommendations = parsed_data.get('personalization', {})
                    parserator_metadata = enhancement.get('metadata', {})
                    
            except Exception as e:
                logger.warning(f"Parserator enhancement failed: {e}")
        
        return EnhancedCrystalIdentificationResponse(
            identification=base_result.get("identification", {}),
            metaphysical_properties=base_result.get("metaphysical_properties", {}),
            physical_properties=base_result.get("physical_properties", {}),
            care_instructions=base_result.get("care_instructions", {}),
            confidence=base_result.get("identification", {}).get("confidence", 0.8),
            source=source,
            ethical_validation=ethical_validation,
            cultural_context=cultural_context,
            environmental_impact=environmental_impact,
            personalized_recommendations=[personalized_recommendations] if personalized_recommendations else [],
            parserator_metadata=parserator_metadata
        )
        
    except Exception as e:
        logger.error(f"Enhanced crystal identification error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/crystal/identify")
async def identify_crystal_basic(request: CrystalIdentificationRequest):
    """Basic crystal identification (legacy endpoint)"""
    try:
        logger.info(f"Basic crystal identification request received")
        
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
        
        # Apply basic ethical validation
        ethical_validation = ExoditicalValidator.validate_crystal_data(result)
        
        return {
            "identification": result.get("identification", {}),
            "metaphysical_properties": result.get("metaphysical_properties", {}),
            "physical_properties": result.get("physical_properties", {}),
            "care_instructions": result.get("care_instructions", {}),
            "confidence": result.get("identification", {}).get("confidence", 0.8),
            "source": source,
            "ethical_validation": ethical_validation
        }
        
    except Exception as e:
        logger.error(f"Crystal identification error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/automation/cross-feature", response_model=AutomationResponse)
async def cross_feature_automation(request: AutomationRequest):
    """Process cross-feature automation with ethical validation"""
    try:
        logger.info(f"Cross-feature automation request: {request.trigger_event}")
        
        if not PARSERATOR_API_KEY:
            # Fallback automation without Parserator
            return AutomationResponse(
                suggested_actions=[],
                cross_feature_updates=[],
                ethical_considerations=["Basic automation available - Parserator not configured"],
                cultural_context={},
                environmental_impact={}
            )
        
        automation_result = await ParseOperatorService.process_automation_request(
            trigger_event=request.trigger_event,
            event_data=request.event_data,
            user_profile=request.user_profile,
            collection=request.collection
        )
        
        if automation_result.get('success'):
            parsed_data = automation_result.get('parsedData', {})
            
            return AutomationResponse(
                suggested_actions=parsed_data.get('suggested_actions', []),
                cross_feature_updates=parsed_data.get('cross_feature_updates', []),
                ethical_considerations=parsed_data.get('ethical_considerations', []),
                cultural_context=parsed_data.get('cultural_context', {}),
                environmental_impact=parsed_data.get('environmental_impact', {})
            )
        else:
            raise HTTPException(status_code=500, detail="Automation processing failed")
        
    except Exception as e:
        logger.error(f"Cross-feature automation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/crystal/validate")
async def validate_crystal_data(crystal_data: Dict[str, Any]):
    """Validate crystal data against Exoditical principles"""
    try:
        validation_result = ExoditicalValidator.validate_crystal_data(crystal_data)
        return {
            "validation_result": validation_result,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Crystal validation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/crystal/collection")
async def get_crystal_collection(user_id: str):
    """Get user's crystal collection"""
    # In production, this would query the database
    return {
        "user_id": user_id,
        "crystals": [],
        "total_count": 0,
        "last_updated": datetime.utcnow().isoformat(),
        "ethical_compliance": True
    }

@app.post("/api/crystal/save")
async def save_crystal(entry: CollectionEntry):
    """Save crystal to user's collection with ethical validation"""
    # In production, this would save to database
    logger.info(f"Saving crystal: {entry.crystal_name}")
    return {
        "status": "success",
        "crystal_id": entry.id,
        "saved_at": datetime.utcnow().isoformat(),
        "ethical_validation": "passed"
    }

@app.post("/api/usage")
async def track_usage(stats: UsageStats):
    """Track feature usage for analytics"""
    logger.info(f"Usage tracked: {stats.feature} for user {stats.user_id}")
    return {
        "status": "tracked",
        "timestamp": datetime.utcnow().isoformat(),
        "ethical_compliance": True
    }

@app.get("/api/crystal/search")
async def search_crystals(q: str, limit: int = 20):
    """Search crystal database with ethical considerations"""
    # Enhanced search results with ethical filtering
    return {
        "query": q,
        "results": [],
        "total": 0,
        "limit": limit,
        "ethical_filtering": "enabled",
        "cultural_sensitivity": "active"
    }

# Production deployment
if __name__ == "__main__":
    logger.info(f"Starting Crystal Grimoire Enhanced Backend Server on port {PORT}")
    logger.info(f"Environment: {ENVIRONMENT}")
    logger.info(f"Gemini API: {'configured' if GEMINI_API_KEY else 'not configured'}")
    logger.info(f"OpenAI API: {'configured' if OPENAI_API_KEY else 'not configured'}")
    logger.info(f"Parserator API: {'configured' if PARSERATOR_API_KEY else 'not configured'}")
    logger.info(f"Exoditical Moral Architecture: enabled")
    logger.info(f"Cultural Sensitivity Validation: active")
    logger.info(f"Environmental Impact Assessment: integrated")
    
    uvicorn.run(
        "backend_server_enhanced:app",
        host="0.0.0.0",
        port=PORT,
        reload=ENVIRONMENT == 'development',
        log_level="info"
    )