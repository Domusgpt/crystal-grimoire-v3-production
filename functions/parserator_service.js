/**
 * Parserator Service - Firebase Functions Integration
 * 
 * Integrates with Paul's existing Parserator API at:
 * https://app-5108296280.us-central1.run.app
 * 
 * Features:
 * - Two-stage Architect-Extractor pattern
 * - 70% cost reduction vs single-LLM approaches  
 * - Multi-source validation
 * - Real-time enhancement
 */

const axios = require('axios');
const functions = require('firebase-functions');

class ParseOperatorService {
  constructor() {
    this.baseUrl = 'https://app-5108296280.us-central1.run.app';
    this.parseEndpoint = '/v1/parse';
    this.healthEndpoint = '/health';
    this.apiKey = functions.config().parserator?.api_key || null; // Optional API key
  }

  /**
   * Check Parserator API health
   */
  async checkHealth() {
    try {
      const response = await axios.get(`${this.baseUrl}${this.healthEndpoint}`);
      return response.data;
    } catch (error) {
      console.error('Parserator health check failed:', error.message);
      return {
        status: 'error',
        error: error.message,
      };
    }
  }

  /**
   * Enhanced crystal data processing using Parserator
   */
  async enhanceCrystalData(crystalData, userProfile = {}, collection = []) {
    try {
      const description = this._buildCrystalDescription(crystalData, userProfile, collection);
      
      const schema = {
        'name': 'string',
        'scientific_name': 'string',
        'color': 'string',
        'crystal_system': 'string',
        'hardness': 'string',
        'primary_chakras': 'string_array',
        'secondary_chakras': 'string_array',
        'zodiac_signs': 'string_array',
        'planetary_rulers': 'string_array',
        'elements': 'string_array',
        'healing_properties': 'string_array',
        'metaphysical_uses': 'string_array',
        'emotional_benefits': 'string_array',
        'spiritual_purposes': 'string_array',
        'care_instructions': 'string_array',
        'formation': 'string',
        'origin_locations': 'string_array',
        'confidence_score': 'number',
        'personalized_guidance': 'string',
      };

      const result = await this._callParserator(
        description,
        schema,
        'Extract comprehensive crystal data with personalized guidance based on user profile and existing collection.'
      );

      if (result.success) {
        return this._mergeWithOriginalData(crystalData, result.parsedData, result.metadata);
      } else {
        console.warn('Parserator enhancement failed:', result.error);
        return crystalData; // Graceful fallback
      }
    } catch (error) {
      console.error('Crystal enhancement error:', error);
      return crystalData; // Graceful fallback
    }
  }

  /**
   * Get personalized recommendations using Parserator
   */
  async getPersonalizedRecommendations(userProfile, collection = []) {
    try {
      const profileDescription = this._buildUserProfileDescription(userProfile, collection);
      
      const schema = {
        'crystal_recommendations': 'json_object',
        'healing_suggestions': 'string_array',
        'ritual_recommendations': 'string_array',
        'journal_prompts': 'string_array',
        'reasoning': 'string',
        'confidence': 'number',
      };

      const result = await this._callParserator(
        profileDescription,
        schema,
        'Generate personalized crystal recommendations based on user profile, birth chart, and existing collection. Include healing suggestions, ritual recommendations, and journal prompts.'
      );

      if (result.success) {
        return this._formatRecommendations(result.parsedData);
      } else {
        return [];
      }
    } catch (error) {
      console.error('Recommendations error:', error);
      return [];
    }
  }

  /**
   * Process cross-feature automation using Parserator
   */
  async processCrossFeatureAutomation(triggerEvent, eventData, userProfile = {}, context = {}) {
    try {
      const automationDescription = this._buildAutomationDescription(
        triggerEvent, eventData, userProfile, context
      );
      
      const schema = {
        'healing_session_suggestions': 'json_object',
        'ritual_recommendations': 'json_object', 
        'journal_prompts': 'string_array',
        'crystal_combinations': 'json_object',
        'moon_phase_activities': 'json_object',
        'meditation_guidance': 'string',
        'automation_actions': 'json_object',
        'confidence': 'number',
        'reasoning': 'string',
      };

      const result = await this._callParserator(
        automationDescription,
        schema,
        'Analyze the trigger event and generate intelligent automation suggestions for Crystal Grimoire features (healing, rituals, journal, collection, meditation).'
      );

      if (result.success) {
        return this._buildAutomationResult(result.parsedData);
      } else {
        return this._emptyAutomationResult();
      }
    } catch (error) {
      console.error('Automation processing error:', error);
      return this._emptyAutomationResult();
    }
  }

