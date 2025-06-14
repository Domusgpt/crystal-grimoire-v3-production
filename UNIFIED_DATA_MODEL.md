# UNIFIED DATA MODEL - Crystal Grimoire V0.3
## Designed for AUTOMATION and RELIABILITY

### 🎯 CORE AUTOMATABLE DATA POINTS

**What we can RELIABLY extract from image analysis + LLM:**

1. **COLOR** (95% accuracy with image analysis)
   - Primary color
   - Secondary colors
   - Color intensity/saturation
   - Transparency level

2. **STONE TYPE** (85% accuracy with LLM + Crystal Bible knowledge)
   - Quartz varieties
   - Common crystal families
   - Formation type (cluster, point, tumbled)

3. **CHAKRA ALIGNMENT** (90% accuracy - derived from color + stone type)
   - Primary chakra (color-based mapping)
   - Secondary chakras (stone property mapping)

4. **BIRTH SIGN COMPATIBILITY** (85% accuracy - derived from chakra + properties)
   - Primary zodiac associations
   - Secondary compatible signs

5. **NUMEROLOGY NUMBER** (90% accuracy - calculated from multiple factors)
   - Based on crystal name numerology
   - Color vibration number
   - Chakra number

### 🏗️ UNIFIED DATA STRUCTURE

```json
{
  "crystal_core": {
    "id": "auto_generated_uuid",
    "timestamp": "iso_string",
    "confidence_score": 0.85,
    
    // AUTOMATABLE CORE DATA
    "visual_analysis": {
      "primary_color": "purple",
      "secondary_colors": ["violet", "white"],
      "transparency": "translucent",
      "formation": "cluster",
      "size_estimate": "medium"
    },
    
    "identification": {
      "stone_type": "amethyst",
      "crystal_family": "quartz",
      "variety": "chevron_amethyst",
      "confidence": 0.88
    },
    
    "energy_mapping": {
      "primary_chakra": "third_eye",
      "secondary_chakras": ["crown"],
      "chakra_number": 6,
      "vibration_level": "high"
    },
    
    "astrological_data": {
      "primary_signs": ["pisces", "aquarius"],
      "compatible_signs": ["virgo", "capricorn"],
      "planetary_ruler": "jupiter",
      "element": "water"
    },
    
    "numerology": {
      "crystal_number": 7,
      "color_vibration": 6,
      "chakra_number": 6,
      "master_number": 7
    }
  },
  
  "user_integration": {
    "user_id": "string",
    "added_to_collection": "timestamp",
    "personal_rating": 1-10,
    "usage_frequency": "daily|weekly|monthly|occasional",
    "user_experiences": ["text_array"],
    "intention_settings": ["protection", "intuition"]
  },
  
  "automatic_enrichment": {
    "crystal_bible_reference": "page_number_or_section",
    "healing_properties": ["auto_extracted_array"],
    "usage_suggestions": ["auto_generated_suggestions"],
    "care_instructions": ["auto_generated_care"],
    "synergy_crystals": ["auto_suggested_pairings"]
  }
}
```

### 🔄 DATA FLOW AUTOMATION

```
Image Upload 
    ↓
Visual Analysis (Color, Formation, Size)
    ↓
Crystal Bible LLM Identification (Stone Type, Properties)
    ↓
Automatic Mapping (Chakra, Birth Sign, Numerology)
    ↓
User Integration (Collection, Preferences)
    ↓
Cross-Feature Data Sync (All app features use same data)
```

### 🎨 COLOR-TO-CHAKRA MAPPING (Automated)

```javascript
const COLOR_CHAKRA_MAP = {
  "red": { primary: "root", number: 1, signs: ["aries", "scorpio"] },
  "orange": { primary: "sacral", number: 2, signs: ["leo", "sagittarius"] },
  "yellow": { primary: "solar_plexus", number: 3, signs: ["gemini", "virgo"] },
  "green": { primary: "heart", number: 4, signs: ["taurus", "libra"] },
  "blue": { primary: "throat", number: 5, signs: ["aquarius", "gemini"] },
  "purple": { primary: "third_eye", number: 6, signs: ["pisces", "sagittarius"] },
  "violet": { primary: "crown", number: 7, signs: ["pisces", "aquarius"] },
  "white": { primary: "crown", number: 7, signs: ["cancer", "pisces"] },
  "clear": { primary: "all_chakras", number: 0, signs: ["all"] },
  "black": { primary: "root", number: 1, signs: ["capricorn", "scorpio"] }
};
```

### 🔢 NUMEROLOGY CALCULATION (Automated)

```javascript
function calculateCrystalNumerology(crystal) {
  const nameValue = calculateNameNumerology(crystal.name);
  const colorValue = COLOR_VIBRATION_MAP[crystal.primary_color];
  const chakraValue = crystal.chakra_number;
  
  // Master number calculation
  const masterNumber = (nameValue + colorValue + chakraValue) % 9 || 9;
  
  return {
    name_number: nameValue,
    color_vibration: colorValue,
    chakra_number: chakraValue,
    master_number: masterNumber
  };
}
```

### 🌟 FEATURE INTEGRATION POINTS

**ALL features use the SAME unified data:**

1. **Crystal Identification** → Populates `crystal_core`
2. **Collection Management** → Uses `user_integration` 
3. **Healing Sessions** → Filters by `energy_mapping.primary_chakra`
4. **Astrological Guidance** → Uses `astrological_data` + user birth chart
5. **Dream Journal** → Correlates with `numerology.master_number`
6. **Moon Rituals** → Combines `astrological_data` + lunar phases
7. **Sound Bath** → Uses `energy_mapping.vibration_level`

### 🚀 AUTOMATION PRIORITIES

**Phase 1: Core Automation (Week 1)**
- Color detection from images
- Stone type identification with Crystal Bible LLM
- Automatic chakra mapping
- Basic numerology calculation

**Phase 2: Enhanced Integration (Week 2)**
- Birth sign compatibility automation
- Crystal synergy suggestions
- Personalized recommendations engine
- Cross-feature data synchronization

**Phase 3: Advanced Features (Week 3)**
- Predictive user preferences
- Automatic ritual suggestions
- Dynamic pricing based on rarity
- Advanced analytics and insights

### 💡 RELIABILITY SAFEGUARDS

1. **Confidence Scoring**: Every automated identification includes confidence %
2. **Fallback Systems**: Manual override for low-confidence identifications
3. **User Feedback Loop**: Users can correct automations to improve accuracy
4. **Multiple Validation**: Color + Stone Type + Context validation
5. **Crystal Bible Integration**: Always reference authoritative source

### 🎯 SUCCESS METRICS

- **Color Detection**: >95% accuracy
- **Stone Identification**: >85% accuracy  
- **Chakra Mapping**: >90% accuracy (rule-based)
- **User Satisfaction**: >4.5/5 rating on automated suggestions
- **Data Consistency**: 100% across all features using unified model

This unified model ensures EVERY feature in Crystal Grimoire shares the same data foundation, making automation reliable and user experience seamless.