  /**
   * Validate crystal data against multiple sources
   */
  async validateCrystalData(crystalData, validationSources = ['geological', 'metaphysical', 'cultural']) {
    try {
      const validationDescription = `
        Crystal Data for Validation:
        ${JSON.stringify(crystalData, null, 2)}
        
        Validation Sources: ${validationSources.join(', ')}
        
        Please validate this crystal data for:
        - Geological accuracy (mineral composition, hardness, crystal system)
        - Metaphysical properties authenticity
        - Cultural sensitivity and appropriation concerns
        - Environmental impact and ethical sourcing
      `;

      const schema = {
        'geological_accuracy': 'number',
        'metaphysical_authenticity': 'number',
        'cultural_sensitivity': 'number',
        'environmental_impact': 'number',
        'overall_score': 'number',
        'validation_notes': 'string_array',
        'recommendations': 'string_array',
        'concerns': 'string_array',
      };

      const result = await this._callParserator(
        validationDescription,
        schema,
        'Validate crystal data across geological, metaphysical, cultural, and environmental dimensions. Provide scores (0-1) and detailed notes.'
      );

      if (result.success) {
        return result.parsedData;
      } else {
        return {
          overall_score: 0.5,
          validation_notes: ['Unable to validate - Parserator service unavailable'],
        };
      }
    } catch (error) {
      console.error('Validation error:', error);
      return {
        overall_score: 0.5,
        validation_notes: ['Validation failed - service error'],
      };
    }
  }

  /**
   * Core Parserator API call
   */
  async _callParserator(inputData, outputSchema, instructions = null) {
    try {
      const headers = {
        'Content-Type': 'application/json',
      };
      
      // Add API key if available
      if (this.apiKey) {
        headers['Authorization'] = `Bearer ${this.apiKey}`;
      }

      const body = {
        inputData,
        outputSchema,
      };
      
      if (instructions) {
        body.instructions = instructions;
      }

      console.log('🔄 Calling Parserator API...');
      console.log('📊 Schema fields:', Object.keys(outputSchema).join(', '));

      const response = await axios.post(
        `${this.baseUrl}${this.parseEndpoint}`,
        body,
        { headers, timeout: 30000 } // 30 second timeout
      );

      console.log('📈 Parserator response status:', response.status);

      if (response.status === 200) {
        console.log('✅ Parserator success:', response.data.metadata?.confidence || 'unknown confidence');
        return response.data;
      } else {
        console.error('❌ Parserator error:', response.status, response.data);
        return {
          success: false,
          error: `HTTP ${response.status}: ${JSON.stringify(response.data)}`,
        };
      }
    } catch (error) {
      console.error('🚨 Parserator call exception:', error.message);
      return {
        success: false,
        error: `Exception: ${error.message}`,
      };
    }
  }

  // Helper methods for building descriptions and processing results

  _buildCrystalDescription(crystalData, userProfile, collection) {
    let description = 'Crystal Information:\n';
    
    // Crystal basic info
    if (crystalData.name) description += `Name: ${crystalData.name}\n`;
    if (crystalData.color) description += `Color: ${crystalData.color}\n`;
    if (crystalData.description) description += `Description: ${crystalData.description}\n`;
    if (crystalData.properties) description += `Properties: ${JSON.stringify(crystalData.properties)}\n`;
    
    // User profile context
    description += '\nUser Profile:\n';
    if (userProfile.birthDate) description += `Birth Date: ${userProfile.birthDate}\n`;
    if (userProfile.sunSign) description += `Sun Sign: ${userProfile.sunSign}\n`;
    if (userProfile.moonSign) description += `Moon Sign: ${userProfile.moonSign}\n`;
    if (userProfile.spiritualGoals) description += `Spiritual Goals: ${userProfile.spiritualGoals}\n`;
    
    // Collection context
    description += `\nExisting Collection (${collection.length} crystals):\n`;
    collection.slice(0, 5).forEach(crystal => {
      if (crystal.name) description += `- ${crystal.name}\n`;
    });
    if (collection.length > 5) {
      description += `... and ${collection.length - 5} more crystals\n`;
    }
    
    return description;
  }

  _buildUserProfileDescription(userProfile, collection) {
    let description = 'User Profile for Crystal Recommendations:\n';
    description += `Birth Date: ${userProfile.birthDate || 'Not provided'}\n`;
    description += `Sun Sign: ${userProfile.sunSign || 'Unknown'}\n`;
    description += `Moon Sign: ${userProfile.moonSign || 'Unknown'}\n`;
    description += `Ascendant: ${userProfile.ascendant || 'Unknown'}\n`;
    description += `Spiritual Goals: ${userProfile.spiritualGoals || 'General spiritual growth'}\n`;
    description += `Experience Level: ${userProfile.experienceLevel || 'Beginner'}\n`;
    
    description += `\nCurrent Collection (${collection.length} crystals):\n`;
    const crystalNames = collection
      .filter(c => c.name && c.name !== 'Unknown')
      .map(c => c.name)
      .join(', ');
    description += crystalNames || 'No crystals yet';
    
    return description;
  }

  _buildAutomationDescription(triggerEvent, eventData, userProfile, context) {
    let description = 'Cross-Feature Automation Trigger:\n';
    description += `Event: ${triggerEvent}\n`;
    description += `Event Data: ${JSON.stringify(eventData)}\n`;
    
    if (userProfile && Object.keys(userProfile).length > 0) {
      description += `\nUser Profile: ${JSON.stringify(userProfile)}\n`;
    }
    
    if (context && Object.keys(context).length > 0) {
      description += `\nContext: ${JSON.stringify(context)}\n`;
    }
    
    description += `\nAnalyze this event and suggest intelligent automation for:\n`;
    description += `- Crystal Healing sessions\n`;
    description += `- Moon Rituals\n`;
    description += `- Journal prompts\n`;
    description += `- Collection recommendations\n`;
    description += `- Meditation guidance\n`;
    description += `- Cross-feature connections\n`;
    
    return description;
  }

  _mergeWithOriginalData(original, enhanced, metadata) {
    return {
      ...original,
      parserator_enhanced: enhanced,
      parserator_metadata: metadata,
      enhancement_timestamp: new Date().toISOString(),
      confidence: metadata?.confidence || 0.0,
    };
  }

  _formatRecommendations(data) {
    const recommendations = [];
    
    if (data.crystal_recommendations) {
      recommendations.push({
        type: 'crystal',
        data: data.crystal_recommendations,
      });
    }
    
    if (data.healing_suggestions && Array.isArray(data.healing_suggestions)) {
      data.healing_suggestions.forEach(suggestion => {
        recommendations.push({
          type: 'healing',
          suggestion,
        });
      });
    }
    
    if (data.ritual_recommendations && Array.isArray(data.ritual_recommendations)) {
      data.ritual_recommendations.forEach(ritual => {
        recommendations.push({
          type: 'ritual',
          suggestion: ritual,
        });
      });
    }
    
    if (data.journal_prompts && Array.isArray(data.journal_prompts)) {
      data.journal_prompts.forEach(prompt => {
        recommendations.push({
          type: 'journal',
          suggestion: prompt,
        });
      });
    }
    
    return recommendations;
  }

  _buildAutomationResult(data) {
    return {
      actions: this._parseAutomationActions(data.automation_actions),
      insights: {
        healing_suggestions: data.healing_session_suggestions || {},
        ritual_recommendations: data.ritual_recommendations || {},
        moon_activities: data.moon_phase_activities || {},
        crystal_combinations: data.crystal_combinations || {},
      },
      enhancedEntries: [],
      recommendations: data.journal_prompts || [],
      meditation_guidance: data.meditation_guidance || '',
      confidence: data.confidence || 0.0,
      reasoning: data.reasoning || '',
    };
  }

  _parseAutomationActions(actions) {
    if (!actions || typeof actions !== 'object') return [];
    
    return Object.entries(actions).map(([actionType, actionData]) => ({
      actionType,
      featureTarget: actionData.target || 'unknown',
      parameters: actionData.parameters || {},
      confidence: actionData.confidence || 0.0,
    }));
  }

  _emptyAutomationResult() {
    return {
      actions: [],
      insights: {},
      enhancedEntries: [],
      recommendations: [],
      meditation_guidance: '',
      confidence: 0.0,
      reasoning: 'Automation processing unavailable',
    };
  }
}

module.exports = ParseOperatorService;